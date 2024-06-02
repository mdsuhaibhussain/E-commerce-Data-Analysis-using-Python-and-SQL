-- Creating an ecommerce table 
create table ecommerce (
		order_id int primary key,
        order_date date,
        ship_mode varchar(20),
        segment varchar(20),
        country varchar(20),
        city varchar(20),
        state varchar(20),
        postal_code varchar(20),
        region varchar(20),
        category varchar(20),
        sub_category varchar(20),
        product_id varchar(50),
        quantity int,
        discount decimal(7,2),
        sale_price decimal(7,2),
        profit decimal(7,2));
    
    
    
-- find top 10 highest reveue generating products 
SELECT product_id, SUM(sale_price) AS sales 
FROM ecommerce 
GROUP BY product_id 
ORDER BY sales DESC 
LIMIT 10;



-- find top 5 highest selling products in each region
SELECT region, product_id, total_sales
FROM (
    SELECT region, product_id, SUM(sale_price) as total_sales,
    RANK() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) as sales_rank
    FROM ecommerce
    GROUP BY region, product_id
) as sales_ranks
WHERE sales_rank <= 5;



-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
SELECT year(order_date) AS order_year, MONTH(order_date) AS order_month,
SUM(sale_price) AS sales
FROM ecommerce
GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month
, SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022
, SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte 
GROUP BY order_month
ORDER BY order_month;



-- for each category which month had highest sales
 WITH cte AS (
SELECT category, FORMAT(order_date,'yyyyMM') AS order_year_month
, SUM(sale_price) AS sales 
FROM ecommerce
GROUP BY category, FORMAT(order_date,'yyyyMM')
)
SELECT * FROM(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
FROM cte
) a
WHERE rn=1;



-- which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year, 
        SUM(sale_price) AS sales
    FROM 
        ecommerce
    GROUP BY 
        sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM 
        cte 
    GROUP BY 
        sub_category
)
SELECT 
    *,
    (sales_2023 - sales_2022) AS sales_difference
FROM 
    cte2
ORDER BY 
    sales_difference DESC
LIMIT 1;

