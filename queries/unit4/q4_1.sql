-- =============================================================================
-- EX603 - Project Assignment 4: From Rows to Insight
-- Task 4.1: Measure the platform
-- Dataset: airline.sql 
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Task 4.1.Q1: What are the fare summary numbers for all bookings?
-- What are the baseline metrics (total count, sum, average, min, max fare paid, 
-- and unique passengers) across all booking events on the platform?
-- -----------------------------------------------------------------------------

SELECT
	COUNT(*) AS total_bookings,
	COUNT(fare_paid) AS fare_count,
	SUM(fare_paid) AS total_fare,
	ROUND(AVG(fare_paid), 2) AS average_fare,
	MIN(fare_paid) AS min_fare,
	MAX(fare_paid) AS max_fare,
	COUNT(DISTINCT passenger_id) AS passenger_count
FROM bookings;

-- -----------------------------------------------------------------------------
-- Task 4.1.Q2: How many bookings and average fare for each flight?
-- How do booking volume and average fare paid vary across individual flights (producers),
-- ordered from highest activity to lowest?
-- -----------------------------------------------------------------------------

SELECT
	flight_id,
	COUNT(*) AS booking_count,
	ROUND(AVG(fare_paid), 2) AS average_fare
FROM bookings
GROUP BY flight_id
ORDER BY booking_count DESC, flight_id;

-- -----------------------------------------------------------------------------
-- Task 4.1.Q3: Which flights have at least 10 bookings?
-- Which flights (producers) have enough volume (compare only flights with 10 or more bookings) 
-- for their average metrics to be statistically representative?
-- -----------------------------------------------------------------------------

SELECT
	flight_id,
	COUNT(*) AS booking_count,
	ROUND(AVG(fare_paid), 2) AS average_fare,
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
HAVING COUNT(*) >= 10
ORDER BY booking_count DESC, flight_id;

-- -----------------------------------------------------------------------------
-- Task 4.1.Q4: How do bookings differ by flight and country? (Producer and Region)
-- How does booking volume and average fare vary across both producer (flight) 
-- and geographic region (booking_country)?
-- -----------------------------------------------------------------------------

SELECT
	flight_id,
	booking_country AS region,
	COUNT(*) AS booking_count,
	ROUND(AVG(fare_paid), 2) AS average_fare,
	SUM(CASE
		WHEN cancellation_reason = 'Passenger no show' THEN 1
		ELSE 0
	END) AS no_shows
FROM bookings
GROUP BY flight_id, booking_country
ORDER BY flight_id, booking_country;
