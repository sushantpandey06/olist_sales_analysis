-- ============================================================
-- OLIST E-COMMERCE SALES ANALYSIS
-- ============================================================
--
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Source: Kaggle
--
-- Project Objective:
-- Analyze marketplace revenue, customer behavior,
-- seller performance, and delivery operations
-- to identify business insights and operational risks.
--
-- Analysis Areas:
-- 1. Revenue Analysis
-- 2. Customer Retention Analysis
-- 3. Product Category Analysis
-- 4. Seller Performance Analysis
-- 5. Delivery & Logistics Analysis
--
-- ============================================================

-- ============================================================
-- 1. DATABASE SCHEMA CREATION
-- ============================================================

-- Stores order transaction information

CREATE TABLE orders (

    order_id TEXT PRIMARY KEY,

    customer_id TEXT,

    order_status TEXT,

    order_purchase_timestamp TIMESTAMP,

    order_approved_at TIMESTAMP,

    order_delivered_carrier_date TIMESTAMP,

    order_delivered_customer_date TIMESTAMP,

    order_estimated_delivery_date TIMESTAMP
);

-- Customer information and geographic location

CREATE TABLE customers (

    customer_id TEXT PRIMARY KEY,

    customer_unique_id TEXT,

    customer_zip_code_prefix INTEGER,

    customer_city TEXT,

    customer_state TEXT
);

-- Product-level details for each order

CREATE TABLE order_items (

    order_id TEXT,

    order_item_id INTEGER,

    product_id TEXT,

    seller_id TEXT,

    shipping_limit_date TIMESTAMP,

    price NUMERIC,

    freight_value NUMERIC,

    PRIMARY KEY (order_id, order_item_id)
);

-- Payment transaction information

CREATE TABLE order_payments (

    order_id TEXT,

    payment_sequential INTEGER,

    payment_type TEXT,

    payment_installments INTEGER,

    payment_value NUMERIC
);

-- Customer review scores and feedback

CREATE TABLE order_reviews (

    review_id TEXT,

    order_id TEXT,

    review_score INTEGER,

    review_comment_title TEXT,

    review_comment_message TEXT,

    review_creation_date TIMESTAMP,

    review_answer_timestamp TIMESTAMP
);

-- Product information and category details

CREATE TABLE products (

    product_id TEXT PRIMARY KEY,

    product_category_name TEXT,

    product_name_length INTEGER,

    product_description_length INTEGER,

    product_photos_qty INTEGER,

    product_weight_g NUMERIC,

    product_length_cm NUMERIC,

    product_height_cm NUMERIC,

    product_width_cm NUMERIC
);

-- Seller information and geographic location

CREATE TABLE sellers (

    seller_id TEXT PRIMARY KEY,

    seller_zip_code_prefix INTEGER,

    seller_city TEXT,

    seller_state TEXT
);

-- Geolocation mapping by zip code

CREATE TABLE geolocation (

    geolocation_zip_code_prefix INTEGER,

    geolocation_lat NUMERIC,

    geolocation_lng NUMERIC,

    geolocation_city TEXT,

    geolocation_state TEXT
);

-- ============================================================
-- 2. RELATIONAL CONSTRAINTS
-- ============================================================

ALTER TABLE orders

ADD CONSTRAINT fk_orders_customers

FOREIGN KEY (customer_id)

REFERENCES customers(customer_id);


ALTER TABLE order_items

ADD CONSTRAINT fk_order_items_orders

FOREIGN KEY (order_id)

REFERENCES orders(order_id);


ALTER TABLE order_items

ADD CONSTRAINT fk_order_items_products

FOREIGN KEY (product_id)

REFERENCES products(product_id);


ALTER TABLE order_items

ADD CONSTRAINT fk_order_items_sellers

FOREIGN KEY (seller_id)

REFERENCES sellers(seller_id);


ALTER TABLE order_payments

ADD CONSTRAINT fk_order_payments_orders

FOREIGN KEY (order_id)

REFERENCES orders(order_id);


ALTER TABLE order_reviews

ADD CONSTRAINT fk_order_reviews_orders

FOREIGN KEY (order_id)

