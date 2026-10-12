-- Task 3.2: Find the Bug
-- Part A: The rows that vanished

-- The broekn query using inequality != on a nullable column
SELECT COUNT(*) AS broken_count
FROM bookings
WHERE cancellation_reason != 'Passenger no show';

-- The count of what is dropped 
-- Rows that were dropped because cancellation_reason is NULL
SELECT COUNT(*) AS missing_null_count
FROM bookings
WHERE cancellation_reason IS NULL;

-- Rows with 'Passenger no show'
SELECT COUNT(*) AS target_count
FROM bookings
WHERE cancellation_reason = 'Passenger no show';

-- Total rows in bookings table to show the math does not add up
SELECT COUNT(*) AS total_count
FROM bookings;

-- Repaired query: Fix by including NULL rows
SELECT COUNT(*) AS repaired_count
FROM bookings
WHERE cancellation_reason != 'Passenger no show'
   OR cancellation_reason IS NULL;

-- Part B: The alias that did not exist yet

-- Broken query referencing a SELECT alias in WHERE
SELECT booking_id,
       fare_paid,
       fare_multiplier,
       ROUND(fare_paid * fare_multiplier, 2) AS total_fare
FROM bookings
WHERE total_fare > 30.00;

-- Repeating the expression in WHERE
SELECT booking_id,
       fare_paid,
       fare_multiplier,
       ROUND(fare_paid * fare_multiplier, 2) AS total_fare
FROM bookings
WHERE ROUND(fare_paid * fare_multiplier, 2) > 30.00;

-- Using a CTE for alias
WITH calculated_bookings AS (
    SELECT booking_id,
           fare_paid,
           fare_multiplier,
           ROUND(fare_paid * fare_multiplier, 2) AS total_fare
    FROM bookings
)
SELECT booking_id,
       fare_paid,
       fare_multiplier,
       total_fare
FROM calculated_bookings
WHERE total_fare > 30.00;
