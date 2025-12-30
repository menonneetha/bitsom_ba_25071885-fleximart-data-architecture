-- warehouse_data.sql - Task 3.2 Star Schema Data (10 marks)
-- Minimum requirements: 30 dates, 15 products, 12 customers, 40 sales
-- Run AFTER warehouse_schema.sql

USE fleximart_dw;

-- ========================================
-- dim_date: 30 dates (Jan 1 - Jan 30, 2024)
-- ========================================
INSERT INTO dim_date (date_key, full_date, day_of_week, day_of_month, month, month_name, quarter, year, is_weekend) VALUES
(20240101, '2024-01-01', 'Monday', 1, 1, 'January', 'Q1', 2024, FALSE),
(20240102, '2024-01-02', 'Tuesday', 2, 1, 'January', 'Q1', 2024, FALSE),
(20240103, '2024-01-03', 'Wednesday', 3, 1, 'January', 'Q1', 2024, FALSE),
(20240104, '2024-01-04', 'Thursday', 4, 1, 'January', 'Q1', 2024, FALSE),
(20240105, '2024-01-05', 'Friday', 5, 1, 'January', 'Q1', 2024, FALSE),
(20240106, '2024-01-06', 'Saturday', 6, 1, 'January', 'Q1', 2024, TRUE),
(20240107, '2024-01-07', 'Sunday', 7, 1, 'January', 'Q1', 2024, TRUE),
(20240108, '2024-01-08', 'Monday', 8, 1, 'January', 'Q1', 2024, FALSE),
(20240109, '2024-01-09', 'Tuesday', 9, 1, 'January', 'Q1', 2024, FALSE),
(20240110, '2024-01-10', 'Wednesday', 10, 1, 'January', 'Q1', 2024, FALSE),
(20240111, '2024-01-11', 'Thursday', 11, 1, 'January', 'Q1', 2024, FALSE),
(20240112, '2024-01-12', 'Friday', 12, 1, 'January', 'Q1', 2024, FALSE),
(20240113, '2024-01-13', 'Saturday', 13, 1, 'January', 'Q1', 2024, TRUE),
(20240114, '2024-01-14', 'Sunday', 14, 1, 'January', 'Q1', 2024, TRUE),
(20240115, '2024-01-15', 'Monday', 15, 1, 'January', 'Q1', 2024, FALSE),
(20240116, '2024-01-16', 'Tuesday', 16, 1, 'January', 'Q1', 2024, FALSE),
(20240117, '2024-01-17', 'Wednesday', 17, 1, 'January', 'Q1', 2024, FALSE),
(20240118, '2024-01-18', 'Thursday', 18, 1, 'January', 'Q1', 2024, FALSE),
(20240119, '2024-01-19', 'Friday', 19, 1, 'January', 'Q1', 2024, FALSE),
(20240120, '2024-01-20', 'Saturday', 20, 1, 'January', 'Q1', 2024, TRUE),
(20240121, '2024-01-21', 'Sunday', 21, 1, 'January', 'Q1', 2024, TRUE),
(20240122, '2024-01-22', 'Monday', 22, 1, 'January', 'Q1', 2024, FALSE),
(20240123, '2024-01-23', 'Tuesday', 23, 1, 'January', 'Q1', 2024, FALSE),
(20240124, '2024-01-24', 'Wednesday', 24, 1, 'January', 'Q1', 2024, FALSE),
(20240125, '2024-01-25', 'Thursday', 25, 1, 'January', 'Q1', 2024, FALSE),
(20240126, '2024-01-26', 'Friday', 26, 1, 'January', 'Q1', 2024, FALSE),
(20240127, '2024-01-27', 'Saturday', 27, 1, 'January', 'Q1', 2024, TRUE),
(20240128, '2024-01-28', 'Sunday', 28, 1, 'January', 'Q1', 2024, TRUE),
(20240129, '2024-01-29', 'Monday', 29, 1, 'January', 'Q1', 2024, FALSE),
(20240130, '2024-01-30', 'Tuesday', 30, 1, 'January', 'Q1', 2024, FALSE);
-- Add 2 February dates for demo
INSERT INTO dim_date (date_key, full_date, day_of_week, day_of_month, month, month_name, quarter, year, is_weekend) VALUES
(20240201, '2024-02-01', 'Thursday', 1, 2, 'February', 'Q1', 2024, FALSE),
(20240202, '2024-02-02', 'Friday', 2, 2, 'February', 'Q1', 2024, FALSE);
-- Add March dates for complete Q1 demo
INSERT INTO dim_date (date_key, full_date, day_of_week, day_of_month, month, month_name, quarter, year, is_weekend) VALUES
(20240301, '2024-03-01', 'Friday', 1, 3, 'March', 'Q1', 2024, FALSE),
(20240302, '2024-03-02', 'Saturday', 2, 3, 'March', 'Q1', 2024, TRUE);

