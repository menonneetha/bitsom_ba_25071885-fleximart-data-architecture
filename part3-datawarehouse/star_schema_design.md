Section 1: Schema Overview (4 marks)

1. FACT TABLE: fact_sales

Grain: One row per product per order line item
Business Process: Sales transactions

Measures (Numeric Facts):
quantity_sold: Number of units sold (INT)
unit_price: Price per unit at time of sale (DECIMAL)
discount_amount: Discount applied (DECIMAL)
total_amount: Final amount (quantity × unit_price - discount) (DECIMAL)

Foreign Keys:
date_key → dim_date
product_key → dim_product
customer_key → dim_customer

2. DIMENSION TABLE: dim_date

Purpose: Date dimension for time-based analysis
Type: Conformed dimension

Attributes:
date_key (PK): Surrogate key (INT, format: YYYYMMDD)
full_date: Actual date (DATE)
day_of_week: Monday, Tuesday, etc. (VARCHAR)
month: 1-12 (INT)
month_name: January, February, etc. (VARCHAR)
quarter: Q1, Q2, Q3, Q4 (VARCHAR)
year: 2023, 2024, etc. (INT)
is_weekend: Boolean (BOOLEAN)

3. DIMENSION TABLE: dim_product
Purpose: Product dimension for product-based analysis
Type: Conformed dimension

Attributes:
product_key (PK): Surrogate key (INT)
product_id: Source system ID (VARCHAR)
product_name: Product name (VARCHAR)
category: Electronics, Fashion, etc. (VARCHAR)
subcategory: Smartphones, Laptops, etc. (VARCHAR)
brand: Samsung, Apple, etc. (VARCHAR)
unit_cost: Cost price (DECIMAL)

4. DIMENSION TABLE: dim_customer
Purpose: Customer dimension for customer segmentation
Type: Conformed dimension

Attributes:
customer_key (PK): Surrogate key (INT)
customer_id: Source system ID (VARCHAR)
customer_name: Full name (VARCHAR)
email: Customer email (VARCHAR)
phone: Contact number (VARCHAR)
city: City name (VARCHAR)
state: State name (VARCHAR)
customer_segment: VIP, Regular, New (VARCHAR)
join_date: First purchase date (DATE)

4 tables total: 1 fact + 3 dimensions
---------------------------------------------------------------------------------------------------------------------

Section 2: Design Decisions (3 marks - 150 words)

Explain:

1. Why you chose this granularity (transaction line-item level)

Transaction line-item granularity enables precise sales analysis at the most atomic level. Each row represents one product within one order, capturing exact quantity_sold, unit_price, and discount_amount per item. This supports detailed queries like "Which specific products drove January revenue?" without aggregation loss, unlike order-level granularity that hides product mix within multi-item orders.

2. Why surrogate keys instead of natural keys

Surrogate keys (date_key, product_key, customer_key) replace natural keys for performance and flexibility. Natural keys like product_id change rarely but create wide, inefficient joins. Surrogate INT keys enable compact indexes, faster JOINs, and schema evolution - new source systems map to existing surrogate keys without fact table rewrites.

3. How this design supports drill-down and roll-up operations

Drill-down/roll-up works seamlessly: Roll-up from daily sales (fact_sales → dim_date.year) to yearly totals; drill-down from Electronics category (dim_product.category) to specific smartphones. Time hierarchy (dim_date: day → month → quarter → year) and product hierarchy (category → subcategory → brand) enable intuitive multi-level analysis across all dimensions simultaneously.

---------------------------------------------------------------------------------------------------------------------
Section 3: Sample Data Flow (3 marks)
Source Transaction (orders table):
Order #101, Customer "John Doe" (CUST001), Product "Samsung Galaxy S21 Ultra" (ELEC001), Qty: 2, Unit Price: 50000, Discount: 0, Order Date: 2024-01-15

ETL Transformation → Data Warehouse:
fact_sales (1 row):
{
  date_key: 20240115,
  product_key: 5,
  customer_key: 12,
  quantity_sold: 2,
  unit_price: 50000,
  discount_amount: 0,
  total_amount: 100000
}

dim_date (lookup):

{
  date_key: 20240115 (PK),
  full_date: '2024-01-15',
  day_of_week: 'Monday',
  month: 1,
  month_name: 'January',
  quarter: 'Q1',
  year: 2024,
  is_weekend: false
}

dim_product (lookup):

{
  product_key: 5 (PK),
  product_id: 'ELEC001',
  product_name: 'Samsung Galaxy S21 Ultra',
  category: 'Electronics',
  subcategory: 'Smartphones',
  brand: 'Samsung',
  unit_cost: 45000
}

dim_customer (lookup):

{
  customer_key: 12 (PK),
  customer_id: 'CUST001',
  customer_name: 'John Doe',
  email: 'john.doe@email.com',
  city: 'Mumbai',
  state: 'Maharashtra',
  customer_segment: 'VIP',
  join_date: '2023-12-01'
}

Flow: Source → ETL (lookup surrogate keys, calculate total_amount) → Star Schema
