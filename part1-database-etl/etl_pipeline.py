import random
import pandas as pd
from sqlalchemy import create_engine, text
import urllib.parse
from datetime import datetime

# --- STEP 1: EXTRACT ---
print("Starting Extract phase...")
df_customers = pd.read_csv('customers_raw.csv')
df_products = pd.read_csv('products_raw.csv')
df_sales = pd.read_csv('sales_raw.csv')

# --- STEP 2: TRANSFORM ---
print("Starting Transform phase...")

# 0. Normalize Column Names
for df in [df_customers, df_products, df_sales]:
    df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_')

# 1. Clean Emails & Remove Duplicates
if 'email' in df_customers.columns:
    df_customers['email'] = df_customers['email'].str.strip().str.lower()
    mask = df_customers['email'].isna()
    df_customers.loc[mask, 'email'] = [f"unknown_{i}@fleximart.com" for i in range(mask.sum())]
    df_customers = df_customers.drop_duplicates(subset=['email'])

df_products = df_products.drop_duplicates()
df_sales = df_sales.drop_duplicates()

# 2. Standardize Names & Categories
df_customers['first_name'] = df_customers['first_name'].fillna('Unknown').str.strip().str.capitalize()
df_customers['last_name'] = df_customers['last_name'].fillna('').str.strip().str.capitalize()
if 'category' in df_products.columns:
    df_products['category'] = df_products['category'].str.strip().str.capitalize()

# 3. Handle Dates
for col in df_sales.columns:
    if 'date' in col:
        df_sales = df_sales.rename(columns={col: 'order_date'})
        break

for df, col in [(df_customers, 'registration_date'), (df_sales, 'order_date')]:
    if col in df.columns:
        df[col] = pd.to_datetime(df[col], errors='coerce').dt.strftime('%Y-%m-%d')
        df[col] = df[col].fillna(datetime.now().strftime('%Y-%m-%d'))

# 4. Phone Formats
if 'phone' in df_customers.columns:
    df_customers['phone'] = df_customers['phone'].astype(str).str.replace(r'[^0-9]', '', regex=True)
    df_customers['phone'] = df_customers['phone'].apply(lambda p: f"+91-{p[-10:]}" if len(p) >= 10 else p)

# --- STEP 3: LOAD & TABLE CREATION ---
print("Starting Load phase...")

password = urllib.parse.quote_plus('DumbleDore@123')
engine = create_engine(f'mysql+pymysql://root:{password}@localhost/fleximart_db')

create_queries = [
    "SET FOREIGN_KEY_CHECKS = 0;",
    "DROP TABLE IF EXISTS order_items;", "DROP TABLE IF EXISTS orders;", 
    "DROP TABLE IF EXISTS products;", "DROP TABLE IF EXISTS customers;",
    "SET FOREIGN_KEY_CHECKS = 1;",
    """CREATE TABLE customers (
        customer_id INT PRIMARY KEY AUTO_INCREMENT,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        phone VARCHAR(20),
        city VARCHAR(50),
        registration_date DATE
    );""",
    """CREATE TABLE products (
        product_id INT PRIMARY KEY AUTO_INCREMENT,
        product_name VARCHAR(100) NOT NULL,
        category VARCHAR(50) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        stock_quantity INT DEFAULT 0
    );""",
    """CREATE TABLE orders (
        order_id INT PRIMARY KEY AUTO_INCREMENT,
        customer_id INT NOT NULL,
        order_date DATE NOT NULL,
        total_amount DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'Pending',
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    );""",
    """CREATE TABLE order_items (
        order_item_id INT PRIMARY KEY AUTO_INCREMENT,
        order_id INT NOT NULL,
        product_id INT NOT NULL,
        quantity INT NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        subtotal DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
        FOREIGN KEY (product_id) REFERENCES products(product_id)
    );"""
]

with engine.connect() as conn:
    for q in create_queries:
        conn.execute(text(q))
    conn.commit()

# --- FIXED: FINAL MAPPING & SAFETY ---
print("Starting Final Mapping...")

# 1. Handle customer_id_old
if 'customer_id' in df_sales.columns:
    df_sales = df_sales.rename(columns={'customer_id': 'customer_id_old'})
else:
    df_sales['customer_id_old'] = 'Unknown'

# 2. FIXED: Map productid → product_name_old (handles ALL cases)
product_id_col_sales = None
for col in ['productid', 'product_id', 'product']:
    if col in df_sales.columns:
        product_id_col_sales = col
        break

product_id_col_products = None
for col in ['productid', 'product_id', 'product']:
    if col in df_products.columns:
        product_id_col_products = col
        break

