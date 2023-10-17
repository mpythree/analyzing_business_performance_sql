/*CREATE TABLE geolocation_dirty2 AS
SELECT geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, 
REPLACE(REPLACE(REPLACE(
TRANSLATE(TRANSLATE(TRANSLATE(TRANSLATE(
TRANSLATE(TRANSLATE(TRANSLATE(TRANSLATE(
    geolocation_city, '£,³,´,.', ''), '`', ''''), 
    'é,ê', 'e,e'), 'á,â,ã', 'a,a,a'), 'ô,ó,õ', 'o,o,o'),
	'ç', 'c'), 'ú,ü', 'u,u'), 'í', 'i'), 
	'4o', '4º'), '* ', ''), '%26apos%3b', ''''
) AS geolocation_city, geolocation_state
from geolocation_dirty gd;*/

CREATE TABLE geolocation AS
WITH geolocation AS (
	SELECT geolocation_zip_code_prefix,
	geolocation_lat, 
	geolocation_lng, 
	geolocation_city, 
	geolocation_state FROM (
		SELECT *,
			ROW_NUMBER() OVER (
				PARTITION BY geolocation_zip_code_prefix
			) AS ROW_NUMBER
		FROM geolocation_dirty2 
	) TEMP
	WHERE ROW_NUMBER = 1
),
custgeo AS (
	SELECT customer_zip_code_prefix, geolocation_lat, 
	geolocation_lng, customer_city, customer_state 
	FROM (
		SELECT *,
			ROW_NUMBER() OVER (
				PARTITION BY customer_zip_code_prefix
			) AS ROW_NUMBER
		FROM (
			SELECT customer_zip_code_prefix, geolocation_lat, 
			geolocation_lng, customer_city, customer_state
			FROM customers cd 
			LEFT JOIN geolocation_dirty gdd 
			ON customer_city = geolocation_city
			AND customer_state = geolocation_state
			WHERE customer_zip_code_prefix NOT IN (
				SELECT geolocation_zip_code_prefix
				FROM geolocation gd 
			)
		) geo
	) TEMP
	WHERE ROW_NUMBER = 1
),
sellgeo AS (
	SELECT seller_zip_code_prefix, geolocation_lat, 
	geolocation_lng, seller_city, seller_state 
	FROM (
		SELECT *,
			ROW_NUMBER() OVER (
				PARTITION BY seller_zip_code_prefix
			) AS ROW_NUMBER
		FROM (
			SELECT seller_zip_code_prefix, geolocation_lat, 
			geolocation_lng, seller_city, seller_state
			FROM sellers cd 
			LEFT JOIN geolocation_dirty gdd 
			ON seller_city = geolocation_city
			AND seller_state = geolocation_state
			WHERE seller_zip_code_prefix NOT IN (
				SELECT geolocation_zip_code_prefix
				FROM geolocation gd 
				UNION
				SELECT customer_zip_code_prefix
				FROM custgeo cd 
			)
		) geo
	) TEMP
	WHERE ROW_NUMBER = 1
)
SELECT * 
FROM geolocation
UNION
SELECT * 
FROM custgeo
UNION
SELECT * 
FROM sellgeo;