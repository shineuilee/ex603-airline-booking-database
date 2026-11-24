-- -----------------------------------------------------------------------------
-- Task 6.3 Part A: Top three bookings per flight
-- Which three bookings have the highest fares
-- for each flight?
--
-- Tie policy:
-- ROW_NUMBER returns at most three bookings per flight
-- to maintain a consistent dashboard display size.
-- If fares are tied at third place, the booking with
-- the lower booking_id is prioritized, and additional
-- tied bookings are excluded to maintain the limit.
-- This provides a deterministic result.
-- -----------------------------------------------------------------------------

WITH ranked_bookings AS (
    SELECT
        b.booking_id,
        b.flight_id,
        f.flight_number,
        b.booked_at,
        b.fare_paid,

        ROW_NUMBER() OVER (
            PARTITION BY b.flight_id
            ORDER BY b.fare_paid DESC, b.booking_id
        ) AS fare_rank,

        FIRST_VALUE(b.fare_paid) OVER (
            PARTITION BY b.flight_id
            ORDER BY b.fare_paid DESC, b.booking_id
        ) AS highest_fare

    FROM bookings b
    INNER JOIN flights f
        ON b.flight_id = f.flight_id
)
SELECT
    flight_id,
    flight_number,
    booking_id,
    booked_at,
    fare_paid,
    fare_rank,
    highest_fare,
    highest_fare - fare_paid AS difference_from_top
FROM ranked_bookings
WHERE fare_rank <= 3
ORDER BY flight_id, fare_rank;

-- -----------------------------------------------------------------------------
-- Task 6.3 Part B: Month-over-month comparison
-- How does monthly booking volume and recorded
-- fare change compared with the previous month?
-- A calendar series prevents skipped months.
-- -----------------------------------------------------------------------------

WITH calendar_months AS (
    SELECT
        GENERATE_SERIES(
            DATE_TRUNC('month', MIN(booked_at)),
            DATE_TRUNC('month', MAX(booked_at)),
            INTERVAL '1 month'
        ) AS booking_month
    FROM bookings
),
monthly_bookings AS (
    SELECT
        DATE_TRUNC('month', booked_at)
            AS booking_month,
        COUNT(*) AS booking_count,
        SUM(fare_paid) AS total_fare
    FROM bookings
    GROUP BY DATE_TRUNC('month', booked_at)
),
complete_months AS (
    SELECT
        c.booking_month,

        COALESCE(m.booking_count, 0)
            AS booking_count,

        COALESCE(m.total_fare, 0)
            AS total_fare,

        m.booking_month IS NULL
            AS missing_month_flag

    FROM calendar_months c
    LEFT JOIN monthly_bookings m
        ON c.booking_month = m.booking_month
),
monthly_comparison AS (
    SELECT
        booking_month,
        booking_count,
        total_fare,
        missing_month_flag,

        LAG(booking_count) OVER (
            ORDER BY booking_month
        ) AS previous_booking_count,

        LAG(total_fare) OVER (
            ORDER BY booking_month
        ) AS previous_total_fare

    FROM complete_months
)
SELECT
    booking_month,
    booking_count,
    previous_booking_count,

    ROUND(
        100.0 * (
            booking_count - previous_booking_count
        ) / NULLIF(previous_booking_count, 0),
        2
    ) AS booking_pct_change,

    total_fare,
    previous_total_fare,

    ROUND(
        100.0 * (
            total_fare - previous_total_fare
        ) / NULLIF(previous_total_fare, 0),
        2
    ) AS fare_pct_change,

    missing_month_flag

FROM monthly_comparison
ORDER BY booking_month;

-- -----------------------------------------------------------------------------
-- Task 6.3 Part B: Supporting Analysis 1
-- Monthly No-show Rate
-- Is the passenger no-show rate improving
-- or worsening over time?
-- -----------------------------------------------------------------------------

