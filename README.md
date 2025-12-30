# bitsom_ba_25071885-fleximart-data-architecture
Module 2: Assignment: AI Data Architecture Design and Implementation
# FlexiMart Data Architecture Project

**Student Name:** Neetha Menon
**Student ID:** bitsom_ba_25071885
**Email:** neetha.menon@gmail.com
**Date:** 27-Dec-2025

## Project Overview

The FlexiMart Data Architecture Project implements a comprehensive analytics solution, featuring MongoDB for operational product catalog management and a MySQL star schema data warehouse for sales analytics. Key deliverables include product data import/queries (Task 2.2), star schema design with fact_sales and dimensions dim_date/dim_product/dim_customer (Task 3.1), data population meeting volume/realism criteria (Task 3.2), and advanced analytical queries demonstrating drill-down, window functions, and customer segmentation (Task 3.3). This architecture enables FlexiMart executives to analyze sales patterns, identify top products/customers, and support data-driven decisions across time, product, and customer dimensions.

## Repository Structure
├── part1-database-etl/
│   ├── etl_pipeline.py
│   ├── schema_documentation.md
│   ├── business_queries.sql
│   └── data_quality_report.txt
├── part2-nosql/
│   ├── nosql_analysis.md
│   ├── mongodb_operations.js
│   └── products_catalog.json
├── part3-datawarehouse/
│   ├── star_schema_design.md
│   ├── warehouse_schema.sql
│   ├── warehouse_data.sql
│   └── analytics_queries.sql
└── README.md

## Technologies Used

- Python 3.x, pandas, mysql-connector-python
- MySQL 8.0 / PostgreSQL 14
- MongoDB 6.0

## Setup Instructions

### Database Setup

```bash
# Create databases
mysql -u root -p -e "CREATE DATABASE fleximart;"
mysql -u root -p -e "CREATE DATABASE fleximart_dw;"

# Run Part 1 - ETL Pipeline
python part1-database-etl/etl_pipeline.py

# Run Part 1 - Business Queries
mysql -u root -p fleximart < part1-database-etl/business_queries.sql

# Run Part 3 - Data Warehouse
mysql -u root -p fleximart_dw < part3-datawarehouse/warehouse_schema.sql
mysql -u root -p fleximart_dw < part3-datawarehouse/warehouse_data.sql
mysql -u root -p fleximart_dw < part3-datawarehouse/analytics_queries.sql


### MongoDB Setup

mongosh < part2-nosql/mongodb_operations.js

## Key Learnings

* Applied star schema design principles including precise fact/dimension granularity, surrogate keys for performance, and ETL data flows that enable scalable analytics.
* Implemented advanced SQL techniques such as hierarchical time drill-downs (year→quarter→month), window functions for revenue contribution percentages, and CASE statements for customer value segmentation.
* Gained practical experience troubleshooting MongoDB data import issues, MySQL foreign key constraints, and duplicate key errors while ensuring data volume, realism, and integrity requirements.
* Demonstrated production-ready analytics by creating business intelligence queries that support executive decision-making across time, product performance, and customer segmentation dimensions.

## Challenges Faced

1. Challenge: etl_pipeline.py failed to process and load FlexiMart product JSON data into MySQL due to parsing errors and duplicate SKU handling during testing.
Solution: Debugged the script by adding error logging, implemented deduplication logic using SQL INSERT IGNORE or REPLACE, and corrected JSON parsing to handle nested attributes like categories and pricing properly before final MongoDB deployment.

2. Challenge: Encountered duplicate key errors during MongoDB product data import from JSON files.
Solution: Identified and removed duplicate entries in the source data using MongoDB queries, then re-imported with upsert operations to ensure unique SKUs without data loss.

3. Challenge: MySQL foreign key constraints failed during data warehouse population due to missing dimension records.
Solution: Implemented sequential ETL loading—first populating dimensions (dim_date, dim_product, dim_customer) with surrogate keys, then inserting fact_sales to satisfy referential integrity.

4. Challenge: Ensuring data volume and realism requirements while generating synthetic sales data for 10,000+ records.
Solution: Used Python scripts to create realistic distributions (e.g., Pareto for customer revenue, seasonal patterns for dates) and validated totals against FlexiMart business metrics before loading.

