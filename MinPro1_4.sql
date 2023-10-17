-- Masukkan tabel yang berisi informasi jumlah penggunaan masing-masing tipe pembayaran untuk setiap tahun

-- Favorite payment of all time

SELECT
	payment_type,
	COUNT(payment_type) amount
FROM order_payments op 
GROUP BY 1

-- Favorite payment by year

WITH fav AS (
	SELECT
		DATE_PART('YEAR', o.order_purchase_timestamp) "year",
		op.payment_type,
		COUNT(op.payment_type) amount
	FROM order_payments op
	JOIN orders o ON op.order_id = o.order_id 
	GROUP BY 1,2
	ORDER BY 1 )

SELECT *,
	CASE WHEN year_2017 = 0 THEN NULL
		ELSE ROUND((year_2018 - year_2017) / year_2017, 2)
	END AS pct_change_2017_2018
FROM (
SELECT 
  payment_type,
  SUM(CASE WHEN "year" = 2016 THEN amount ELSE 0 END) AS year_2016,
  SUM(CASE WHEN "year" = 2017 THEN amount ELSE 0 END) AS year_2017,
  SUM(CASE WHEN "year" = 2018 THEN amount ELSE 0 END) AS year_2018
FROM fav 
GROUP BY 1) subq
ORDER BY 5 DESC

	