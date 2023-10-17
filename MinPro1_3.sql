-- SubTask 1 revenue per tahun

SELECT 
	EXTRACT(YEAR FROM order_purchase_timestamp) "year",
	SUM(value) revenue
FROM (
	SELECT 
		order_id,
		SUM(price+freight_value) value
	FROM order_items
	GROUP BY 1 ) sub1
JOIN orders o ON o.order_id = sub1.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1

-- SubTask 2 jumlah cancel order per tahun

SELECT
	DATE_PART('YEAR', order_purchase_timestamp) "year",
	SUM(1) mnt_canceled
FROM orders
WHERE order_status = 'canceled'
GROUP BY 1

-- SubTask 3 top kategori yang menghasilkan revenue terbesar per tahun

SELECT
	top."year",
	product_category_name,
	revenue
FROM (
	SELECT
		DATE_PART('YEAR', o.order_purchase_timestamp) "year",
		p.product_category_name,
		SUM(oi.price + oi.freight_value) revenue,
		ROW_NUMBER() OVER (PARTITION BY DATE_PART('YEAR', o.order_purchase_timestamp)
			ORDER BY SUM(oi.price + oi.freight_value) DESC ) "rank"
	FROM order_items oi
	JOIN orders o ON oi.order_id = o.order_id 
	JOIN products p ON oi.product_id = p.product_id
	GROUP BY 1,2 ) top
WHERE "rank" = 1

-- SubTask 4 kategori yang mengalami cancel order terbanyak per tahun

SELECT
	ccl."year",
	product_category_name,
	mnt_cancel
FROM (
	SELECT
		DATE_PART('YEAR', o.order_purchase_timestamp) "year",
		p.product_category_name,
		SUM(1) mnt_cancel,
		ROW_NUMBER () OVER (PARTITION BY DATE_PART('YEAR', o.order_purchase_timestamp)
				ORDER BY SUM(1) DESC)  "rank"
	FROM order_items oi 
	JOIN orders o ON oi.order_id = o.order_id 
	JOIN products p ON oi.product_id = p.product_id 
	WHERE o.order_status = 'canceled'
	GROUP BY 1,2 ) ccl
WHERE "rank" = 1

-- Finishing combining all tables

WITH st1 AS (
SELECT 
	EXTRACT(YEAR FROM order_purchase_timestamp) "year",
	SUM(value) revenue
FROM (
	SELECT 
		order_id,
		SUM(price+freight_value) value
	FROM order_items
	GROUP BY 1 ) sub1
JOIN orders o ON o.order_id = sub1.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1),

st2 AS (
SELECT
	DATE_PART('YEAR', order_purchase_timestamp) "year",
	SUM(1) mnt_canceled
FROM orders
WHERE order_status = 'canceled'
GROUP BY 1),

st3 AS (
SELECT
	top."year",
	product_category_name,
	revenue
FROM (
	SELECT
		DATE_PART('YEAR', o.order_purchase_timestamp) "year",
		p.product_category_name,
		SUM(oi.price + oi.freight_value) revenue,
		ROW_NUMBER() OVER (PARTITION BY DATE_PART('YEAR', o.order_purchase_timestamp)
			ORDER BY SUM(oi.price + oi.freight_value) DESC ) "rank"
	FROM order_items oi
	JOIN orders o ON oi.order_id = o.order_id 
	JOIN products p ON oi.product_id = p.product_id
	GROUP BY 1,2 ) top
WHERE "rank" = 1),

st4 AS (
SELECT
	ccl."year",
	product_category_name,
	mnt_cancel
FROM (
	SELECT
		DATE_PART('YEAR', o.order_purchase_timestamp) "year",
		p.product_category_name,
		SUM(1) mnt_cancel,
		ROW_NUMBER () OVER (PARTITION BY DATE_PART('YEAR', o.order_purchase_timestamp)
				ORDER BY SUM(1) DESC)  "rank"
	FROM order_items oi 
	JOIN orders o ON oi.order_id = o.order_id 
	JOIN products p ON oi.product_id = p.product_id 
	WHERE o.order_status = 'canceled'
	GROUP BY 1,2 ) ccl
WHERE "rank" = 1)

SELECT
	s1."year",
	s1.revenue yearly_revenue,
	s3.product_category_name top_revenue_category,
	s3.revenue top_category_revenue,
	s2.mnt_canceled mnt_yearly_cancel,
	s4.product_category_name top_cancel_category,
	s4.mnt_cancel category_mnt_cancel
FROM st1 s1
JOIN st2 s2 ON s1."year" = s2."year"
JOIN st3 s3 ON s1."year" = s3."year"
JOIN st4 s4 ON s1."year" = s4."year"

