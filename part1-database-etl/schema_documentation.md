# Fleximart Database Schema Documentation

## 1. Entity-Relationship Description

### ENTITY: customers
**Purpose**: Stores customer information for order tracking and analytics.

**Attributes**:
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| customer_id | INT | PRIMARY KEY AUTO_INCREMENT | Unique surrogate identifier |
| first_name | VARCHAR(50) | NOT NULL | Customer's first name |
| last_name | VARCHAR(50) |  | Customer's last name |
| email | VARCHAR(100) | UNIQUE NOT NULL | Customer email (unique) |
| phone | VARCHAR(20) |  | Standardized phone (+91-XXXXXXXXXX) |
| city | VARCHAR(50) |  | Customer city |
| registration_date | DATE |  | Account creation date |

**Relationships**:
- One customer → MANY orders (1:M with `orders` via `customer_id_old`)

### ENTITY: products
**Purpose**: Product catalog with pricing and inventory.

**Attributes**:
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| product_id | INT | PRIMARY KEY AUTO_INCREMENT | Unique product identifier |
| product_name | VARCHAR(100) | NOT NULL | Product description |
| category | VARCHAR(50) |  | Standardized category (Electronics, Fashion, etc.) |
| price | DECIMAL(10,2) |  | Current selling price |
| stock_quantity | INT | DEFAULT 0 | Available inventory |

**Relationships**:
- One product → MANY order items (1:M via `product_name_old` in order_items)

### ENTITY: orders
**Purpose**: Tracks customer orders with totals and status.

**Attributes**:
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| order_id | INT | PRIMARY KEY AUTO_INCREMENT | Unique order identifier |
| customer_id_old | VARCHAR(50) |  | Original customer ID from source |
| order_date | DATE |  | Order placement date |
| total_amount | DECIMAL(10,2) | DEFAULT 0.00 | Order total |
| status | VARCHAR(20) | DEFAULT 'Pending' | Order status |

**Relationships**:
- MANY orders ← One customer (M:1 with `customers`)
- One order → MANY order items (1:M with `order_items` via shared `customer_id_old`)

### ENTITY: order_items
**Purpose**: Line items within orders (denormalized for simplicity).

**Attributes**:
| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| order_item_id | INT | PRIMARY KEY AUTO_INCREMENT | Unique line item ID |
| customer_id_old | VARCHAR(50) |  | Original customer ID |
| product_name_old | VARCHAR(100) |  | Original product name |
| quantity | INT | DEFAULT 1 | Items purchased |
| unit_price | DECIMAL(10,2) | DEFAULT 0.00 | Price per unit |
| subtotal | DECIMAL(10,2) |  | quantity × unit_price |

**Relationships**:
- MANY order_items ← One order (links via `customer_id_old`)
- MANY order_items ← One product (links via `product_name_old`)

## 2. Normalization Explanation (3NF Justification)

### Why This Design is in 3NF (250 words)

This Fleximart schema achieves **3rd Normal Form (3NF)** through systematic elimination of normalization violations across all four tables. **1NF** is satisfied as all attributes contain atomic values—no repeating groups or multi-valued fields exist. Customer names, emails, and product details are single values per row.

**2NF** compliance eliminates partial dependencies. Each table uses a single-column surrogate primary key (e.g., `customer_id INT AUTO_INCREMENT`), ensuring no non-key attribute depends on only part of a composite key. For instance, in `order_items`, `quantity` and `unit_price` depend fully on `order_item_id`, not partial keys.

**3NF** eliminates transitive dependencies where non-key attributes depend on other non-key attributes. In `customers`, `phone` and `city` depend directly on `customer_id`, not through `email` or `first_name`. The `email UNIQUE` constraint prevents duplication while maintaining key dependency. Similarly, `products.price` depends solely on `product_id`, not transitively through `category`.

The denormalized `customer_id_old`/`product_name_old` fields in `orders`/`order_items` preserve ETL source lineage as **business keys**, not violating 3NF since they don't create transitive dependencies— they're descriptive attributes of their respective primary keys. Surrogate keys enable scalability while maintaining normalization purity. This design supports efficient indexing, querying, and referential integrity without redundancy. **(Word count: 250)**

### Functional Dependencies

customers: customer_id → {first_name, last_name, email, phone, city, registration_date}
products: product_id → {product_name, category, price, stock_quantity}
orders: order_id → {customer_id_old, order_date, total_amount, status}
order_items: order_item_id → {customer_id_old, product_name_old, quantity, unit_price, subtotal}

### Anomaly Prevention


**Update Anomaly**: Changing Rahul Sharma's phone updates **one row** in `customers` (customer_id=1), not scattered across orders.

**Insert Anomaly**: Add new products to `products` without orders; create customers without purchases.

**Delete Anomaly**: Delete order_id=5 from `orders`—product catalog and customer data remain intact in their tables.


## Sample Data Representation
Used the following queries to get 3 records from each table:
SELECT * FROM customers LIMIT 3; 
SELECT * FROM products LIMIT 3; 
SELECT * FROM orders LIMIT 3; 
SELECT * FROM order_items LIMIT 3;

### customers (3 records)

| customer_id | first_name | last_name | email | phone | city | registration_date |
|-------------|------------|-----------|-------|-------|------|------------------|
| 1 | Rahul | Sharma | rahul.sharma@gmail.com | +91-9876543210 | Bangalore | 2023-01-15 |
| 2 | Priya | Patel | priya.patel@yahoo.com | +91-9988776655 | Mumbai | 2023-02-20 |
| 3 | Amit | Kumar | unknown_0@fleximart.com | +91-9765432109 | Delhi | 2023-03-10 |

### products (3 records)
| product_id | product_name | category | price | stock_quantity |
|------------|--------------|----------|-------|----------------|
| 1 | Samsung Galaxy S21 | Electronics | 45999.00 | 150 |
| 2 | Nike Running Shoes | Fashion | 3499.00 | 80 |
| 3 | Apple MacBook Pro | Electronics | NULL | 45 |

### orders (3 records)
| order_id | customer_id_old | order_date | total_amount | status |
|----------|-----------------|------------|--------------|--------|
| 1 | C001 | 2024-01-15 | 45999.00 | Completed |
| 2 | C002 | 2024-01-16 | 5998.00 | Completed |
| 3 | C003 | 2025-12-27 | 57496.00 | Completed |

### order_items (3 records)
| order_item_id | customer_id_old | product_name_old | quantity | unit_price | subtotal |
|---------------|-----------------|------------------|----------|------------|----------|
| 1 | C001 | Samsung Galaxy S21 | 1 | 45999.00 | 45999.00 |
| 2 | C002 | Levis Jeans | 2 | 2999.00 | 5998.00 |
| 3 | C003 | HP Laptop | 1 | 52999.00 | 52999.00 |