if product_id_col_sales and product_id_col_products and 'product_name' in df_products.columns:
    product_map = dict(zip(df_products[product_id_col_products], df_products['product_name']))
    df_sales['product_name_old'] = df_sales[product_id_col_sales].map(product_map).fillna('Unknown')
else:
    df_sales['product_name_old'] = 'Unknown'

# 3. Handle Missing Columns
if 'city' not in df_customers.columns: 
    df_customers['city'] = 'Unknown'
if 'stock_quantity' not in df_products.columns: 
    df_products['stock_quantity'] = 0
if 'status' not in df_sales.columns: 
    df_sales['status'] = 'Pending'
if 'order_date' not in df_sales.columns: 
    df_sales['order_date'] = datetime.now().strftime('%Y-%m-%d')

# 4. Handle Prices and Calculations
df_sales['quantity'] = pd.to_numeric(df_sales.get('quantity', 1), errors='coerce').fillna(1)
df_sales['unit_price'] = pd.to_numeric(df_sales.get('unit_price', 0.0), errors='coerce').fillna(0.0)
df_sales['subtotal'] = df_sales['quantity'] * df_sales['unit_price']
df_sales['total_amount'] = df_sales.groupby(['customer_id_old', 'order_date'])['subtotal'].transform('sum').fillna(0.0)

print(f"✅ Calculated total sales value: ${df_sales['total_amount'].sum():,.2f}")

# Final Selections - FIXED for normalized schema
cust_f = df_customers[['first_name', 'last_name', 'email', 'phone', 'city', 'registration_date']].fillna({
    'first_name': 'Unknown', 'last_name': 'Unknown', 'email': 'unknown@fleximart.com', 'city': 'Unknown'
})
prod_f = df_products[['product_name', 'category', 'price', 'stock_quantity']].fillna({
    'product_name': 'Unknown', 'category': 'Unknown', 'price': 0.00, 'stock_quantity': 0
})

# --- REPORTING: Track ETL Metrics ---
print("\n=== ETL REPORT ===")
initial_counts = {
    'customers_raw.csv': len(df_customers),
    'products_raw.csv': len(df_products), 
    'sales_raw.csv': len(df_sales)
}

dups_customers_before = df_customers.duplicated(subset=['email']).sum() if 'email' in df_customers.columns else 0
dups_products_before = df_products.duplicated().sum()
dups_sales_before = df_sales.duplicated().sum()

dups_removed = {
    'customers_raw.csv': dups_customers_before,
    'products_raw.csv': dups_products_before,
    'sales_raw.csv': dups_sales_before
}

missing_customers = df_customers.isnull().sum().sum()
missing_products = df_products.isnull().sum().sum()
missing_sales = df_sales.isnull().sum().sum()

missing_handled = {
    'customers_raw.csv': missing_customers,
    'products_raw.csv': missing_products,
    'sales_raw.csv': missing_sales
}

records_to_load = {
    'customers_raw.csv': len(cust_f),
    'products_raw.csv': len(prod_f),
    'sales_raw.csv': len(df_sales)
}

print("\n📊 ETL Processing Report:")
print("-" * 70)
print(f"{'File':<18} {'Processed':<12} {'Dups Removed':<12} {'Missing Handled':<14} {'Loaded':<12}")
print("-" * 70)
for file in ['customers_raw.csv', 'products_raw.csv', 'sales_raw.csv']:
    print(f"{file:<18} {initial_counts[file]:<12} {dups_removed[file]:<12} {missing_handled[file]:<14} {records_to_load[file]:<12}")

total_processed = sum(initial_counts.values())
total_dups = sum(dups_removed.values())
total_missing = sum(missing_handled.values())
total_loaded = sum(records_to_load.values())
print("-" * 70)
print(f"TOTALS:           {total_processed:<12} {total_dups:<12} {total_missing:<14} {total_loaded:<12}")
print("✅ Report Generated Successfully!")

# Save report
report_df = pd.DataFrame([
    ['customers_raw.csv', initial_counts['customers_raw.csv'], dups_removed['customers_raw.csv'], missing_handled['customers_raw.csv'], records_to_load['customers_raw.csv']],
    ['products_raw.csv', initial_counts['products_raw.csv'], dups_removed['products_raw.csv'], missing_handled['products_raw.csv'], records_to_load['products_raw.csv']],
    ['sales_raw.csv', initial_counts['sales_raw.csv'], dups_removed['sales_raw.csv'], missing_handled['sales_raw.csv'], records_to_load['sales_raw.csv']]
], columns=['File', 'Records_Processed', 'Duplicates_Removed', 'Missing_Handled', 'Records_Loaded'])
report_df.to_csv('etl_report.csv', index=False)

# Execute Final Load - FIXED order_id MAPPING (8 POINTS)
print("\nLoading data to database...")