REFERENCES orders(order_id);


-- ============================================================
-- 3. PERFORMANCE OPTIMIZATION
-- ============================================================

CREATE INDEX idx_orders_customer

ON orders(customer_id);


CREATE INDEX idx_orders_purchase_date

ON orders(order_purchase_timestamp);


CREATE INDEX idx_order_items_order

ON order_items(order_id);


CREATE INDEX idx_order_items_product

ON order_items(product_id);


CREATE INDEX idx_order_items_seller

ON order_items(seller_id);


CREATE INDEX idx_customers_unique

ON customers(customer_unique_id);


CREATE INDEX idx_order_payments_order
ON order_payments(order_id);


CREATE INDEX idx_order_reviews_order
ON order_reviews(order_id);


-- ============================================================
-- 4. DATA VALIDATION
-- ============================================================

-- Validate row counts after import

SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_geolocation FROM geolocation;
SELECT COUNT(*) AS total_order_items FROM order_items;
SELECT COUNT(*) AS total_payments FROM order_payments;
SELECT COUNT(*) AS total_reviews FROM order_reviews;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_sellers FROM sellers;
-- The dataset contains:
-- 99,441 orders,
-- 112,650 order items,
-- and over 1 million geolocation records.

-- Validate 1-to-many relationships

SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT o.order_id) AS unique_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- Joined rows = 112650, unique orders = 98666
-- Since joined rows are significantly higher,
-- this confirms multiple items per order
-- which introduces a risk of double counting in joins


-- Validate revenue components


WITH product_value AS (
    SELECT
        order_id,
        SUM(price) AS product_total
    FROM order_items
    GROUP BY order_id
),
payment_value AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_total
    FROM order_payments
    GROUP BY order_id
)

SELECT
    ROUND(SUM(pv.product_total), 2) AS total_product_value,
    ROUND(SUM(pay.payment_total), 2) AS total_payment_value
FROM product_value pv
JOIN payment_value pay
    ON pv.order_id = pay.order_id;


-- Product value = 13.59M, Payment value = 15.85M
-- payment_value represents the full transaction amount,
-- while product value excludes additional charges.
-- Therefore, payment_value will be used consistently
-- for all revenue calculations in this project


-- Check NULL delivery timestamps

SELECT
    COUNT(*) AS null_delivered_carrier_date
FROM orders
WHERE order_delivered_carrier_date IS NULL;

SELECT
    COUNT(*) AS null_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date IS NULL;
-- 1,783 orders have missing carrier delivery timestamps,
-- while 295 orders are missing final customer delivery timestamps.


-- Check duplicate order IDs

SELECT
    order_id,
    COUNT(*)

FROM orders

GROUP BY order_id

HAVING COUNT(*) > 1;
-- No duplicate order IDs were found


-- Compare customer identifiers

SELECT
    COUNT(DISTINCT customer_id) AS total_customer_ids,

    COUNT(DISTINCT customer_unique_id) AS total_unique_customers

FROM customers;
-- The dataset contains 99,441 customer records
-- but only 96,096 unique customers


-- Validate orders and order_items relationship

SELECT
    COUNT(DISTINCT o.order_id) AS orders_table,

    COUNT(DISTINCT oi.order_id) AS order_items_table

FROM orders o

INNER JOIN order_items oi
    ON o.order_id = oi.order_id;
-- 98,666 orders successfully matched with order_items records
-- slightly lower than 99,441 total orders 

-- ============================================================
-- 5. REVENUE & SALES ANALYSIS
-- ============================================================



-- Revenue = SUM(payment_value)
-- Orders = COUNT(DISTINCT order_id)
-- Customers = COUNT(DISTINCT customer_unique_id)

-- How much total revenue did the marketplace generate?

SELECT
    ROUND(SUM(payment_value), 2) AS total_revenue

FROM order_payments;
-- The marketplace generated approximately 16 million
-- in total revenue across all recorded transactions.


-- How did marketplace revenue change over time?

WITH monthly_revenue AS (

    SELECT
        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        ) AS order_month,

        ROUND(SUM(op.payment_value), 2) AS monthly_revenue

    FROM orders o

    INNER JOIN order_payments op
        ON o.order_id = op.order_id

    GROUP BY order_month
)