WITH calendar_months AS (
    SELECT
        GENERATE_SERIES(
            DATE_TRUNC('month', MIN(booked_at)),
            DATE_TRUNC('month', MAX(booked_at)),
            INTERVAL '1 month'
        ) AS booking_month
    FROM bookings
),
monthly_failures AS (
    SELECT
        DATE_TRUNC('month', booked_at)
            AS booking_month,

        COUNT(*) AS total_bookings,

        COUNT(*) FILTER (
            WHERE cancellation_reason =
                  'Passenger no show'
        ) AS no_show_count

    FROM bookings
    GROUP BY DATE_TRUNC('month', booked_at)
),
monthly_rates AS (
    SELECT
        c.booking_month,

        COALESCE(m.total_bookings, 0)
            AS total_bookings,

        COALESCE(m.no_show_count, 0)
            AS no_show_count,

        100.0 * COALESCE(m.no_show_count, 0)
            / NULLIF(m.total_bookings, 0)
            AS no_show_rate

    FROM calendar_months c
    LEFT JOIN monthly_failures m
        ON c.booking_month = m.booking_month
),
rate_comparison AS (
    SELECT
        booking_month,
        total_bookings,
        no_show_count,
        no_show_rate,

        LAG(no_show_rate) OVER (
            ORDER BY booking_month
        ) AS previous_no_show_rate

    FROM monthly_rates
)
SELECT
    booking_month,
    total_bookings,
    no_show_count,
    ROUND(no_show_rate, 2) AS no_show_rate,
    ROUND(previous_no_show_rate, 2)
        AS previous_no_show_rate,
    ROUND(
        no_show_rate - previous_no_show_rate,
        2
    ) AS change_percentage_points
FROM rate_comparison
ORDER BY booking_month;

-- -----------------------------------------------------------------------------
-- Task 6.3 Part B: Supporting Analysis 2
-- Quarterly No-show Rate
-- How does the no-show rate change across quarters?
-- Does the no-show rate show a clearer trend
-- when bookings are grouped by quarter?
-- -----------------------------------------------------------------------------

WITH quarterly_failures AS (
    SELECT
        DATE_TRUNC('quarter', booked_at)
            AS booking_quarter,

        COUNT(*) AS total_bookings,

        COUNT(*) FILTER (
            WHERE cancellation_reason =
                  'Passenger no show'
        ) AS no_show_count

    FROM bookings
    GROUP BY DATE_TRUNC('quarter', booked_at)
),
quarterly_rates AS (
    SELECT
        booking_quarter,
        total_bookings,
        no_show_count,

        100.0 * no_show_count
            / NULLIF(total_bookings, 0)
            AS no_show_rate

    FROM quarterly_failures
),
rate_comparison AS (
    SELECT
        booking_quarter,
        total_bookings,
        no_show_count,
        no_show_rate,

        LAG(no_show_rate) OVER (
            ORDER BY booking_quarter
        ) AS previous_no_show_rate

    FROM quarterly_rates
)
SELECT
    booking_quarter,
    total_bookings,
    no_show_count,
    ROUND(no_show_rate, 2) AS no_show_rate,
    ROUND(previous_no_show_rate, 2)
        AS previous_no_show_rate,
    ROUND(
        no_show_rate - previous_no_show_rate,
        2
    ) AS change_percentage_points
FROM rate_comparison
ORDER BY booking_quarter;

-- -----------------------------------------------------------------------------
-- Task 6.3 Part B: Supporting Analysis 3
-- Data Coverage and Limitations
-- What is the available data coverage?
-- Is there sufficient evidence to establish
-- a sustained improvement in the no-show rate?
-- This analysis supports the Task 6.4 closing memo.
-- -----------------------------------------------------------------------------

SELECT
    MIN(booked_at) AS first_booking,
    MAX(booked_at) AS last_booking,
    COUNT(*) AS total_bookings
FROM bookings;

