-- =================================================================
-- EX 603 Assignment 2 — schema.sql
-- Theme: Airline Booking
-- Author: Shin Eui Lee
-- Target: PostgreSQL 14+
-- =================================================================

-- Reset: Reverse creation order to prevent foreign key dependency errors.
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS flight_routes CASCADE;
DROP TABLE IF EXISTS flights CASCADE;
DROP TABLE IF EXISTS airports CASCADE;
DROP TABLE IF EXISTS passengers CASCADE;

-- -----------------------------------------------------------------
-- 1. passengers — Actor. User accounts. Created first because it only points to itself.
-- -----------------------------------------------------------------
CREATE TABLE passengers (
    passenger_id      INTEGER GENERATED ALWAYS AS IDENTITY,
    first_name        VARCHAR(50)  NOT NULL,
    middle_name       VARCHAR(50),
    last_name         VARCHAR(50)  NOT NULL,
    email             VARCHAR(250) NOT NULL,
    phone_number      VARCHAR(20)  NOT NULL,
    registration_date TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_passengers PRIMARY KEY (passenger_id),
    CONSTRAINT uq_passengers_email UNIQUE (email)
);

-- -----------------------------------------------------------------
-- 2. airports — Catalog. Airport info and codes. Independent table with no foreign keys.
-- -----------------------------------------------------------------
CREATE TABLE airports (
    airport_code      CHAR(3)      NOT NULL,
    airport_name      VARCHAR(100) NOT NULL,
    airport_city      VARCHAR(100) NOT NULL,
    airport_country   VARCHAR(100) NOT NULL,
    CONSTRAINT pk_airports PRIMARY KEY (airport_code)
);

-- -----------------------------------------------------------------
-- 3. flights — Producer. Flight schedules. Created before routes and bookings.
-- -----------------------------------------------------------------
CREATE TABLE flights (
    flight_id         INTEGER GENERATED ALWAYS AS IDENTITY,
    flight_number     VARCHAR(10)    NOT NULL,
    departure_time    TIMESTAMPTZ    NOT NULL,
    arrival_time      TIMESTAMPTZ    NOT NULL,
    base_fare         NUMERIC(10, 2) NOT NULL,
    total_seats       INTEGER        NOT NULL,
    is_active         BOOLEAN        NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_flights PRIMARY KEY (flight_id),
    CONSTRAINT chk_flights_base_fare CHECK (base_fare > 0),
    CONSTRAINT chk_flights_total_seats CHECK (total_seats > 0),
    CONSTRAINT chk_flights_schedule CHECK (arrival_time > departure_time)
);

-- -----------------------------------------------------------------
-- 4. flight_routes — Junction table resolving M:N between flights and airports.
-- -----------------------------------------------------------------
CREATE TABLE flight_routes (
    flight_id         INTEGER     NOT NULL,
    airport_code      CHAR(3)     NOT NULL,
    point_type        VARCHAR(20) NOT NULL,
    CONSTRAINT pk_flight_routes PRIMARY KEY (flight_id, airport_code),
    CONSTRAINT fk_flight_routes_flight
        FOREIGN KEY (flight_id) REFERENCES flights (flight_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_flight_routes_airport
        FOREIGN KEY (airport_code) REFERENCES airports (airport_code)
        ON DELETE RESTRICT,
    CONSTRAINT chk_flight_routes_point_type 
        CHECK (point_type IN ('origin', 'destination', 'layover'))
);

-- -----------------------------------------------------------------
-- 5. bookings — Event table. Tickets bought by passangers. Depends on both passengers and flights.
-- -----------------------------------------------------------------
CREATE TABLE bookings (
    booking_id            INTEGER GENERATED ALWAYS AS IDENTITY,
    booking_reference     CHAR(6)        NOT NULL,
    passenger_id          INTEGER        NOT NULL,
    flight_id             INTEGER        NOT NULL,
    seat_number           VARCHAR(5)     NOT NULL,
    fare_paid             NUMERIC(10, 2) NOT NULL,
    booking_status        VARCHAR(20)    NOT NULL,
    ticket_purchased_time TIMESTAMPTZ    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_bookings PRIMARY KEY (booking_id),
    CONSTRAINT uq_bookings_reference UNIQUE (booking_reference),
    CONSTRAINT fk_bookings_passenger
        FOREIGN KEY (passenger_id) REFERENCES passengers (passenger_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_bookings_flight
        FOREIGN KEY (flight_id) REFERENCES flights (flight_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_bookings_fare_paid CHECK (fare_paid >= 0),
    CONSTRAINT chk_bookings_status 
        CHECK (booking_status IN ('confirmed', 'checked_in', 'canceled', 'completed'))
);
