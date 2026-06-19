
CREATE TABLE superstore_clean AS
SELECT
CAST("Row ID" AS INT) AS row_id,
"Order ID" AS order_id,
TO_DATE("Order Date",'MM/DD/YYYY') AS order_date,
TO_DATE("Ship Date",'MM/DD/YYYY') AS ship_date,
"Ship Mode" AS ship_mode,
"Customer ID" AS customer_id,
"Customer Name" AS customer_name,
"Segment" AS segment,
"Country/Region" AS country_region,
"City" AS city,
"State/Province" AS state_province,
"Postal Code" AS postal_code,
"Region" AS region,
"Product ID" AS product_id,
"Category" AS category,
"Sub-Category" AS sub_category,
"Product Name" AS product_name,
CAST("Sales" AS NUMERIC) AS sales,
CAST("Quantity" AS INT) AS quantity,
CAST("Discount" AS NUMERIC) AS discount,
CAST("Profit" AS NUMERIC) AS profit
FROM superstore;

-- TOTAL REVENUE 
SELECT ROUND(SUM(sales),2) AS total_revenue
FROM superstore_clean;

-- TOTAL PROFIT
SELECT ROUND(SUM(profit),2) AS total_profit
FROM superstore_clean;

-- TOTAL ORDERS
SELECT COUNT(DISTINCT order_id)
FROM superstore_clean;

-- TOTAL CUSTOMERS 
SELECT COUNT(DISTINCT customer_id)
FROM superstore_clean;

-- AVERAGE ORDER VALUE 
SELECT
ROUND(
SUM(sales) /
COUNT(DISTINCT order_id),2
) AS avg_order_value
FROM superstore_clean;

-- TOP 10 PRODUCTS BY REVENUE 	
SELECT
product_name,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 10;

-- TOP 10 PRODUCTS BY PROFIT
SELECT
product_name,
SUM(profit) AS total_profit
FROM superstore_clean
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;

-- LOSS MAKING PRODUCTS
SELECT
product_name,
SUM(profit) AS total_profit
FROM superstore_clean
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit;

-- SALES BY CATEGORY 
SELECT
category,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY category
ORDER BY revenue DESC;

-- PROFIT BY CATEGORY 
SELECT
category,
SUM(profit) AS profit
FROM superstore_clean
GROUP BY category
ORDER BY profit DESC;

-- SALES BY SUB CATEGORY 
SELECT
sub_category,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY sub_category
ORDER BY revenue DESC;

-- TOP 10 CUSTOMERS BY REVENUE 
SELECT
customer_name,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY customer_name
ORDER BY revenue DESC
LIMIT 10;

-- TOP 10 CUSTOMERS BY PROFIT
SELECT
customer_name,
SUM(profit) AS profit
FROM superstore_clean
GROUP BY customer_name
ORDER BY profit DESC
LIMIT 10;

-- CUSTOMER LIFE TIME VALUE 
SELECT
customer_name,
SUM(sales) AS customer_lifetime_value
FROM superstore_clean
GROUP BY customer_name
ORDER BY customer_lifetime_value DESC;

-- CUSTOMERS GENERATING LOSSES
SELECT
customer_name,
SUM(profit) AS total_profit
FROM superstore_clean
GROUP BY customer_name
HAVING SUM(profit) < 0
ORDER BY total_profit;

-- REPEAT CUSTOMERS 
SELECT
customer_name,
COUNT(DISTINCT order_id) AS total_orders
FROM superstore_clean
GROUP BY customer_name
HAVING COUNT(DISTINCT order_id) > 5
ORDER BY total_orders DESC;

-- REVENUE BY REGION 
SELECT
region,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY region
ORDER BY revenue DESC;

-- PROFIT BY REGION 
SELECT
region,
SUM(profit) AS profit
FROM superstore_clean
GROUP BY region
ORDER BY profit DESC;

-- TOP 10 STATES BY REVENUE 
SELECT
state_province,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY state_province
ORDER BY revenue DESC
LIMIT 10;

-- TOP 10 STATES BY PROFIT
SELECT
state_province,
SUM(profit) AS profit
FROM superstore_clean
GROUP BY state_province
ORDER BY profit DESC
LIMIT 10;

-- STATES GENERATING LOSSES
SELECT
state_province,
SUM(profit) AS profit
FROM superstore_clean
GROUP BY state_province
HAVING SUM(profit) < 0
ORDER BY profit;

-- AVERAGE PROFIT BY DISCOUNT 
SELECT
discount,
ROUND(AVG(profit),2) AS avg_profit
FROM superstore_clean
GROUP BY discount
ORDER BY discount;

