-- -----------------------------------------------------------------------------
-- Task 5.2.Part A-1: LEFT JOIN
-- How many bookings does each flight have, including flights with no bookings?
-- LEFT JOIN keeps every flight, even if there is no matching booking.
-- -----------------------------------------------------------------------------
 
SELECT
	f.flight_id,
	f.flight_number,
	f.is_active,
	COUNT(b.booking_id) AS booking_count
FROM flights f
LEFT JOIN bookings b
	ON f.flight_id = b.flight_id
GROUP BY f.flight_id, f.flight_number, f.is_active
ORDER BY f.flight_id;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part A-2: INNER JOIN
-- How many bookings does each flight have, using INNER JOIN?
-- INNER JOIN only keeps flights that have at least one booking.
-- -----------------------------------------------------------------------------
 
SELECT
	f.flight_id,
	f.flight_number,
	f.is_active,
	COUNT(b.booking_id) AS booking_count
FROM flights f
INNER JOIN bookings b
	ON f.flight_id = b.flight_id
GROUP BY f.flight_id, f.flight_number, f.is_active
ORDER BY f.flight_id;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part A-3: Count of flights excluded by the INNER JOIN
-- How many flights appear in the LEFT JOIN but not in the INNER JOIN?
-- COUNT(DISTINCT) is used so that flights with many bookings are counted once.
-- -----------------------------------------------------------------------------
 
SELECT
	(SELECT COUNT(DISTINCT f.flight_id)
	 FROM flights f
	 LEFT JOIN bookings b ON f.flight_id = b.flight_id) AS left_join_flights,
	(SELECT COUNT(DISTINCT f.flight_id)
	 FROM flights f
	 INNER JOIN bookings b ON f.flight_id = b.flight_id) AS inner_join_flights,
	(SELECT COUNT(DISTINCT f.flight_id)
	 FROM flights f
	 LEFT JOIN bookings b ON f.flight_id = b.flight_id)
	-
	(SELECT COUNT(DISTINCT f.flight_id)
	 FROM flights f
	 INNER JOIN bookings b ON f.flight_id = b.flight_id) AS excluded_flights;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part A-4: Which flights were excluded by the INNER JOIN?
-- These are the flights with no matching booking, so the booking columns
-- are NULL after the LEFT JOIN.
-- -----------------------------------------------------------------------------
 
SELECT
	f.flight_id,
	f.flight_number,
	f.origin_country,
	f.seat_capacity,
	f.is_active
FROM flights f
LEFT JOIN bookings b
	ON f.flight_id = b.flight_id
WHERE b.booking_id IS NULL
ORDER BY f.flight_id;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part B-1: RIGHT JOIN
-- Can a RIGHT JOIN return the same result as the LEFT JOIN in Part A-1?
-- The table order is switched, so flights is now on the right side.
-- -----------------------------------------------------------------------------
 
SELECT
	f.flight_id,
	f.flight_number,
	f.is_active,
	COUNT(b.booking_id) AS booking_count
FROM bookings b
RIGHT JOIN flights f
	ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number, f.is_active
ORDER BY f.flight_id;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part B-2: Check that the LEFT JOIN and RIGHT JOIN results match
-- Do the two results have the same rows? EXCEPT is run in both directions.
-- If both "only_in" counts are 0, the results are the same.
-- -----------------------------------------------------------------------------
 
WITH left_result AS (
	SELECT f.flight_id, COUNT(b.booking_id) AS booking_count
	FROM flights f
	LEFT JOIN bookings b ON f.flight_id = b.flight_id
	GROUP BY f.flight_id
),
right_result AS (
	SELECT f.flight_id, COUNT(b.booking_id) AS booking_count
	FROM bookings b
	RIGHT JOIN flights f ON b.flight_id = f.flight_id
	GROUP BY f.flight_id
)
SELECT
	(SELECT COUNT(*) FROM left_result)  AS left_rows,
	(SELECT COUNT(*) FROM right_result) AS right_rows,
	(SELECT COUNT(*) FROM (
		SELECT * FROM left_result
		EXCEPT
		SELECT * FROM right_result) x)  AS only_in_left,
	(SELECT COUNT(*) FROM (
		SELECT * FROM right_result
		EXCEPT
		SELECT * FROM left_result) y)   AS only_in_right;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part B-3: FULL OUTER JOIN
-- Are there unmatched records on either side of the relationship?
-- Each row is labeled as matched, flight without bookings,
-- or booking without a flight, and then counted.
-- -----------------------------------------------------------------------------
 
SELECT
	CASE
		WHEN f.flight_id IS NOT NULL AND b.booking_id IS NOT NULL THEN 'Matched'
		WHEN b.booking_id IS NULL THEN 'Flight without bookings'
		ELSE 'Booking without a flight'
	END AS match_type,
	COUNT(*) AS row_count,
	COUNT(DISTINCT f.flight_id) AS flight_count
FROM flights f
FULL OUTER JOIN bookings b
	ON f.flight_id = b.flight_id
GROUP BY 1
ORDER BY 1;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part C-1: NOT EXISTS
-- Which flights have never had a booking?
-- For each flight, NOT EXISTS checks that no booking has the same flight_id.
-- -----------------------------------------------------------------------------
 
SELECT
	f.flight_id,
	f.flight_number,
	f.is_active
FROM flights f
WHERE NOT EXISTS (
	SELECT 1
	FROM bookings b
	WHERE b.flight_id = f.flight_id
)
ORDER BY f.flight_id;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part C-2: EXCEPT
-- Which flights have never had a booking?
-- EXCEPT removes every flight_id found in bookings from the list of all flights.
-- -----------------------------------------------------------------------------
 
SELECT flight_id
FROM flights
EXCEPT
SELECT flight_id
FROM bookings
ORDER BY flight_id;
 
-- -----------------------------------------------------------------------------
-- Task 5.2.Part C-3: Check that NOT EXISTS and EXCEPT find the same flights
-- Do both methods return the same flight IDs?
-- If both "only_in" counts are 0, the two methods give the same result.
-- -----------------------------------------------------------------------------
 
WITH not_exists_result AS (
	SELECT f.flight_id
	FROM flights f
	WHERE NOT EXISTS (
		SELECT 1 FROM bookings b WHERE b.flight_id = f.flight_id
	)
),
except_result AS (
	SELECT flight_id FROM flights
	EXCEPT
	SELECT flight_id FROM bookings
)
SELECT
	(SELECT COUNT(*) FROM not_exists_result) AS not_exists_rows,
	(SELECT COUNT(*) FROM except_result)     AS except_rows,
	(SELECT COUNT(*) FROM (
		SELECT * FROM not_exists_result
		EXCEPT
		SELECT * FROM except_result) x)      AS only_in_not_exists,
	(SELECT COUNT(*) FROM (
		SELECT * FROM except_result
		EXCEPT
		SELECT * FROM not_exists_result) y)  AS only_in_except;