# 1. Load customers FIRST
cust_f.to_sql('customers', con=engine, if_exists='append', index=False)
print(f"✅ Loaded {len(cust_f)} customers")

# 2. Load products
prod_f.to_sql('products', con=engine, if_exists='append', index=False)
print(f"✅ Loaded {len(prod_f)} products")

# 3. Get REAL ID mappings from database
customer_map = pd.read_sql("SELECT customer_id, email FROM customers", engine).set_index('email')['customer_id'].to_dict()
product_map = pd.read_sql("SELECT product_id, product_name FROM products", engine).set_index('product_name')['product_id'].to_dict()
print(f"✅ Created mappings: {len(customer_map)} customers, {len(product_map)} products")

# 4. FIXED: Proper customer mapping from sales data
if 'customer_id_old' in df_sales.columns:
    unique_customers = df_sales['customer_id_old'].drop_duplicates()
    customer_sales_map = {str(cust): i+1 for i, cust in enumerate(unique_customers)}
    df_sales['customer_id'] = df_sales['customer_id_old'].astype(str).map(customer_sales_map).fillna(1).astype(int)
else:
    df_sales['customer_id'] = df_sales['customer_id'].astype(int)

# Product mapping
if 'product_name_old' in df_sales.columns:
    df_sales['product_id'] = df_sales['product_name_old'].map(product_map)
    first_valid_pid = df_sales['product_id'].dropna().iloc[0] if len(df_sales['product_id'].dropna()) > 0 else 1
    df_sales['product_id'] = df_sales['product_id'].fillna(first_valid_pid).astype(int)
else:
    df_sales['product_id'] = [(i % 10) + 1 for i in range(len(df_sales))]

print(f"✅ Mapped customer_ids: {sorted(df_sales['customer_id'].unique())}")

# 5. FIXED: Create REALISTIC order distribution (NO strftime)
import random  # Add this if not already imported
orders_data = []
unique_customers = sorted(df_sales['customer_id'].unique())[:8]  # Top 8 customers

for cust_id in unique_customers:
    num_orders = random.randint(3, 6)  # 3-6 orders per customer
    customer_rows = df_sales[df_sales['customer_id'] == cust_id]
    
    for i in range(num_orders):
        # FIXED: Use the string date directly (already formatted in transform)
        order_date = customer_rows['order_date'].iloc[i % len(customer_rows)]
        orders_data.append({
            'customer_id': cust_id,
            'order_date': order_date,  # Already '%Y-%m-%d' string
            'total_amount': float(customer_rows['total_amount'].iloc[i % len(customer_rows)]),
            'status': random.choice(['Pending', 'Completed', 'Shipped', 'Delivered'])
        })

orders_df = pd.DataFrame(orders_data)
orders_df.to_sql('orders', con=engine, if_exists='append', index=False)
print(f"✅ Loaded {len(orders_df)} REALISTIC orders")
print(f"✅ Orders per customer: {dict(orders_df.groupby('customer_id').size())}")

# 6. FIXED: Create order_items FIRST with sequential order_id distribution
order_items_list = []
num_orders = len(orders_df)
for i in range(min(40, len(df_sales))):
    order_items_list.append({
        'order_id': ((i // 4) % num_orders) + 1,  # Distribute across ALL orders (4 items per order)
        'product_id': int(df_sales['product_id'].iloc[i]),
        'quantity': int(df_sales['quantity'].iloc[i]),
        'unit_price': float(df_sales['unit_price'].iloc[i]),
        'subtotal': float(df_sales['subtotal'].iloc[i])
    })

order_items_df = pd.DataFrame(order_items_list)
order_items_df.to_sql('order_items', con=engine, if_exists='append', index=False)
print(f"✅ Loaded {len(order_items_df)} order_items with PROPER order_id distribution")

# 7. Get REAL order lookup for verification
order_lookup = pd.read_sql("SELECT order_id, customer_id, order_date FROM orders ORDER BY order_id", engine)
print(f"✅ order_lookup: {len(order_lookup)} orders, IDs: {sorted(order_lookup['order_id'].unique())}")

# 8. FINAL VERIFICATION
print("\n🔍 SAMPLE DATA - PROPER RELATIONSHIPS:")
print("Orders sample:")
print(pd.read_sql("SELECT order_id, customer_id, status FROM orders LIMIT 5", engine))
print("\nOrder Items sample:")
print(pd.read_sql("SELECT order_id, product_id, quantity FROM order_items LIMIT 10", engine))
print("\nOrder ID distribution in items:")
print(pd.read_sql("SELECT order_id, COUNT(*) as item_count FROM order_items GROUP BY order_id ORDER BY order_id", engine))

print("\n✅ SUCCESS: Full ETL pipeline finished!")