-- ========================================
-- dim_product: 15 products (5 per category)
-- ========================================
INSERT INTO dim_product (product_id, product_name, category, subcategory, unit_price) VALUES
('ELEC001', 'Samsung Galaxy S21 Ultra', 'Electronics', 'Smartphones', 79999.00),
('ELEC002', 'Apple MacBook Pro 14-inch', 'Electronics', 'Laptops', 189999.00),
('ELEC003', 'Sony WH-1000XM5 Headphones', 'Electronics', 'Audio', 29990.00),
('ELEC004', 'Dell 27-inch 4K Monitor', 'Electronics', 'Monitors', 32999.00),
('ELEC005', 'OnePlus Nord CE 3', 'Electronics', 'Smartphones', 26999.00),
('FASH001', 'Levi''s 511 Slim Fit Jeans', 'Fashion', 'Clothing', 3499.00),
('FASH002', 'Nike Air Max 270 Sneakers', 'Fashion', 'Footwear', 12995.00),
('FASH003', 'Adidas Originals T-Shirt', 'Fashion', 'Clothing', 1499.00),
('FASH004', 'Puma RS-X Sneakers', 'Fashion', 'Footwear', 8999.00),
('FASH005', 'H&M Slim Fit Formal Shirt', 'Fashion', 'Clothing', 1999.00),
('HOME001', 'IKEA Coffee Table', 'Home', 'Furniture', 5999.00),
('HOME002', 'Philips LED Bulb 10W', 'Home', 'Lighting', 299.00),
('HOME003', 'Dyson Vacuum Cleaner', 'Home', 'Appliances', 34999.00),
('HOME004', 'IKEA Bookshelf', 'Home', 'Furniture', 7999.00),
('HOME005', 'Crompton Ceiling Fan', 'Home', 'Appliances', 2499.00);

-- ========================================
-- dim_customer: 12 customers (4 cities)
-- ========================================
INSERT INTO dim_customer (customer_id, customer_name, city, state, customer_segment) VALUES
('CUST001', 'John Doe', 'Mumbai', 'Maharashtra', 'VIP'),
('CUST002', 'Priya Sharma', 'Mumbai', 'Maharashtra', 'Regular'),
('CUST003', 'Raj Patel', 'Mumbai', 'Maharashtra', 'New'),
('CUST004', 'Anita Singh', 'Mumbai', 'Maharashtra', 'VIP'),
('CUST005', 'Vikram Reddy', 'Bangalore', 'Karnataka', 'Regular'),
('CUST006', 'Sneha Gupta', 'Bangalore', 'Karnataka', 'New'),
('CUST007', 'Arjun Menon', 'Bangalore', 'Karnataka', 'VIP'),
('CUST008', 'Lakshmi Nair', 'Bangalore', 'Karnataka', 'Regular'),
('CUST009', 'Rahul Joshi', 'Delhi', 'Delhi', 'New'),
('CUST010', 'Meera Khan', 'Delhi', 'Delhi', 'VIP'),
('CUST011', 'Amit Verma', 'Delhi', 'Delhi', 'Regular'),
('CUST012', 'Deepa Iyer', 'Chennai', 'Tamil Nadu', 'New');

