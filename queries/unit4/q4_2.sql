-- =============================================================================
-- EX603 - Project Assignment 4: From Rows to Insight
-- Task 4.1: Measure the platform
-- Dataset: airline.sql 
-- =============================================================================

-- Task 4.2 Part A: How many bookings and no-shows per flight?
-- Both counts come from one grouped query with CASE.
SELECT
	flight_id,
	COUNT(*) AS total_bookings,
	SUM(CASE
		WHEN cancellation_reason = 'Passenger no show' THEN 1
		ELSE 0
	END) AS no_shows,
	ROUND(100.0 * SUM(CASE
		WHEN cancellation_reason = 'Passenger no show' THEN 1
		ELSE 0
	END) / COUNT(*), 2) AS no_show_rate
FROM bookings
GROUP BY flight_id
ORDER BY no_shows DESC, no_show_rate DESC, flight_id;

-- Task 4.2 Part B: What are regional totals and all-region total?
-- No flight detail rows; ROLLUP makes the country and grand totals.
SELECT
	CASE
		WHEN GROUPING(booking_country) = 1 THEN 'All regions'
		ELSE booking_country
	END AS region,
	CASE
		WHEN GROUPING(booking_country) = 1 THEN 'Grand total'
		ELSE 'Regional subtotal'
	END AS row_type,
	COUNT(*) AS total_bookings,
	SUM(CASE
		WHEN cancellation_reason = 'Passenger no show' THEN 1
		ELSE 0
	END) AS no_shows,
	ROUND(100.0 * SUM(CASE
		WHEN cancellation_reason = 'Passenger no show' THEN 1
		ELSE 0
	END) / COUNT(*), 2) AS no_show_rate
FROM bookings
GROUP BY ROLLUP (booking_country)
ORDER BY GROUPING(booking_country), booking_country;

-- Task 4.2 Part C: What is the no-show rate for busy flights?
-- Step 1 groups by flight. Step 2 keeps flights with 10+ bookings.
WITH flight_summary AS (
	SELECT
		flight_id,
		COUNT(*) AS booking_count,
		SUM(CASE
			WHEN cancellation_reason = 'Passenger no show' THEN 1
			ELSE 0
		END) AS no_shows
	FROM bookings
	GROUP BY flight_id
)
SELECT
	COUNT(*) AS flight_count,
	SUM(booking_count) AS total_bookings,
	SUM(no_shows) AS total_no_shows,
	ROUND(100.0 * SUM(no_shows) /
		NULLIF(SUM(booking_count), 0), 2) AS baseline_rate
FROM flight_summary
WHERE booking_count >= 10;
