-- -----------------------------------------------------------------------------
-- Task 6.1 Q1: Window average
-- How does each booking's fare compare to
-- the average fare of its flight?
-- ---------------------------------------------------------------------
SELECT
    booking_id,
    flight_id,
    fare_paid,
    ROUND(
        AVG(fare_paid) OVER (
            PARTITION BY flight_id
        ), 2
    ) AS flight_avg_fare,
    ROUND(
        fare_paid - AVG(fare_paid) OVER (
            PARTITION BY flight_id
        ), 2
    ) AS fare_difference
FROM bookings
ORDER BY flight_id, booking_id;

-- -----------------------------------------------------------------------------
-- Task 6.1 Q1: GROUP BY comparison
-- What is the average fare for each flight
-- when individual booking rows are collapsed?
-- -----------------------------------------------------------------------------
SELECT
    flight_id,
    COUNT(*) AS booking_count,
    ROUND(AVG(fare_paid), 2) AS flight_avg_fare
FROM bookings
GROUP BY flight_id
ORDER BY flight_id;

-- -----------------------------------------------------------------------------
-- Task 6.1 Q1: Row count validation
-- How many rows are preserved by each method?
-- -----------------------------------------------------------------------------

SELECT
    (
        SELECT COUNT(*)
        FROM bookings
    ) AS window_rows,
    (
        SELECT COUNT(*)
        FROM (
            SELECT flight_id
            FROM bookings
            GROUP BY flight_id
        ) AS grouped_flights
    ) AS group_by_rows;

-- -----------------------------------------------------------------------------
-- Task 6.1 Q2: Rank flights three ways
-- How does tie handling affect the flight
-- leaderboard based on booking volume?
-- -----------------------------------------------------------------------------

WITH flight_counts AS (
    SELECT
        f.flight_id,
        f.flight_number,
        COUNT(b.booking_id) AS booking_count
    FROM flights f
    LEFT JOIN bookings b
        ON f.flight_id = b.flight_id
    GROUP BY
        f.flight_id,
        f.flight_number
)
SELECT
    flight_id,
    flight_number,
    booking_count,

    ROW_NUMBER() OVER (
        ORDER BY booking_count DESC, flight_id
    ) AS row_number_rank,

    RANK() OVER (
        ORDER BY booking_count DESC
    ) AS rank_position,

    DENSE_RANK() OVER (
        ORDER BY booking_count DESC
    ) AS dense_rank_position

FROM flight_counts
ORDER BY booking_count DESC, flight_id;

-- -----------------------------------------------------------------------------
-- Task 6.1 Q3: Divide flights into four bands
-- How are flights grouped into four performance
-- bands based on booking volume?
-- -----------------------------------------------------------------------------

WITH flight_counts AS (
    SELECT
        f.flight_id,
        f.flight_number,
        COUNT(b.booking_id) AS booking_count
    FROM flights f
    LEFT JOIN bookings b
        ON f.flight_id = b.flight_id
    GROUP BY
        f.flight_id,
        f.flight_number
)
SELECT
    flight_id,
    flight_number,
    booking_count,

    NTILE(4) OVER (
        ORDER BY booking_count DESC, flight_id
    ) AS performance_band

FROM flight_counts
ORDER BY booking_count DESC, flight_id;

-- -----------------------------------------------------------------------------
-- Task 6.1 Q3: Verify tied flights
-- Are flights with identical booking counts
-- assigned to different performance bands?
-- -----------------------------------------------------------------------------
WITH flight_counts AS (
    SELECT
        f.flight_id,
        COUNT(b.booking_id) AS booking_count
    FROM flights f
    LEFT JOIN bookings b
        ON f.flight_id = b.flight_id
    GROUP BY f.flight_id
),
banded_flights AS (
    SELECT
        flight_id,
        booking_count,
        NTILE(4) OVER (
            ORDER BY booking_count DESC, flight_id
        ) AS performance_band
    FROM flight_counts
)
SELECT
    booking_count,
    COUNT(*) AS tied_flights,
    MIN(performance_band) AS lowest_band,
    MAX(performance_band) AS highest_band
FROM banded_flights
GROUP BY booking_count
HAVING COUNT(DISTINCT performance_band) > 1;
