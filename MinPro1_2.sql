-- Subtask 1 Rata-rata Monthly Active User (MAU) per tahun
WITH st1 AS (
SELECT
	EXTRACT (YEAR FROM order_purchase_timestamp) "year",
	EXTRACT (MONTH FROM order_purchase_timestamp) "month",
	COUNT(c.customer_unique_id) mau
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1,2)

SELECT
	"year",
	ROUND(AVG(mau), 2) average_mau
FROM st1
GROUP BY 1

-- Subtask 2 total customer baru per tahun
WITH st2 AS (
SELECT 
	customer_unique_id,
	MIN(EXTRACT(YEAR FROM order_purchase_timestamp))
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1 )

SELECT
	"min" "year",
	COUNT(customer_unique_id) new_customer
FROM st2
GROUP BY 1
ORDER BY 1

-- Subtask 3 jumlah customer yang melakukan repeat order per tahun
WITH st3 AS (
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp) "year",
	customer_unique_id,
	COUNT(1) freq
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING COUNT(1) > 1)

SELECT
	"year",
	COUNT(customer_unique_id) repeat_order
FROM st3
GROUP BY 1

-- SubTask 4 rata-rata frekuensi order untuk setiap tahun.
WITH st4 AS (
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp) "year",
	c.customer_unique_id, 
	COUNT(o.order_id)
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1,2)

SELECT
	"year",
	ROUND(AVG("count"), 3) avg_order
FROM st4
GROUP BY 1
	

-- Combining all tables with CTE
WITH mau_tab AS (
WITH st1 AS (
SELECT
	EXTRACT (YEAR FROM order_purchase_timestamp) "year",
	EXTRACT (MONTH FROM order_purchase_timestamp) "month",
	COUNT(c.customer_unique_id) mau
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1,2)

SELECT
	"year",
	ROUND(AVG(mau), 2) average_mau
FROM st1
GROUP BY 1),

new_tab AS (
WITH st2 AS (
SELECT 
	customer_unique_id,
	MIN(EXTRACT(YEAR FROM order_purchase_timestamp))
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1 )

SELECT
	"min" "year",
	COUNT(customer_unique_id) new_customer
FROM st2
GROUP BY 1
ORDER BY 1),

rep_tab AS (
WITH st3 AS (
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp) "year",
	customer_unique_id,
	COUNT(1) freq
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING COUNT(1) > 1)

SELECT
	"year",
	COUNT(customer_unique_id) repeat_order
FROM st3
GROUP BY 1),

avgfreq_tab AS (
WITH st4 AS (
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp) "year",
	c.customer_unique_id, 
	COUNT(o.order_id)
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1,2)

SELECT
	"year",
	ROUND(AVG("count"), 3) avg_order
FROM st4
GROUP BY 1)

SELECT
	mt."year",
	average_mau,
	new_customer,
	repeat_order,
	avg_order
FROM mau_tab mt
JOIN new_tab nt ON mt."year" = nt."year"
JOIN rep_tab rt ON mt."year" = rt."year"
JOIN avgfreq_tab aft ON mt."year" = aft."year"

