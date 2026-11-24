EX603 Data and Algorithms for Scalable Systems  
Name: Shin Eui Lee  

# Project Title: Airline Booking and Operation Sytem
A relational database managing airline operation including managing flights, passenger reservations and routes. 

## Theme: Airline Booking

  - actor: passangers
  - producer: flights
  - event: bookings
  - catalog: airports
  - junction: flight_routes
  - metric: fare_paid

What the system does: A relational database for a large-scale application for airline booking

## Domain Overview

This platform is an airline booking system designed to help passengers sign up, search for flights, book seats, and manage their reservations. Behind the scenes, it supports airline operations by organizing flight information, airport connections, seat capacity, and available flight services. The system keeps this information in one place so the company can track passenger bookings, reservation statuses, and recorded fares.

To support everyday operations, the database answers several key business questions. For flight management, it helps identify which airports and services are associated with each flight. For customer and revenue management, it helps staff determine who is booked on each flight, how many bookings each flight has received, and how much recorded fare each flight has generated.

The database also supports business performance analysis by identifying booking trends, comparing individual fares with flight averages, ranking flights by booking volume, and examining passenger no-show patterns over time. One of the main business questions is whether the passenger no-show problem is getting better or worse and what actions the team should take next quarter to improve operational performance.

## Entity Relationship Diagram (ERD)

### ERD Image
![Airline Booking ERD](schema/erd.png)

### ERD diagram source

// Actor: passengers
Table passengers {
  passenger_id bigint [primary key]
  first_name varchar(50)
  middle_name varchar(50)
  last_name varchar(50)
  email varchar(250)
  phone_number varchar(20)
  registration_date timestamptz
}

// Producer: flights
Table flights {
  flight_id bigint [primary key]
  flight_number varchar(10)
  departure_time timestamptz
  arrival_time timestamptz
  base_fare numeric(10,2)
  total_seats integer
  is_active boolean
}

// Event: bookings
Table bookings {
  booking_id bigint [primary key]
  booking_reference char(6)
  passenger_id bigint
  flight_id bigint
  seat_number varchar(5)
  fare_paid numeric(10,2)
  booking_status varchar(20)
  ticket_purchased_time timestamptz
}

// Catalog: airports
Table airports {
  airport_code char(3) [primary key]
  airport_name varchar(100)
  airport_city varchar(100)
  airport_country varchar(100)
}

// Junction: flight_routes
Table flight_routes {
  flight_id bigint
  airport_code char(3)
  point_type varchar(20)

  indexes {
    (flight_id, airport_code) [pk]
  }
}

// Relationships 
Ref: passengers.passenger_id < bookings.passenger_id
Ref: flights.flight_id < bookings.flight_id
Ref: flights.flight_id < flight_routes.flight_id
Ref: airports.airport_code < flight_routes.airport_code

### Updated ERD diagram source (Assignment 2)

// Actor: passengers
Table passengers {
  passenger_id integer [pk, increment]
  first_name varchar(50)
  middle_name varchar(50)
  last_name varchar(50)
  email varchar(250)
  phone_number varchar(20)
  registration_date timestamptz
  referred_by integer
}

// Producer: flights
Table flights {
  flight_id integer [pk, increment]
  flight_number varchar(10)
  departure_time timestamptz
  arrival_time timestamptz
  base_fare numeric(10,2)
  total_seats integer
  is_active boolean
}

// Event: bookings
Table bookings {
  booking_id integer [pk, increment]
  booking_reference char(6)
  passenger_id integer
  flight_id integer
  seat_number varchar(5)
  fare_paid numeric(10,2)
  booking_status varchar(20)
  ticket_purchased_time timestamptz
}

// Catalog: airports
Table airports {
  airport_code char(3) [pk]
  airport_name varchar(100)
  airport_city varchar(100)
  airport_country varchar(100)
}

// Junction: flight_routes
Table flight_routes {
  flight_id bigint
  airport_code char(3)
  point_type varchar(20)

  indexes {
    (flight_id, airport_code) [pk]
  }
}



// Relationships 
Ref: passengers.passenger_id < bookings.passenger_id
Ref: flights.flight_id < bookings.flight_id
Ref: flights.flight_id < flight_routes.flight_id
Ref: airports.airport_code < flight_routes.airport_code
Ref: passengers.referred_by > passengers.passenger_id

## Database Schema (DDL)

The ERD above represents the original database design developed in Assignments 1 and 2. Beginning in Unit 3, the SQL analyses use the instructor-provided reference schema and dataset, which differ slightly from the original design.

