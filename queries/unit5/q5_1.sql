-- -----------------------------------------------------------------------------
-- Roles: passengers (actor), flights (producer), bookings (event),
--        airports (catalog), flight_routes (junction)
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Task 5.1.Q1: Who made each booking, and for which flight?
-- This query joins three tables (bookings, passengers, flights) to show
-- the passenger, the flight, and the booking date and time for every booking.
-- -----------------------------------------------------------------------------

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
-- Task 5.1.Q2 (Part 1): Do Flights 1, 2, and 3 share the same airports?
-- This query connects flights to airports through the flight_routes
-- junction table and lists the airports used by each focus flight.
-- -----------------------------------------------------------------------------

SELECT
	f.flight_id,
	f.flight_number,
	STRING_AGG(a.iata_code, ', ' ORDER BY a.iata_code) AS airports_served
FROM flights f
INNER JOIN flight_routes fr
	ON f.flight_id = fr.flight_id
INNER JOIN airports a
	ON fr.airport_id = a.airport_id
WHERE f.flight_id IN (1, 2, 3)
GROUP BY f.flight_id, f.flight_number
ORDER BY f.flight_id;

-- -----------------------------------------------------------------------------
-- Task 5.1.Q2 (Part 2): Which flights use SGN (Tan Son Nhat International)?
-- SGN was chosen as the catalog tag because it is used by the most flights.
-- The query also shows the bookings and no-shows for each flight,
-- so the focus flights can be compared with other SGN flights.
-- -----------------------------------------------------------------------------

SELECT
	a.iata_code,
	a.airport_name,
	f.flight_id,
	f.flight_number,
	COUNT(b.booking_id) AS booking_count,
	SUM(CASE
		WHEN b.cancellation_reason = 'Passenger no show' THEN 1
		ELSE 0
	END) AS no_shows
FROM airports a
INNER JOIN flight_routes fr
	ON a.airport_id = fr.airport_id
INNER JOIN flights f
	ON fr.flight_id = f.flight_id
LEFT JOIN bookings b
	ON f.flight_id = b.flight_id
WHERE a.iata_code = 'SGN'
GROUP BY a.iata_code, a.airport_name, f.flight_id, f.flight_number
ORDER BY f.flight_id;

-- -----------------------------------------------------------------------------
-- Task 5.1.Q3: How do Flights 1, 2, and 3 compare with similar flights?
-- This self join compares each focus flight with other flights that have
-- the same seat capacity. It shows the booking count and no-show rate
-- of those flights to check whether they have similar results.
-- -----------------------------------------------------------------------------

WITH flight_activity AS (
	SELECT
		flight_id,
		COUNT(*) AS booking_count,
		SUM(CASE
			WHEN cancellation_reason = 'Passenger no show' THEN 1
			ELSE 0
		END) AS no_shows
	FROM bookings
	GROUP BY flight_id
)
SELECT
	f1.flight_id         AS focus_flight,
	f1.origin_country    AS focus_origin,
	f1.seat_capacity     AS shared_capacity,
	f2.flight_id         AS compared_flight,
	f2.origin_country    AS compared_origin,
	COALESCE(a2.booking_count, 0) AS compared_bookings,
	COALESCE(a2.no_shows, 0)      AS compared_no_shows,
	ROUND(100.0 * COALESCE(a2.no_shows, 0)
		/ NULLIF(a2.booking_count, 0), 2) AS compared_no_show_rate
FROM flights f1
INNER JOIN flights f2
	ON f1.seat_capacity = f2.seat_capacity
	AND f1.flight_id <> f2.flight_id
LEFT JOIN flight_activity a2
	ON f2.flight_id = a2.flight_id
WHERE f1.flight_id IN (1, 2, 3)
ORDER BY f1.flight_id, f2.flight_id;
