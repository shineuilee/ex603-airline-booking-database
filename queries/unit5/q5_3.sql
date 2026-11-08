-- -----------------------------------------------------------------------------
-- Task 5.3.Part A-1: CROSS JOIN
-- What does every possible combination of airport and flight look like?
-- CROSS JOIN pairs every airport with every flight, without any join condition.
-- -----------------------------------------------------------------------------
 
SELECT
	a.iata_code,
	f.flight_id,
	f.flight_number
FROM airports a
CROSS JOIN flights f
ORDER BY a.iata_code, f.flight_id;
 
-- -----------------------------------------------------------------------------
-- Task 5.3.Part A-2: Row counts for the CROSS JOIN
-- How many rows does each source table have, and does the CROSS JOIN
-- result equal the two counts multiplied together?
-- -----------------------------------------------------------------------------
 
SELECT
	(SELECT COUNT(*) FROM airports) AS airport_rows,
	(SELECT COUNT(*) FROM flights)  AS flight_rows,
	(SELECT COUNT(*) FROM airports)
		* (SELECT COUNT(*) FROM flights) AS expected_rows,
	(SELECT COUNT(*)
	 FROM airports a
	 CROSS JOIN flights f)          AS cross_join_rows;
 
-- -----------------------------------------------------------------------------
-- Task 5.3.Part B-1: EXPLAIN for the three-table join from Task 5.1.Q1
-- How does PostgreSQL plan to run the join of bookings, passengers, and flights?
-- EXPLAIN only shows the plan. It does not run the query.
-- -----------------------------------------------------------------------------
 
EXPLAIN
SELECT
	b.booking_id,
	p.passenger_name,
	f.flight_number,
	b.booked_at,
	b.booking_status,
	b.cancellation_reason
FROM bookings b
INNER JOIN passengers p
	ON b.passenger_id = p.passenger_id
INNER JOIN flights f
	ON b.flight_id = f.flight_id
ORDER BY b.booked_at, b.booking_id;
 
-- -----------------------------------------------------------------------------
-- Task 5.3.Part B-2: EXPLAIN ANALYZE for the same query
-- How long does the query actually take, and how many rows does each step
-- really return? EXPLAIN ANALYZE runs the query, which is safe here
-- because it is a read-only SELECT.
-- -----------------------------------------------------------------------------
 
EXPLAIN ANALYZE
SELECT
	b.booking_id,
	p.passenger_name,
	f.flight_number,
	b.booked_at,
	b.booking_status,
	b.cancellation_reason
FROM bookings b
INNER JOIN passengers p
	ON b.passenger_id = p.passenger_id
INNER JOIN flights f
	ON b.flight_id = f.flight_id
ORDER BY b.booked_at, b.booking_id;
 