The database schema and reference dataset were provided in Unit 3. The SQL file contains the table definitions, primary and foreign keys, constraints, and sample data used throughout this project.

[View the Database Schema and Reference Dataset](schema/airline.sql)

### Table Overview

The reference database consists of six related tables that support airline booking operations and business analysis.

| Table | Description |
| --- | --- |
| `passengers` | Stores passenger information, registration details, account status, and referral relationships. |
| `flights` | Stores flight information, including flight numbers, origin countries, seat capacity, and active status. |
| `bookings` | Stores individual booking records, including passenger and flight IDs, booking timestamps, fares, booking statuses, and cancellation reasons. |
| `airports` | Stores airport identifiers, IATA codes, and airport names. |
| `flight_routes` | Connects flights to airports and records the effective dates of those relationships. |
| `flight_services` | Stores the service codes associated with each flight. |

The `bookings`, `flights`, and `passengers` tables are the primary tables used in the SQL analyses. They support booking volume analysis, fare comparisons, passenger behavior analysis, flight rankings, and passenger no-show monitoring.

## Schema Design

The relational database schema for flight operations and reservations built for PostgreSQL 14+.

* **passengers (actor)**: Stores customer accounts. Uses an auto-generated identity integer key and an enforced UNIQUE constraint on emails, with members referral tracking.
* **airports (catalog)**: Stores airport information, using the global 3-letter airport codes (CHAR(3)) as the primary key.
* **flights (producer)**: Stores flight schedules, seat capacity, ticket prices with basic schedule and fare validation.
* **flight_routes (junction)**: Resolves many-to-many associations between flights and airports. Utilizes a composite primary key (flight_id, airport_code) to prevent duplicate entries.
* **bookings (event)**: Stores flight reservations and paid fares, keeping a record of passenger ticket history and standard reservation statuses like confirmed or canceled. 

### Key Design Decisions
* **Protecting Booking History:** Foreign keys on bookings utilize ON DELETE RESTRICT to ensure passenger reservations and payment records are not accidentally deleted, ensuring booking records stay intact.
* **Automated Cleanup for Schedules:** Deleting a flight automatically removes its associated route stops in flight_routes using ON DELETE CASCADE.
* **Data Validation Checks:** CHECK constraints on status values, seat capacity, departures/arrival times so invalid data cannot enter the database.

## Query Catalogue

The following catalogue summarizes the SQL queries developed throughout this project, the business questions they address, and links to the corresponding SQL files.

### Unit 3

### Unit 4

### Unit 5

### Unit 6: Window Functions and Analytics

| Task | Query | Business Question |
| --- | --- | --- |
| 6.1 Q1 | [Flight Average Fare](queries/unit6/q6_1.sql) | Which individual booking fares are unusually high or low compared with their flight's average fare? |
| 6.1 Q2 | [Flight Rankings](queries/unit6/q6_1.sql) | Which flights receive the most bookings, and how do different ranking methods handle ties? |
| 6.1 Q3 | [Flight Performance Bands](queries/unit6/q6_1.sql) | How can flights be divided into four groups based on booking volume, and how are tied flights handled? |
| 6.2 Part A | [Previous and Next Booking Fares](queries/unit6/q6_2.sql) | How do fares change between consecutive bookings for the same flight? |
| 6.2 Part B | [Running Total and Moving Average](queries/unit6/q6_2.sql) | How do cumulative recorded fares and recent average fares change over time? |
| 6.2 Part C | [Booking Activity Gaps](queries/unit6/q6_2.sql) | Which flights experience extended periods without recorded bookings? |
| 6.3 Part A | [Top Three Booking Fares](queries/unit6/q6_3.sql) | Which three bookings have the highest fares for each flight? |
| 6.3 Part B | [Month-over-Month Comparison](queries/unit6/q6_3.sql) | How do monthly booking volume and recorded fares change compared with the previous month? |
| Supporting Analysis 1 | [Monthly No-show Rate](queries/unit6/q6_3.sql) | Is the monthly passenger no-show rate improving or worsening? |
| Supporting Analysis 2 | [Quarterly No-show Rate](queries/unit6/q6_3.sql) | Does quarterly reporting reveal a clearer trend in passenger no-show performance? |
| Supporting Analysis 3 | [Data Coverage](queries/unit6/q6_3.sql) | What historical data is available, and is it sufficient to assess sustained improvement? |

## Technical Highlights

