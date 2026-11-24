-- -----------------------------------------------------------------------------
-- Task 6.2 Part A: Row-to-row comparison
-- How does each booking fare change compared
-- with the previous and next booking for the same flight?
-- -----------------------------------------------------------------------------

WITH fare_comparison AS (
    SELECT
        booking_id,
        flight_id,
        booked_at,
        fare_paid,

        LAG(fare_paid) OVER (
            PARTITION BY flight_id
            ORDER BY booked_at, booking_id
        ) AS previous_fare,

        LEAD(fare_paid) OVER (
            PARTITION BY flight_id
            ORDER BY booked_at, booking_id
        ) AS next_fare

    FROM bookings
)
SELECT
    booking_id,
    flight_id,
    booked_at,
    previous_fare,
    fare_paid AS current_fare,
    next_fare,
    fare_paid - previous_fare AS fare_delta
FROM fare_comparison
WHERE flight_id = 1
ORDER BY booked_at, booking_id;

-- -----------------------------------------------------------------------------
-- Task 6.2 Part B: Running total and moving average
-- How does the cumulative booked fare change
-- over time, and how close is it to an
-- illustrative target of 50,000?
-- The moving average uses the latest seven bookings.
-- -----------------------------------------------------------------------------

WITH fare_trends AS (
    SELECT
        booking_id,
        flight_id,
        booked_at,
        fare_paid,

        SUM(fare_paid) OVER (
            ORDER BY booked_at, booking_id
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS running_total,

        ROUND(
            AVG(fare_paid) OVER (
                ORDER BY booked_at, booking_id
                ROWS BETWEEN 6 PRECEDING
                         AND CURRENT ROW
            ), 2
        ) AS moving_avg_7

    FROM bookings
)
SELECT
    booking_id,
    flight_id,
    booked_at,
    fare_paid,
    running_total,
    moving_avg_7,
    50000 AS fare_target,
    ROUND(
        100.0 * running_total / 50000,
        2
    ) AS target_progress_pct,
    50000 - running_total AS remaining_to_target
FROM fare_trends
ORDER BY booked_at, booking_id;

-- -----------------------------------------------------------------------------
-- Task 6.2 Part C: Detect booking gaps
-- Which flights have gaps of at least 30 days
-- between consecutive recorded bookings?
-- -----------------------------------------------------------------------------

WITH booking_sequence AS (
    SELECT
        booking_id,
        flight_id,
        booked_at,

        LAG(booked_at) OVER (
            PARTITION BY flight_id
            ORDER BY booked_at, booking_id
        ) AS previous_booking

    FROM bookings
),
booking_gaps AS (
    SELECT
        booking_id,
        flight_id,
        previous_booking,
        booked_at AS current_booking,
        booked_at - previous_booking AS booking_gap
    FROM booking_sequence
)
SELECT
    booking_id,
    flight_id,
    previous_booking,
    current_booking,
    booking_gap,
    ROUND(
        EXTRACT(EPOCH FROM booking_gap) / 86400,
        2
    ) AS gap_days
FROM booking_gaps
WHERE booking_gap >= INTERVAL '30 days'
ORDER BY booking_gap DESC, flight_id;
