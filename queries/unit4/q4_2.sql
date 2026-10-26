-- =============================================================================
-- EX603 - Project Assignment 4: From Rows to Insight
-- Task 4.1: Measure the platform
-- Dataset: airline.sql 
-- =============================================================================

-------------------------------------------------------------------
-- Task 4.2.1: Single-Pass Conditional Aggregation
-- What is the total volume, cancellation count, cancellation rate (failure rate %), 
-- and completed revenue for each flight (producer) computed in a single table pass?
-- -----------------------------------------------------------------------------
SELECT 
    flight_id AS producer_id,
    COUNT(*) AS total_bookings,
    COUNT(CASE WHEN booking_status = 'cancelled' THEN 1 END) AS cancelled_bookings,
    ROUND(
        100.0 * COUNT(CASE WHEN booking_status = 'cancelled' THEN 1 END) / COUNT(*), 
        2
    ) AS failure_rate_pct,
    ROUND(SUM(CASE WHEN booking_status != 'cancelled' THEN fare_paid ELSE 0 END), 2) AS net_revenue
FROM bookings
GROUP BY flight_id
ORDER BY total_bookings DESC, producer_id ASC;


-- -----------------------------------------------------------------------------
-- Task 4.2.2: Hierarchical Aggregation with ROLLUP
-- What are the booking volumes and revenues grouped hierarchically by flight (producer) 
-- and region (booking country), including subtotals for each flight and the platform grand total?
-- -----------------------------------------------------------------------------
SELECT 
    flight_id AS producer_id,
    booking_country AS region,
    COUNT(*) AS event_count,
    ROUND(SUM(fare_paid), 2) AS total_revenue,
    ROUND(AVG(fare_paid), 2) AS average_fare
FROM bookings
GROUP BY ROLLUP(flight_id, booking_country)
ORDER BY flight_id ASC NULLS LAST, booking_country ASC NULLS LAST;


-- -----------------------------------------------------------------------------
-- Task 4.2.3: CTE Analysis Pipeline (Pipeline Comparing Producers to Baseline)
-- How does each flight's performance (booking count, net revenue, average fare) 
-- compare against the platform-wide averages to identify high-performing or anomalous flights?
-- -----------------------------------------------------------------------------
WITH flight_metrics AS (
    SELECT 
        flight_id,
        COUNT(*) AS booking_count,
        ROUND(SUM(fare_paid), 2) AS flight_revenue,
        ROUND(AVG(fare_paid), 2) AS flight_avg_fare,
        ROUND(
            100.0 * COUNT(CASE WHEN booking_status = 'cancelled' THEN 1 END) / COUNT(*), 
            2
        ) AS cancellation_rate
    FROM bookings
    GROUP BY flight_id
),
platform_baseline AS (
    SELECT 
        ROUND(AVG(booking_count), 2) AS avg_bookings_per_flight,
        ROUND(AVG(flight_revenue), 2) AS avg_revenue_per_flight
    FROM flight_metrics
)
SELECT 
    f.flight_id,
    f.booking_count,
    p.avg_bookings_per_flight,
    f.flight_revenue,
    p.avg_revenue_per_flight,
    ROUND(f.flight_revenue - p.avg_revenue_per_flight, 2) AS revenue_variance_from_avg,
    f.cancellation_rate
FROM flight_metrics f
CROSS JOIN platform_baseline p
ORDER BY f.flight_revenue DESC;