-- ========================================
-- fact_sales: 40 transactions (weekend sales higher)
-- ========================================
INSERT INTO fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, discount_amount, total_amount) VALUES
-- Weekdays (lower volume)
(20240102, 1, 1, 1, 79999.00, 0.00, 79999.00),
(20240103, 2, 2, 1, 189999.00, 5000.00, 184999.00),
(20240104, 3, 3, 2, 29990.00, 0.00, 59980.00),
(20240105, 4, 4, 1, 32999.00, 0.00, 32999.00),
(20240108, 5, 5, 1, 26999.00, 0.00, 26999.00),
(20240109, 6, 6, 3, 3499.00, 0.00, 10497.00),
(20240110, 7, 7, 2, 1499.00, 0.00, 2998.00),
(20240111, 8, 8, 1, 8999.00, 0.00, 8999.00),
-- Weekends (higher volume)
(20240106, 1, 1, 2, 79999.00, 7999.00, 151998.00),
(20240107, 2, 2, 1, 189999.00, 0.00, 189999.00),
(20240113, 3, 3, 3, 29990.00, 0.00, 89970.00),
(20240114, 4, 4, 2, 32999.00, 0.00, 65998.00),
(20240120, 5, 5, 2, 26999.00, 0.00, 53998.00),
(20240121, 6, 6, 5, 3499.00, 349.00, 16801.00),
(20240127, 7, 7, 4, 1499.00, 0.00, 5996.00),
(20240128, 8, 8, 2, 8999.00, 0.00, 17998.00),
-- More realistic mix across categories/customers
(20240115, 9, 9, 1, 5999.00, 0.00, 5999.00),
(20240116, 10, 10, 2, 299.00, 0.00, 598.00),
(20240117, 11, 11, 1, 34999.00, 0.00, 34999.00),
(20240118, 12, 12, 1, 7999.00, 0.00, 7999.00),
(20240119, 13, 1, 3, 2499.00, 0.00, 7497.00),
(20240122, 14, 2, 2, 50000.00, 5000.00, 95000.00),
(20240123, 15, 3, 1, 75000.00, 0.00, 75000.00),
(20240124, 1, 4, 1, 79999.00, 0.00, 79999.00),
(20240125, 2, 5, 1, 189999.00, 10000.00, 179999.00),
(20240126, 3, 6, 4, 29990.00, 1199.00, 116561.00),
(20240129, 4, 7, 1, 32999.00, 0.00, 32999.00),
(20240130, 5, 8, 3, 26999.00, 0.00, 80997.00),
-- Additional transactions for 40 total
(20240112, 6, 9, 2, 3499.00, 0.00, 6998.00),
(20240119, 7, 10, 3, 1499.00, 0.00, 4497.00),
(20240126, 8, 11, 2, 8999.00, 899.00, 16999.00),
(20240105, 9, 12, 1, 5999.00, 0.00, 5999.00),
(20240112, 10, 1, 10, 299.00, 0.00, 2990.00),
(20240119, 11, 2, 1, 34999.00, 0.00, 34999.00),
(20240126, 12, 3, 1, 7999.00, 0.00, 7999.00),
(20240130, 13, 4, 2, 2499.00, 0.00, 4998.00);
INSERT INTO fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, discount_amount, total_amount) VALUES
(20240201, 1, 1, 1, 79999.00, 4000.00, 75999.00),   -- Samsung Galaxy discount
(20240202, 3, 2, 2, 29990.00, 0.00, 59980.00);      -- Sony Headphones
INSERT INTO fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, discount_amount, total_amount) VALUES
(20240301, 2, 3, 1, 189999.00, 10000.00, 179999.00),  -- MacBook discount
(20240302, 4, 4, 3, 32999.00, 0.00, 98997.00);         -- Monitors (weekend boost)



-- ========================================
-- Verification Queries (REMOVE before submission)
-- ========================================
-- SELECT COUNT(*) FROM dim_date;     -- 34
-- SELECT COUNT(*) FROM dim_product;  -- 15  
-- SELECT COUNT(*) FROM dim_customer; -- 12
-- SELECT COUNT(*) FROM fact_sales;   -- 44
