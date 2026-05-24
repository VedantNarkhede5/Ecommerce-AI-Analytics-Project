CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

SELECT COUNT(*) AS total_rows FROM superstore;

SELECT * FROM superstore LIMIT 10;

SELECT COUNT(*) AS total_orders
FROM superstore;

SELECT ROUND(SUM(sales), 2) AS total_revenue
FROM superstore;

SELECT
    ROUND(AVG(sales), 2) AS avg_sales,
    ROUND(MIN(sales), 2) AS min_sales,
    ROUND(MAX(sales), 2) AS max_sales
FROM superstore;

SELECT DISTINCT category
FROM superstore;

SELECT order_id, customer_name, region, sales
FROM superstore
WHERE region = 'West'
LIMIT 10;

SELECT
    category,
    ROUND(SUM(sales), 2)  AS total_sales,
    COUNT(*)              AS total_orders
FROM superstore
GROUP BY category
ORDER BY total_sales DESC;

SELECT
    order_year,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*)             AS total_orders
FROM superstore
GROUP BY order_year
ORDER BY order_year ASC;

SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*)             AS total_orders
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;

SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*)             AS times_ordered
FROM superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

SELECT
    ship_mode,
    COUNT(*)             AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales
FROM superstore
GROUP BY ship_mode
ORDER BY total_orders DESC;

SELECT COUNT(*) AS orders_in_2018
FROM superstore
WHERE order_year = 2018;

SELECT
    `Category`,
    ROUND(SUM(`Sales`), 2) AS total_sales
FROM superstore
GROUP BY `Category`
HAVING SUM(`Sales`) > 700000
ORDER BY total_sales DESC;
 
 SELECT
    `Region`,
    `Category`,
    ROUND(SUM(`Sales`), 2) AS total_sales
FROM superstore
GROUP BY `Region`, `Category`
ORDER BY `Region`, total_sales DESC;

SELECT
    `Order ID`,
    `Customer Name`,
    `Sales`,
    CASE
        WHEN `Sales` < 50 THEN 'Small Order'
        WHEN `Sales` < 500 THEN 'Medium Order'
        WHEN `Sales` < 2000 THEN 'Large Order'
        ELSE 'Very Large Order'
    END AS order_size
FROM superstore
LIMIT 20;

SELECT
    CASE
        WHEN `Sales` < 50 THEN 'Small Order'
        WHEN `Sales` < 500 THEN 'Medium Order'
        WHEN `Sales` < 2000 THEN 'Large Order'
        ELSE 'Very Large Order'
    END AS order_size,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Sales`), 2) AS total_sales
FROM superstore
GROUP BY order_size
ORDER BY total_sales DESC;

SELECT
    `Customer Name`,
    ROUND(SUM(`Sales`), 2) AS total_sales
FROM superstore
GROUP BY `Customer Name`
HAVING SUM(`Sales`) > (
    SELECT AVG(`Customer Total Sales`)
    FROM superstore
)
ORDER BY total_sales DESC;

SELECT
    category,
    product_name,
    total_sales
FROM (
    SELECT
        `Category` AS category,
        `Product Name` AS product_name,
        ROUND(SUM(`Sales`), 2) AS total_sales,
        RANK() OVER (
            PARTITION BY `Category`
            ORDER BY SUM(`Sales`) DESC
        ) AS rnk
    FROM superstore
    GROUP BY `Category`, `Product Name`
) ranked
WHERE rnk = 1;

SELECT
    `Ship Mode`,
    ROUND(AVG(`Days to Ship`), 2) AS avg_days_to_ship,
    MIN(`Days to Ship`) AS min_days,
    MAX(`Days to Ship`) AS max_days
FROM superstore
GROUP BY `Ship Mode`
ORDER BY avg_days_to_ship ASC;

SELECT
    `Order Month`,
    ROUND(SUM(`Sales`), 2) AS monthly_sales,
    COUNT(*) AS total_orders
FROM superstore
WHERE `Order Year` = 2018
GROUP BY `Order Month`
ORDER BY `Order Month` ASC;

SELECT
    `Order Month`,
    COUNT(*) AS total_orders
FROM superstore
GROUP BY `Order Month`
ORDER BY total_orders DESC
LIMIT 5;

SELECT
    `Season`,
    ROUND(SUM(`Sales`), 2) AS total_sales,
    COUNT(*) AS total_orders
FROM superstore
GROUP BY `Season`
ORDER BY total_sales DESC;

SELECT
    CASE
        WHEN `Is Weekend` = 1 THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Sales`), 2) AS total_sales,
    ROUND(AVG(`Sales`), 2) AS avg_sales
FROM superstore
GROUP BY day_type;

SELECT
    `State`,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Sales`), 2) AS total_sales
FROM superstore
GROUP BY `State`
ORDER BY total_orders DESC
LIMIT 10;

SELECT
    `Sub-Category`,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Sales`), 2) AS total_sales,
    ROUND(AVG(`Sales`), 2) AS avg_sales
FROM superstore
GROUP BY `Sub-Category`
ORDER BY total_sales DESC;


WITH customer_sales AS (
    SELECT
        `Region`,
        `Customer Name`,
        ROUND(SUM(`Sales`), 2) AS total_sales,

        RANK() OVER (
            PARTITION BY `Region`
            ORDER BY SUM(`Sales`) DESC
        ) AS sales_rank

    FROM superstore
    GROUP BY `Region`, `Customer Name`
)

SELECT
    `Region`,
    `Customer Name`,
    total_sales,
    sales_rank
FROM customer_sales
WHERE sales_rank <= 5
ORDER BY `Region`, sales_rank;


SELECT
    `Order Date`,
    ROUND(`Sales`, 2) AS daily_sales,

    ROUND(
        SUM(`Sales`) OVER (
            ORDER BY `Order Date`
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ),
    2) AS running_total

FROM superstore
ORDER BY `Order Date`
LIMIT 30;

SELECT
    `Segment`,
    `Customer Name`,

    ROUND(SUM(`Sales`), 2) AS total_sales,

    RANK() OVER (
        PARTITION BY `Segment`
        ORDER BY SUM(`Sales`) DESC
    ) AS rank_in_segment,

    DENSE_RANK() OVER (
        PARTITION BY `Segment`
        ORDER BY SUM(`Sales`) DESC
    ) AS dense_rank_in_segment

FROM superstore
GROUP BY `Segment`, `Customer Name`
ORDER BY `Segment`, rank_in_segment
LIMIT 20;

SELECT
    `Category`,

    ROUND(SUM(
        CASE
            WHEN `Order Year` = 2015
            THEN `Sales`
            ELSE 0
        END
    ), 2) AS sales_2015,

    ROUND(SUM(
        CASE
            WHEN `Order Year` = 2016
            THEN `Sales`
            ELSE 0
        END
    ), 2) AS sales_2016,

    ROUND(SUM(
        CASE
            WHEN `Order Year` = 2017
            THEN `Sales`
            ELSE 0
        END
    ), 2) AS sales_2017,

    ROUND(SUM(
        CASE
            WHEN `Order Year` = 2018
            THEN `Sales`
            ELSE 0
        END
    ), 2) AS sales_2018,

    ROUND(SUM(`Sales`), 2) AS total_sales

FROM superstore
GROUP BY `Category`
ORDER BY total_sales DESC;

SELECT
    `Order ID`,
    COUNT(*) AS row_count

FROM superstore

GROUP BY `Order ID`

HAVING COUNT(*) > 1

ORDER BY row_count DESC
LIMIT 10;