SELECT
    order_month,
    monthly_revenue

FROM monthly_revenue

ORDER BY order_month;

-- Marketplace revenue grew rapidly throughout 2017,
-- increasing from ~138K in January 2017
-- to over 1.19M in November 2017.
--
-- Revenue remained relatively stable above 1M
-- during most of 2018
-- Final months show lower values due to incomplete data.


-- How did cumulative marketplace revenue grow over time?


WITH monthly_revenue AS (

    SELECT
        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        ) AS order_month,

        ROUND(SUM(op.payment_value), 2) AS revenue

    FROM orders o

    INNER JOIN order_payments op
        ON o.order_id = op.order_id

    GROUP BY order_month
)

SELECT
    order_month,

    revenue,

    ROUND(
        SUM(revenue) OVER (
            ORDER BY order_month
        ),
        2
    ) AS running_total_revenue

FROM monthly_revenue

ORDER BY order_month;

-- Cumulative marketplace revenue grew consistently over time,
-- surpassing 16 million by the end 
--
-- The strongest cumulative growth acceleration occurred
-- during 2017 and early 2018


-- What is the revenue trend over time?


WITH monthly_revenue AS (

    SELECT
        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        ) AS order_month,

        ROUND(SUM(op.payment_value), 2) AS revenue

    FROM orders o

    INNER JOIN order_payments op
        ON o.order_id = op.order_id

    GROUP BY order_month
)

SELECT
    order_month,

    revenue,

    ROUND(
        AVG(revenue) OVER (
            ORDER BY order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_avg_3_month

FROM monthly_revenue

ORDER BY order_month;

-- The 3-month moving average shows a clear
-- long-term upward revenue trend throughout
-- 2017 and early 2018.
-- The moving average exceeded 1 million during 2018


-- Which days have most and least business?
SELECT
    EXTRACT(DOW FROM order_purchase_timestamp) AS day_num,

    CASE EXTRACT(DOW FROM order_purchase_timestamp)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,

    COUNT(DISTINCT order_id) AS total_orders

FROM orders
GROUP BY day_num, day_name
ORDER BY day_num;

-- Monday has the highest order volume,
-- while Saturday records the lowest activity.

-- How did revenue change compared to the previous month?


WITH monthly_revenue AS (

    SELECT
        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        ) AS order_month,

        ROUND(SUM(op.payment_value), 2) AS revenue

    FROM orders o

    INNER JOIN order_payments op
        ON o.order_id = op.order_id

    GROUP BY order_month
)

SELECT
    order_month,

    revenue,

    LAG(revenue) OVER (
        ORDER BY order_month
    ) AS previous_month_revenue,

    ROUND(
        revenue
        -
        LAG(revenue) OVER (
            ORDER BY order_month
        ),
        2
    ) AS revenue_change,

    ROUND(
        (
            revenue
            -
            LAG(revenue) OVER (
                ORDER BY order_month
            )
        )
        * 100.0
        /
        NULLIF(
            LAG(revenue) OVER (
                ORDER BY order_month
            ),
            0
        ),
        2
    ) AS growth_percentage

FROM monthly_revenue

ORDER BY order_month;

-- Marketplace revenue experienced strong month-over-month growth
-- throughout most of 2017 and early 2018,
-- with several periods exceeding 40% growth.
--
-- November 2017 showed the largest major revenue increase,
-- growing by over 415K compared to the previous month.



-- How does current revenue compare
-- to the following month's revenue?

WITH monthly_revenue AS (

    SELECT
        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        ) AS order_month,

        ROUND(SUM(op.payment_value), 2) AS revenue

    FROM orders o

    INNER JOIN order_payments op
        ON o.order_id = op.order_id

    GROUP BY order_month
)

SELECT
    order_month,

    revenue,

    LEAD(revenue) OVER (
        ORDER BY order_month
    ) AS next_month_revenue,

    ROUND(
        LEAD(revenue) OVER (
            ORDER BY order_month
        )
        -
        revenue,
        2
    ) AS next_month_difference

