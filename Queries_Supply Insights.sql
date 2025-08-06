CREATE DATABASE supply_insights; 
USE supply_insights; 

CREATE TABLE dates (
    dates DATE,
    mmm_yy DATE, 
    month_name VARCHAR(50),
    week_no VARCHAR(50));
    
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50));

CREATE TABLE products (
	product_name VARCHAR(50),
	product_id INT PRIMARY KEY,
    category VARCHAR(50));

CREATE TABLE targets_orders (
    customer_id INT,
    ontime_target INT,
    ifull_target INT,
    otif_target INT,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id));

CREATE TABLE order_lines (
    order_id VARCHAR(50),
    order_date DATE,
    customer_id INT,
    product_id INT,
    ordered_quantity INT,
    agreed_delivery_date DATE,
    actual_delivery_date DATE,
    delivery_quantity INT, 
    is_on_time INT,
    is_in_full INT,
    is_on_time_in_full INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id));

CREATE TABLE orders_aggregate (
    order_id INT,
    customer_id INT,
    order_date DATE,
    is_on_time INT,
    is_in_full INT,
    is_on_time_in_full INT);

LOAD DATA LOCAL INFILE 'C:\\Users\\91620\\Documents\\Summer docs\\Projects\\Supply Insights Dataset\\date.csv'
INTO TABLE dates
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\91620\\Documents\\Summer docs\\Projects\\Supply Insights Dataset\\customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\91620\\Documents\\Summer docs\\Projects\\Supply Insights Dataset\\products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\91620\\Documents\\Summer docs\\Projects\\Supply Insights Dataset\\target_orders.csv'
INTO TABLE targets_orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\91620\\Documents\\Summer docs\\Projects\\Supply Insights Dataset\\order_lines.csv'
INTO TABLE order_lines
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\91620\\Documents\\Summer docs\\Projects\\Supply Insights Dataset\\orders_aggregate.csv'
INTO TABLE orders_aggregate 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM dates; 
SELECT * FROM customers; 
SELECT * FROM products; 
SELECT * FROM targets_orders; 
SELECT * FROM order_lines; 
SELECT * FROM orders_aggregate;

#1 OT, IF and OTIF per customer 
SELECT
    customers.customer_name,
    COUNT(order_lines.order_id) AS total_orders,
    SUM(order_lines.is_on_time) AS on_time_orders,
    SUM(order_lines.is_in_full) AS in_full_orders,
    SUM(order_lines.is_on_time_in_full) AS on_time_in_full_orders,

    ROUND(SUM(order_lines.is_on_time) * 100.0 / COUNT(order_lines.order_id), 2) AS on_time_percent,
    ROUND(SUM(order_lines.is_in_full) * 100.0 / COUNT(order_lines.order_id), 2) AS in_full_percent,
    ROUND(SUM(order_lines.is_on_time_in_full) * 100.0 / COUNT(order_lines.order_id), 2) AS otif_percent
FROM
    order_lines
JOIN customers ON order_lines.customer_id = customers.customer_id
GROUP BY
    customers.customer_name
ORDER BY
    customers.customer_name;

#2 OTIF percentage 
SELECT
    order_lines.customer_id,
    SUM(order_lines.is_on_time_in_full),
    ROUND(SUM(order_lines.is_on_time_in_full) * 100.0 / COUNT(order_lines.order_id), 2) AS actual_otif_percent,
    targets_orders.otif_target
FROM
    order_lines
JOIN
    targets_orders ON order_lines.customer_id = targets_orders.customer_id
GROUP BY
    order_lines.customer_id, targets_orders.otif_target
ORDER BY
    actual_otif_percent ASC; 

#3 Comparision of taregted OTIF and actual OTIF 
SELECT
    customers.customer_name,
    order_lines.customer_id, 
    ROUND(SUM(order_lines.is_on_time_in_full) * 100.0 / COUNT(order_lines.order_id), 2) AS actual_otif_percent,
    targets_orders.otif_target
FROM
    order_lines
JOIN
    targets_orders ON order_lines.customer_id = targets_orders.customer_id
JOIN
    customers ON order_lines.customer_id = customers.customer_id
GROUP BY
    order_lines.customer_id, customers.customer_name, targets_orders.otif_target
HAVING
    actual_otif_percent < 40 
ORDER BY
    actual_otif_percent ASC;
    
#4 Product level OTIF analysis 
SELECT
    products.product_name,
    SUM(order_lines.is_on_time) * 100.0 / COUNT(order_lines.order_id) AS ot_percent,
    SUM(order_lines.is_in_full) * 100.0 / COUNT(order_lines.order_id) AS if_percent,
    SUM(order_lines.is_on_time_in_full) * 100.0 / COUNT(order_lines.order_id) AS otif_percent
FROM
    order_lines
JOIN
    products ON order_lines.product_id = products.product_id
GROUP BY
    products.product_name
ORDER BY
    otif_percent;

#5 City-wise OTIF percentage 
SELECT
    customers.city,
    ROUND(SUM(order_lines.is_on_time_in_full) * 100.0 / COUNT(order_lines.order_id), 2) AS otif_percent
FROM
    order_lines
JOIN
    customers ON order_lines.customer_id = customers.customer_id
GROUP BY
   city
ORDER BY
    otif_percent;

#6 Lowest OTIF products 
SELECT
    products.product_name,
    COUNT(order_lines.order_id) AS total_orders,
    SUM(is_on_time_in_full) AS otif_orders,
    ROUND(SUM(is_on_time_in_full) * 100.0 / COUNT(order_lines.order_id), 2) AS otif_percent
FROM
    order_lines 
JOIN
    products ON order_lines.product_id = products.product_id
GROUP BY
    products.product_name
ORDER BY
    otif_percent ASC
    LIMIT 5; 
    
    



    






