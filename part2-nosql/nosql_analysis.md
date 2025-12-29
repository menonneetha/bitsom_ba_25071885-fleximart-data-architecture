-- Section A: Limitations of RDBMS (4 marks - 150 words)

Explain why the current relational database would struggle with:

1. Products having different attributes (e.g., laptops have RAM/processor, shoes have size/color)
2. Frequent schema changes when adding new product types
3. Storing customer reviews as nested data

RDBMS faces critical limitations for modern e-commerce data:

1. Heterogeneous Product Attributes: RDBMS rigid schemas force uniform columns across all products. Products have category-specific fields - laptops require RAM, processor, screen_size; shoes need size, color, material. Storing these in a single products table creates:
   - NULL-heavy tables: 80% columns empty per row
   - EAV anti-pattern: Complex product_attributes table with key-value pairs
   - Poor query performance: Multiple JOINs for basic product retrieval
2. Frequent Schema Changes: Adding new product types (drones, smartwatches) demands ALTER TABLE operations causing:
   - Downtime: schema locks
   - Migration complexity across millions of rows
   - Backward compatibility breaks existing applications during schema evolution.

3. Storing customer reviews as nested data is inefficient since RDBMS requires separate reviews tables. Fetching complete product information demands 3+ JOINs (products → order_items → orders → reviews), creating N+1 query problems and slow page loads for e-commerce applications.

These rigid structures make RDBMS unsuitable for dynamic, hierarchical e-commerce data.


-- Section B: NoSQL Benefits (4 marks - 150 words)

Explain how MongoDB solves these problems using:

1. Flexible schema (document structure)
2. Embedded documents (reviews within products)
3. Horizontal scalability


MongoDB addresses RDBMS limitations through its document-oriented design:

1. Flexible Schema eliminates rigid column requirements. Laptops store {ram: "16GB", processor: "i7", screen: "15inch"} while shoes store {size: 42, color: "black", material: "leather"} in the same collection without NULL-heavy tables. New product types like drones or smartwatches add fields instantly without ALTER TABLE operations, schema locks, costly migrations, or downtime. Developers evolve schemas organically as business needs change.

2. Embedded Documents solve nested data problems by storing customer reviews directly within product documents. A single query retrieves complete product + reviews data, eliminating 3+ JOINs (products → order_items → orders → reviews) and N+1 query problems that cause slow e-commerce page loads.

3. Horizontal Scalability distributes data across shards/clusters, handling Black Friday traffic spikes that overwhelm single RDBMS servers. MongoDB scales linearly by adding commodity hardware rather than expensive vertical server upgrades.


-- Section C: Trade-offs (2 marks - 100 words)

What are two disadvantages of using MongoDB instead of MySQL for this product catalog?

MongoDB presents two key disadvantages compared to MySQL for product catalogs:

1. Complex Transactions: MongoDB lacks robust multi-document ACID transactions across collections. Product catalog operations like "update inventory + create order + log review" require complex application-level coordination, risking data inconsistencies during failures. MySQL handles these atomically with simple transactions.

2. Query Limitations: No traditional SQL JOINs force data denormalization. Cross-referencing products, orders, and customers requires multiple queries or expensive aggregation pipelines, increasing application complexity and latency. MySQL's JOINs enable efficient relational queries for reporting and analytics.

These trade-offs make MongoDB less suitable for heavy transactional workloads requiring strong consistency.