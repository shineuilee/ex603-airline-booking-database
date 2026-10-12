-- Task 3.3: Hand the team a corrected query

-- Subquery using IN
SELECT passenger_id, passenger_name, email
FROM passengers
WHERE passenger_id IN (
    SELECT passenger_id
    FROM bookings
    WHERE booking_status = 'disputed'
)
ORDER BY passenger_id ASC;

-- Common Table Expression (CTE) using WITH
WITH disputed_actors AS (
    SELECT DISTINCT passenger_id
    FROM bookings
    WHERE booking_status = 'disputed'
)
SELECT p.passenger_id, p.passenger_name, p.email
FROM passengers p
JOIN disputed_actors da
  ON p.passenger_id = da.passenger_id
ORDER BY p.passenger_id ASC;

-- Correlated Subquery using EXISTS
SELECT p.passenger_id, p.passenger_name, p.email
FROM passengers p
WHERE EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.passenger_id = p.passenger_id
      AND b.booking_status = 'disputed'
)
ORDER BY p.passenger_id ASC;