## Findings and Recommendations

## Limitations and Future Improvements


## Unit 4: Booking Fare and No-Show Analysis

Used the same airline booking data from Unit 3. The metric is fare_paid, the actor is passenger_id, and the producer is flight_id. booking_country was used as a region label. For this report, failure means a booking with cancellation_reason = 'Passenger no show'.

- queries/unit4/q4_1.sql: Overall booking and fare summary, actual no-show rate, counts by flight, HAVING, and flight plus country results.
- queries/unit4/q4_2.sql: Total bookings and no-shows in one query, country subtotals and platform grand total, and a CTE baseline for busy flights.
- analysis/unit4.md: Explanations for Tasks 4.1 and 4.2 and the reflection.
- analysis/unit4-finding.md: Main finding and which flight IDs recommended for reviewing.
- screenshots/unit4: Full screenshots from pgAdmin showing all query and its result together.

## Unit 6: Window Functions and Analytics

Used the same airline booking data from previous units to analyze individual booking fares, flight popularity, booking patterns, and passenger no-show trends using SQL window functions. The metric is `fare_paid`, the actor is `passenger_id`, and the producer is `flight_id`. As defined in Unit 4, failure means a booking with `cancellation_reason = 'Passenger no show'`.

### SQL Queries and Analysis

- [queries/unit6/q6_1.sql](queries/unit6/q6_1.sql): Comparison of individual booking fares with flight averages, comparison of window functions and GROUP BY, flight popularity rankings using ROW_NUMBER, RANK, and DENSE_RANK, and flight grouping using NTILE.
- [queries/unit6/q6_2.sql](queries/unit6/q6_2.sql): Comparison of consecutive booking fares using LAG and LEAD, running fare totals, moving averages, revenue target progress, and detection of booking gaps.
- [queries/unit6/q6_3.sql](queries/unit6/q6_3.sql): Top three booking fares per flight, month-over-month booking and fare comparisons, monthly and quarterly passenger no-show rates, and data coverage analysis.
- [analysis/unit6.md](analysis/unit6.md): Explanations, query results, business interpretations, and write-ups for Tasks 6.1, 6.2, and 6.3, including the supporting analyses and reflection.
- [analysis/unit6-finding.md](analysis/unit6-finding.md): Closing memo for Task 6.4, including passenger no-show trends, data limitations, supporting evidence, and recommendations for the next quarter.
- [screenshots/unit6](screenshots/unit6): Screenshots from pgAdmin showing the executed SQL queries and their results.

### Key Findings

- Window functions preserved all 200 individual booking records, while GROUP BY returned only 13 flight-level summary rows.
- A total of 12 passenger no-shows were identified across 200 bookings, resulting in an overall recorded no-show rate of 6.00%.
- The quarterly passenger no-show rate decreased from 7.55% in Q1 to 4.17% in Q4, suggesting improvement at the quarterly level.
- Monthly no-show rates remained inconsistent, including an increase to 12.50% in December after two months without recorded no-shows.
- The limited sample size and historical coverage prevent a definitive conclusion about sustained improvement.

### Recommendations for the Next Quarter

- Monitor monthly and quarterly passenger no-show rates.
- Investigate recurring passenger no-show cases and test preventive measures.
- Expand historical data coverage and improve the collection of flight departure and no-show occurrence timestamps.

Additional findings, supporting SQL queries, and detailed recommendations are available in the [Unit 6 Closing Memo](analysis/unit6-finding.md).

## Final Project Video Presentation

This presentation demonstrates SQL window functions, key findings,
business recommendations, and limitations of the analysis.

[Watch the Final Project Presentation](https://bostonu.zoom.us/rec/share/ay89Ow0DyrpECHam-6wL9QKON4oOXoIMwS12PG9D6rmd17TE7hdp1EKwtJGVVBbJ.JBpUI3jn0K41bYV-)

## How to Run It

### Prerequisites

- PostgreSQL installed
- Access to the PostgreSQL command-line tools (`createdb` and `psql`)

Run the following commands from the root directory of this repository.

### Step 1: Create the Database

```bash
createdb ex603_airline
```

### Step 2: Create the Schema and Load the Reference Dataset

```bash
psql -d ex603_airline -f schema/airline.sql
```

### Step 3: Execute an Analysis Query

For example, to execute the Task 6.1 queries:

```bash
psql -d ex603_airline -f queries/unit6/q6_1.sql
```

Other SQL queries can be executed by replacing the file path with the desired query file.
