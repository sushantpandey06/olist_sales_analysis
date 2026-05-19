# Olist E-Commerce SQL Analysis

30+ SQL queries on the Brazilian Olist marketplace dataset. 99,441 orders across 7 tables.

Dataset: Brazilian E-Commerce Public Dataset by Olist (Kaggle)

## What this covers

Revenue trends, customer retention, seller performance, product reviews, and delivery operations. The queries use CTEs, window functions (LAG, LEAD, RANK, DENSE_RANK, ROW_NUMBER), PARTITION BY, running totals, moving averages, and cohort retention analysis.

## Main findings

The repeat customer rate is 3.12%. That means 97% of customers buy once and never come back. The cohort retention analysis confirmed this — less than 1% of customers are still active after their first month. This is the biggest problem in the dataset.

Late deliveries get 2.57 average review stars. On-time deliveries get 4.29. That's a 1.72-point gap. Delivery speed is the single strongest driver of customer satisfaction on this platform.

Revenue grew from about 138K to 1.19M per month during 2017, then stabilized above 1M through most of 2018.

One seller was processing 1,300+ orders with an average delivery time of 22 days while the platform average is 12. That's a bottleneck.

## Schema

7 tables: orders, customers, order_items, order_payments, order_reviews, products, sellers. Connected through order_id, customer_id, product_id, seller_id.

## How to run

1. Set up PostgreSQL
2. Run the CREATE TABLE statements from the SQL file
3. Load the CSVs from Kaggle
4. Run the queries in order — each one has a comment explaining what it answers and what the result means

## What I'd improve

- Add RFM segmentation (recency, frequency, monetary)
- Basket analysis to find products bought together
- Automate as stored procedures for monthly reporting