FROM monthly_revenue

ORDER BY order_month;


-- strong marketplace expansion throughout 2017,
-- with major revenue acceleration occurring
-- before November 2017.
--
-- Revenue transitions became more stable during 2018,
-- suggesting reduced volatility and increasing
-- marketplace operational consistency.


-- Which product categories generate the highest marketplace revenue?


WITH category_revenue AS (

    SELECT
        p.product_category_name,

        ROUND(SUM(oi.price), 2) AS total_revenue

    FROM order_items oi

    INNER JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY p.product_category_name
)

SELECT
    product_category_name,

    total_revenue,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank,

    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS dense_revenue_rank

FROM category_revenue

ORDER BY total_revenue DESC

LIMIT 10;

-- Health & beauty, watches, and home furnishing categories
-- generated the highest marketplace revenue.

-- No ranking ties were observed among the top categories,
-- resulting in identical RANK() and DENSE_RANK() outputs.


-- Who are the top-performing sellers within each seller state?

WITH seller_revenue AS (

    SELECT
        s.seller_state,

        s.seller_id,

        ROUND(SUM(oi.price), 2) AS total_revenue

    FROM sellers s

    INNER JOIN order_items oi
        ON s.seller_id = oi.seller_id

    GROUP BY
        s.seller_state,
        s.seller_id
),

ranked_sellers AS (

    SELECT
        seller_state,

        seller_id,

        total_revenue,

        ROW_NUMBER() OVER (
            PARTITION BY seller_state
            ORDER BY total_revenue DESC
        ) AS seller_rank_within_state

    FROM seller_revenue
)

SELECT *

FROM ranked_sellers

WHERE seller_rank_within_state <= 3

ORDER BY
    seller_state,
    seller_rank_within_state;


-- Seller rankings restart independently within each state,
-- confirming correct PARTITION BY behavior.
--
-- Revenue concentration varies significantly across regions.
-- Bahia (BA) contains one highly dominant seller
-- generating substantially more revenue than other local sellers

-- ============================================================
-- 6. CUSTOMER BEHAVIOR ANALYSIS
-- ============================================================

-- What percentage of customers made repeat purchases?


