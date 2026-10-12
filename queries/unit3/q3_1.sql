** Task 3.1: Establish What the Data Contains**

// 3.1 a: Finding active flights with seat capacity >= 180
// showing top 10 rows
SELECT flight_id, flight_number, origin_country, seat_capacity, is_active
FROM flights
WHERE is_active = TRUE
  AND seat_capacity >= 180
ORDER BY seat_capacity DESC
LIMIT 10;

// 3.1 b: Check all unique booking statuses in bookings table
SELECT DISTINCT booking_status
FROM bookings
ORDER BY booking_status;

// 3.1 c
// Part 1: Filter fare between 20 and 40
SELECT booking_id, passenger_id, flight_id, fare_paid, booking_status
FROM bookings
WHERE fare_paid BETWEEN 20.00 AND 40.00
ORDER BY fare_paid DESC
LIMIT 10;

// Part 2: Filter country with Kore or Japan using IN
SELECT booking_id, passenger_id, flight_id, booking_country, booking_status
FROM bookings
WHERE booking_country IN ('Korea', 'Japan')
ORDER BY booking_id ASC
LIMIT 10;

// 3.1 d
// Part 1: Flight number starting with VN20 using LIKE
SELECT flight_id, flight_number, origin_country, tail_number
FROM flights
WHERE flight_number LIKE 'VN20%'
ORDER BY flight_number;

// Part 2: Replace NULL in cancellation reason with default text
SELECT booking_id, flight_id, booking_status,
       COALESCE(cancellation_reason, 'No reason provided') AS cancellation_reason_clean
FROM bookings
ORDER BY booking_id ASC
LIMIT 15;

// 3.1 e: Calculate total fare and add simple price groups using CASE
SELECT booking_id,
       flight_id,
       fare_paid,
       fare_multiplier,
       ROUND(fare_paid * fare_multiplier, 2) AS total_fare,
       CASE 
           WHEN fare_paid >= 30.00 THEN 'High Fare'
           WHEN fare_paid >= 15.00 THEN 'Medium Fare'
           ELSE 'Low Fare'
       END AS price_group,
       booking_status
FROM bookings
ORDER BY total_fare DESC
LIMIT 15;