-- TOTAL REVENUE BY DISCOUNT 
SELECT
discount,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY discount
ORDER BY discount;

-- DISCOUNT RANGE ANALYSIS
SELECT
CASE
WHEN discount = 0 THEN 'No Discount'
WHEN discount <= 0.10 THEN '0-10%'
WHEN discount <= 0.20 THEN '11-20%'
WHEN discount <= 0.30 THEN '21-30%'
ELSE 'Above 30%'
END AS discount_range,

SUM(sales) AS revenue,
SUM(profit) AS profit

FROM superstore_clean

GROUP BY discount_range
ORDER BY revenue DESC;

-- MONTHLY REVENUE TREND  
SELECT
DATE_TRUNC('month', order_date) AS month,
ROUND(SUM(sales),2) AS revenue
FROM superstore_clean
GROUP BY month
ORDER BY month;

-- MONTHLY PROFIT TREND
SELECT
DATE_TRUNC('month', order_date) AS month,
ROUND(SUM(profit),2) AS profit
FROM superstore_clean
GROUP BY month
ORDER BY month;

-- MONTHLY ORDERS TREND
SELECT
DATE_TRUNC('month', order_date) AS month,
COUNT(DISTINCT order_id) AS orders
FROM superstore_clean
GROUP BY month
ORDER BY month;

-- BEST REVENUE MONTH
SELECT
DATE_TRUNC('month', order_date) AS month,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY month
ORDER BY revenue DESC
LIMIT 1;

-- WORST REVENUE MONTH
SELECT
DATE_TRUNC('month', order_date) AS month,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY month
ORDER BY revenue
LIMIT 1;

-- RANK CUSTOMERS BY REVENUE 
SELECT
customer_name,
SUM(sales) AS revenue,
RANK() OVER(
ORDER BY SUM(sales) DESC
) AS customer_rank
FROM superstore_clean
GROUP BY customer_name;

-- DENSE RANK CUSTOMERS
SELECT
customer_name,
SUM(sales) AS revenue,
DENSE_RANK() OVER(
ORDER BY SUM(sales) DESC
) AS dense_rank
FROM superstore_clean
GROUP BY customer_name;

-- TOP PRODUCT IN EACH CATEGORY 
WITH ranked_products AS
(
SELECT
category,
product_name,
SUM(sales) AS revenue,

ROW_NUMBER() OVER(
PARTITION BY category
ORDER BY SUM(sales) DESC
) AS rn

FROM superstore_clean

GROUP BY category, product_name
)

SELECT *
FROM ranked_products
WHERE rn = 1;

-- RUNNING REVENUE
WITH monthly_sales AS
(
SELECT
DATE_TRUNC('month', order_date) AS month,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY month
)

SELECT
month,
revenue,

SUM(revenue) OVER(
ORDER BY month
) AS running_revenue

FROM monthly_sales;

-- REVENUE CONTRIBUTION
SELECT
category,

ROUND(
SUM(sales) * 100
/
SUM(SUM(sales)) OVER(),
2
) AS revenue_percentage

FROM superstore_clean

GROUP BY category;

-- CUSTOMERS ABOVE AVERAGE REVENUE
WITH customer_sales AS
(
SELECT
customer_name,
SUM(sales) AS revenue
FROM superstore_clean
GROUP BY customer_name
)

SELECT *
FROM customer_sales

WHERE revenue >
(
SELECT AVG(revenue)
FROM customer_sales
)

ORDER BY revenue DESC;

-- PRODUCTD ABOVE AVERAGE PROFIT
WITH product_profit AS
(
SELECT
product_name,
SUM(profit) AS profit
FROM superstore_clean
GROUP BY product_name
)

SELECT *
FROM product_profit

WHERE profit >
(
SELECT AVG(profit)
FROM product_profit
)

ORDER BY profit DESC;

-- HIGH REVENUE LOW PROFIT PRODUCTS 
SELECT
product_name,
SUM(sales) AS revenue,
SUM(profit) AS profit
FROM superstore_clean
GROUP BY product_name
HAVING SUM(sales) > 10000
AND SUM(profit) < 100
ORDER BY revenue DESC;

-- CATEGORIES WITH HIGHEST PROFIT MARGIN
SELECT
category,

ROUND(
SUM(profit) * 100 /
SUM(sales),
2
) AS profit_margin

FROM superstore_clean

GROUP BY category
ORDER BY profit_margin DESC;

-- MOST FREQUENTLY ORDERED PRODUCTS
SELECT
product_name,
COUNT(DISTINCT order_id) AS order_frequency
FROM superstore_clean
GROUP BY product_name
ORDER BY order_frequency DESC
LIMIT 20;