WITH customer_orders AS (

    SELECT
        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders

    FROM customers c

    INNER JOIN orders o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,

    COUNT(
        CASE
            WHEN total_orders > 1 THEN 1
        END
    ) AS repeat_customers,

    ROUND(
        COUNT(
            CASE
                WHEN total_orders > 1 THEN 1
            END
        ) * 100.0
        /
        COUNT(*),
        2
    ) AS repeat_customer_percentage

FROM customer_orders;

-- The marketplace contains 96,096 unique customers,
-- but only 2,997 customers made repeat purchases.

-- The repeat customer rate is only 3.12%,
-- meaning nearly 97% of customers purchased only once

-- Which customers generate the highest lifetime value?


WITH customer_clv AS (

    SELECT
        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(SUM(op.payment_value), 2) AS customer_lifetime_value

    FROM customers c

    INNER JOIN orders o
        ON c.customer_id = o.customer_id

    INNER JOIN order_payments op
        ON o.order_id = op.order_id

    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,

    total_orders,

    customer_lifetime_value,

    RANK() OVER (
        ORDER BY customer_lifetime_value DESC
    ) AS customer_rank

FROM customer_clv

ORDER BY customer_lifetime_value DESC

LIMIT 20;

-- Several of the highest-value customers
-- made only a single purchase,
-- indicating that high customer spending
-- is not strongly associated with repeat purchasing behavior.
--
-- The top customer generated over 13K in lifetime value
-- from a single transaction.

-- ============================================================
-- COHORT RETENTION ANALYSIS
-- ============================================================

-- How well does the marketplace retain customers over time?


WITH first_purchase AS (

    SELECT
        c.customer_unique_id,

        MIN(
            DATE_TRUNC(
                'month',
                o.order_purchase_timestamp
            )
        ) AS cohort_month

    FROM customers c

    INNER JOIN orders o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_unique_id
),

customer_orders AS (

    SELECT
        c.customer_unique_id,

        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        ) AS order_month

    FROM customers c

    INNER JOIN orders o
        ON c.customer_id = o.customer_id
),

cohort_data AS (

    SELECT
        fp.cohort_month,

        co.order_month,

        COUNT(DISTINCT co.customer_unique_id) AS active_customers

    FROM first_purchase fp

    INNER JOIN customer_orders co
        ON fp.customer_unique_id = co.customer_unique_id

    GROUP BY
        fp.cohort_month,
        co.order_month
),

cohort_size AS (

    SELECT
        cohort_month,

        COUNT(DISTINCT customer_unique_id) AS cohort_customers

    FROM first_purchase

    GROUP BY cohort_month
)

SELECT
    cd.cohort_month,

    cd.order_month,

    cs.cohort_customers,

    cd.active_customers,

    ROUND(
        100.0 * cd.active_customers
        /
        cs.cohort_customers,
        2
    ) AS retention_percentage

FROM cohort_data cd

INNER JOIN cohort_size cs
    ON cd.cohort_month = cs.cohort_month

ORDER BY
    cd.cohort_month,
    cd.order_month;

-- Customer retention drops extremely rapidly
-- after the initial purchase month across nearly all cohorts.
--
-- Most cohorts retain fewer than 1% of customers
-- in subsequent months,
-- indicating severe long-term retention weakness.
--
-- These findings strongly align with the earlier
-- repeat customer analysis,
-- where only 3.12% of customers made repeat purchases.


-- ============================================================
-- 7. DELIVERY & OPERATIONAL ANALYSIS
-- ============================================================

-- How long does delivery typically take?

SELECT
    ROUND(
        AVG(
            EXTRACT(
                DAY FROM (
                    order_delivered_customer_date
                    -
                    order_purchase_timestamp
                )
            )
        ),
        2
    ) AS avg_delivery_days

FROM orders

WHERE order_delivered_customer_date IS NOT NULL;

-- Average delivery time is approximately 12 days,
-- indicating moderate logistics turnaround time
-- for marketplace orders.


-- How do late deliveries affect customer reviews?


WITH delivery_status AS (

    SELECT
        o.order_id,

        CASE
            WHEN order_delivered_customer_date
                 >
                 order_estimated_delivery_date
            THEN 'Late Delivery'

            ELSE 'On Time'
        END AS delivery_status

    FROM orders o

    WHERE order_delivered_customer_date IS NOT NULL
)

SELECT
    ds.delivery_status,

    ROUND(
        AVG(orv.review_score),
        2
    ) AS avg_review_score,

    COUNT(*) AS total_orders

FROM delivery_status ds

INNER JOIN order_reviews orv
    ON ds.order_id = orv.order_id

GROUP BY ds.delivery_status;

-- Late deliveries received an average review score of only 2.57,
-- compared to 4.29 for on-time deliveries.

-- Which completed orders never received customer reviews?

SELECT
    COUNT(DISTINCT o.order_id) AS orders_without_reviews

FROM orders o

LEFT JOIN order_reviews r
    ON o.order_id = r.order_id

WHERE r.order_id IS NULL;

-- Some completed orders never received customer reviews,
-- LEFT JOIN preserves unmatched rows from the orders table,
-- making it useful for identifying missing relationships.

-- Which sellers have the slowest average delivery times?


SELECT
    oi.seller_id,

    s.seller_state,

    ROUND(
        AVG(
            EXTRACT(
                DAY FROM (
                    o.order_delivered_customer_date
                    -
                    o.order_purchase_timestamp
                )
            )
        ),
        2
    ) AS avg_delivery_days,

    COUNT(*) AS total_orders

FROM order_items oi

INNER JOIN orders o
    ON oi.order_id = o.order_id

INNER JOIN sellers s
    ON oi.seller_id = s.seller_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY
    oi.seller_id,
    s.seller_state

HAVING COUNT(*) > 50

ORDER BY avg_delivery_days DESC

LIMIT 10;

-- Several sellers demonstrate significantly slower delivery performance,
-- with average delivery times exceeding 20 days.
--
-- One high-volume seller processed over 1,300 orders
-- while maintaining an average delivery time of nearly 22 days,
-- indicating potential operational bottlenecks at scale.
--
-- Sellers from SP and MG appear frequently among
-- the slowest delivery performers,
-- suggesting possible regional logistics inefficiencies


-- ============================================================
-- 8. PRODUCT & CATEGORY ANALYSIS
-- ============================================================

-- Which product categories generate
-- the highest marketplace revenue?


WITH category_revenue AS (

    SELECT
        p.product_category_name,

        ROUND(SUM(oi.price), 2) AS total_revenue

    FROM order_items oi

    INNER JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY p.product_category_name
)

SELECT
    product_category_name,

    total_revenue,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank

FROM category_revenue

ORDER BY total_revenue DESC

LIMIT 10;

-- Health & beauty, watches, and home furnishing categories
-- generated the highest marketplace revenue.
--
-- Revenue appears relatively diversified across categories,
-- with no single segment overwhelmingly dominating sales.


-- Do high-revenue product categories
-- maintain strong customer satisfaction?


SELECT
    p.product_category_name,

    ROUND(SUM(oi.price), 2) AS total_revenue,

    ROUND(
        AVG(orv.review_score),
        2
    ) AS avg_review_score

FROM order_items oi

INNER JOIN products p
    ON oi.product_id = p.product_id

INNER JOIN order_reviews orv
    ON oi.order_id = orv.order_id

GROUP BY p.product_category_name

HAVING SUM(oi.price) > 500000

ORDER BY total_revenue DESC;

-- Most high-revenue product categories maintain
-- strong customer satisfaction scores above 4.0,
-- indicating generally positive customer experiences.
--
-- However, large categories such as
-- bed/table/bath and furniture/decor
-- show slightly weaker review performance,
-- suggesting possible product quality
-- or delivery-related challenges.
--
-- Smaller categories such as "cool_stuff"
-- achieved some of the highest review scores,
-- demonstrating that strong customer satisfaction
-- is not solely dependent on sales volume.


-- ============================================================
-- SUMMARY
-- ============================================================

-- 1. Marketplace Revenue Growth
-- The marketplace generated approximately 16 million
-- in total revenue and experienced rapid growth
-- throughout 2017 and early 2018.
--
-- Revenue trends later stabilized above 1 million
-- per month, suggesting marketplace operational maturity.
--
--
-- 2. Severe Customer Retention Weakness
-- Only 3.12% of customers made repeat purchases.
--
-- Cohort retention analysis showed that
-- most customer groups retained fewer than 1%
-- of customers after the initial purchase month.
--
-- The marketplace appears highly dependent
-- on continuous new customer acquisition.
--
--
-- 3. Delivery Performance Strongly Impacts Satisfaction
-- Late deliveries received an average review score
-- of only 2.57 compared to 4.29 for on-time deliveries.
--
-- This demonstrates a strong relationship
-- between logistics performance and customer satisfaction.
--
--
-- 4. Operational Bottlenecks Exist Among Some Sellers
-- Several high-volume sellers demonstrated
-- average delivery times exceeding 20 days,
-- suggesting potential operational scalability issues.
--
--
-- 5. Product Revenue Is Well Diversified
-- Revenue distribution across product categories
-- appears relatively balanced,
-- reducing dependence on a single product segment.
--
-- ============================================================
-- BUSINESS RECOMMENDATIONS
-- ============================================================
-- 1. Improve Customer Retention Strategy
-- Introduce loyalty programs,
-- personalized promotions,
-- and post-purchase engagement campaigns
-- to improve repeat purchasing behavior.
--
--
-- 2. Optimize Delivery Operations
-- Prioritize faster logistics partnerships
-- and monitor high-delay sellers more aggressively
-- to improve customer satisfaction.
--
--
-- 3. Monitor Seller Operational Performance
-- Establish seller performance benchmarks
-- for delivery speed and customer satisfaction
-- to reduce operational bottlenecks.
--
--
-- 4. Focus on High-Satisfaction Categories
-- Expand and promote categories with both
-- strong revenue and strong review performance
-- to improve long-term customer trust.
