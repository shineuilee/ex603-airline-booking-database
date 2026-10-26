-- =============================================================================
-- EX603 - Project Assignment 4: From Rows to Insight
-- Task 4.1: Measure the platform
-- Dataset: airline.sql 
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Task 4.1.1: Platform-wide Baseline Statistics
-- What are the baseline metrics (total count, sum, average, min, max fare paid, 
-- and unique passengers) across all booking events on the platform?
-- -----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_booking_count,
    SUM(fare_paid) AS total_revenue,
    ROUND(AVG(fare_paid), 2) AS average_fare,
    MIN(fare_paid) AS min_fare,
    MAX(fare_paid) AS max_fare,
    COUNT(DISTINCT passenger_id) AS distinct_passengers
FROM bookings;


-- -----------------------------------------------------------------------------
-- Task 4.1.2: Per-Producer Activity and Performance
-- How do booking volume and average fare paid vary across individual flights (producers),
-- ordered from highest activity to lowest?
-- -----------------------------------------------------------------------------
SELECT 
    flight_id AS producer_id,
    COUNT(*) AS event_count,
    ROUND(AVG(fare_paid), 2) AS average_fare
FROM bookings
GROUP BY flight_id
ORDER BY event_count DESC, producer_id ASC;


-- -----------------------------------------------------------------------------
-- Task 4.1.3: Volume Filtering with HAVING
-- Which flights (producers) have enough volume (at least 15 bookings) 
-- for their average metrics to be statistically representative?
-- -----------------------------------------------------------------------------
SELECT 
    flight_id AS producer_id,
    COUNT(*) AS event_count,
    ROUND(AVG(fare_paid), 2) AS average_fare
FROM bookings
GROUP BY flight_id
HAVING COUNT(*) >= 15
ORDER BY event_count DESC, producer_id ASC;


-- -----------------------------------------------------------------------------
-- Task 4.1.4: Multi-dimensional Grouping (Producer and Region)
-- How does booking volume and average fare vary across both producer (flight) 
-- and geographic region (booking_country)?
-- -----------------------------------------------------------------------------
SELECT 
    flight_id AS producer_id,
    booking_country AS region,
    COUNT(*) AS event_count,
    ROUND(AVG(fare_paid), 2) AS average_fare
FROM bookings
GROUP BY flight_id, booking_country
ORDER BY producer_id ASC, region ASC;
