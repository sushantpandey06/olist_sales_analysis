# Olist E-Commerce Sales Analysis

## Project Overview

This project analyzes the Brazilian Olist E-Commerce dataset using PostgreSQL to explore marketplace revenue, customer behavior, seller performance, product satisfaction, and delivery operations.

The analysis focuses on identifying business insights and operational risks using advanced SQL techniques including window functions, Common Table Expressions (CTEs), cohort retention analysis, ranking functions, and multi-table joins.

---

## Dataset Information

- **Dataset:** Brazilian E-Commerce Public Dataset by Olist
- **Source:** Kaggle
- **Time Period:** September 2016 – October 2018
- **Orders:** 99,441
- **Order Items:** 112,650
- **Unique Customers:** 96,096
- **Tables Used:** 8 relational tables

### Tables
- orders
- customers
- order_items
- order_payments
- order_reviews
- products
- sellers
- geolocation

---

## Business Problems Addressed

This project answers real-world business questions including:

### Revenue & Sales Analysis
- Total marketplace revenue
- Monthly revenue growth trends
- Month-over-month growth analysis
- Revenue by product category
- Revenue moving averages
- Revenue seasonality patterns

### Customer Analysis
- Repeat customer rate
- Customer lifetime value (CLV)
- Customer retention trends
- Cohort retention analysis
- Customer ranking by spending

### Seller & Product Analysis
- Top-performing sellers
- Seller delivery performance
- Product category revenue analysis
- High-revenue vs low-rating categories

### Delivery & Operations
- Average delivery time
- Late delivery impact on customer reviews
- Delivery bottlenecks
- Delivery trends across sellers

---

## SQL Concepts & Techniques Used

### SQL Fundamentals
- GROUP BY
- HAVING
- INNER JOIN
- LEFT JOIN
- CASE WHEN
- Aggregate Functions

### Window Functions
- LAG()
- LEAD()
- RANK()
- DENSE_RANK()
- ROW_NUMBER()
- SUM() OVER
- AVG() OVER
- PARTITION BY

### Advanced SQL
- Common Table Expressions (CTEs)
- Multi-step CTEs
- Cohort Retention Analysis
- Running Totals
- Moving Averages
- NULL Handling
- NULLIF() for safe division

### Date Functions
- DATE_TRUNC()
- EXTRACT()
- EXTRACT(DOW)

---

## Key Findings

### 1. Severe Customer Retention Weakness
- Repeat customer rate is only **3.12%**
- Nearly **97% of customers purchased only once**
- Cohort analysis showed retention dropping below 1% after the first month

### 2. Delivery Performance Strongly Impacts Customer Satisfaction
- On-time deliveries averaged **4.29 review score**
- Late deliveries averaged only **2.57 review score**
- Delivery speed appears to be one of the strongest drivers of customer satisfaction

### 3. Marketplace Revenue Growth
- Total marketplace revenue exceeded **16 million**
- Revenue experienced rapid growth throughout 2017 and early 2018
- Revenue later stabilized above 1 million per month

### 4. Operational Bottlenecks Among Sellers
- Some high-volume sellers averaged delivery times exceeding 20 days
- One seller processed over 1,300 orders with nearly 22-day average delivery time

### 5. Diversified Product Revenue
- Revenue was distributed across multiple product categories
- Health & beauty, watches, and home furnishing generated the highest revenue

---

## Business Recommendations

### Improve Customer Retention
- Introduce loyalty programs
- Create personalized promotions
- Increase post-purchase engagement

### Optimize Delivery Operations
- Monitor high-delay sellers
- Improve logistics partnerships
- Reduce late delivery rates

### Strengthen Seller Monitoring
- Track seller delivery benchmarks
- Monitor customer satisfaction by seller

### Expand High-Satisfaction Categories
- Prioritize categories with strong reviews and strong revenue


---

## Tools Used

- PostgreSQL
- pgAdmin 4
- SQL
- GitHub

---

