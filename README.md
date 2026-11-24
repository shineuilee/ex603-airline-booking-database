EX603 Data and Algorithms for Scalable Systems  
Name: Shin Eui Lee  

# Project Title: Airline Booking and Operations System
A relational database project designed to manage airline operations, passenger bookings, and flight routes while supporting SQL-based analysis of booking activity, fare patterns, and passenger no-show trends.

## Theme: Airline Booking

- Actor: passengers
- Producer: flights
- Event: bookings
- Catalog: airports
- Junction: flight_routes
- Metric: fare_paid

**What the system does:** The system manages flight information, passenger records, reservations, airport connections, and flight routes while supporting the analysis of booking activity, fare patterns, and passenger no-show rates.

## Domain Overview

This platform is an airline booking system designed to help passengers sign up, search for flights, book seats, and manage their reservations. Behind the scenes, it supports airline operations by organizing flight information, airport connections, seat capacity, and available flight services. The system keeps this information in one place so the company can track passenger bookings, reservation statuses, and recorded fares.

To support everyday operations, the database answers several key business questions. For flight management, it helps identify which airports and services are associated with each flight. For customer and revenue management, it helps staff determine who is booked on each flight, how many bookings each flight has received, and how much recorded fare each flight has generated.

The database also supports business performance analysis by identifying booking trends, comparing individual fares with flight averages, ranking flights by booking volume, and examining passenger no-show patterns over time. One of the main business questions is whether the passenger no-show problem is getting better or worse and what actions the team should take next quarter to improve operational performance.

## Entity Relationship Diagram (ERD)

### ERD Image
![Airline Booking ERD](schema/erd.png)

### ERD diagram source

```dbml
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
```

### Updated ERD diagram source (Assignment 2)

```dbml
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
```

## Schema Design

The following describes the original relational database design developed in Assignments 1 and 2 for flight operations and reservations using PostgreSQL 14+.

* **passengers (actor)**: Stores customer accounts. Uses an auto-generated identity integer key and an enforced UNIQUE constraint on emails, with members referral tracking.
* **airports (catalog)**: Stores airport information, using the global 3-letter airport codes (CHAR(3)) as the primary key.
* **flights (producer)**: Stores flight schedules, seat capacity, ticket prices with basic schedule and fare validation.
* **flight_routes (junction)**: Resolves many-to-many associations between flights and airports. Utilizes a composite primary key (flight_id, airport_code) to prevent duplicate entries.
* **bookings (event)**: Stores flight reservations and paid fares, keeping a record of passenger ticket history and standard reservation statuses like confirmed or canceled. 

### Key Design Decisions
* **Protecting Booking History:** Foreign keys on bookings utilize ON DELETE RESTRICT to ensure passenger reservations and payment records are not accidentally deleted, ensuring booking records stay intact.
* **Automated Cleanup for Schedules:** Deleting a flight automatically removes its associated route stops in flight_routes using ON DELETE CASCADE.
* **Data Validation Checks:** CHECK constraints on status values, seat capacity, departures/arrival times so invalid data cannot enter the database.

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

Throughout the SQL analyses, a passenger no-show is defined as a booking with `cancellation_reason = 'Passenger no show'`. The no-show rate is calculated as the number of recorded passenger no-shows divided by the total number of recorded bookings, multiplied by 100.

## Query Catalogue

The following catalogue summarizes the SQL queries developed throughout this project, the business questions they address, and links to the corresponding SQL files.

### Unit 3: SQL Fundamentals and Query Correction

| Task | Query | Business Question |
| --- | --- | --- |
| 3.1 A | [Active High-Capacity Flights](queries/unit3/q3_1.sql) | Which active flights have a seat capacity of at least 180? |
| 3.1 B | [Booking Status Identification](queries/unit3/q3_1.sql) | What booking statuses exist in the database? |
| 3.1 C – Part 1 | [Fare Range Filtering](queries/unit3/q3_1.sql) | Which bookings have fares between 20 and 40? |
| 3.1 C – Part 2 | [Booking Country Filtering](queries/unit3/q3_1.sql) | Which bookings were made in Korea or Japan? |
| 3.1 D – Part 1 | [Flight Number Pattern Matching](queries/unit3/q3_1.sql) | Which flights have flight numbers beginning with VN20? |
| 3.1 D – Part 2 | [Missing Cancellation Reasons](queries/unit3/q3_1.sql) | How can missing cancellation reasons be displayed clearly in operational reports? |
| 3.1 E | [Fare Calculation and Classification](queries/unit3/q3_1.sql) | What is the calculated total fare for each booking, and how can bookings be classified by fare level? |
| 3.2 Part A | [NULL Handling and Booking Counts](queries/unit3/q3_2.sql) | How can bookings not identified as passenger no-shows be counted correctly without unintentionally excluding NULL cancellation reasons? |
| 3.2 Part B | [Calculated Fare Filtering](queries/unit3/q3_2.sql) | How can bookings with calculated total fares above 30 be identified correctly without referencing an unavailable SELECT alias? |
| 3.3 | [Disputed Booking Identification](queries/unit3/q3_3.sql) | Which passengers have at least one disputed booking, and how can they be identified using different SQL approaches? |

### Unit 4: From Rows to Insight

| Task | Query | Business Question |
| --- | --- | --- |
| 4.1 Q1 | [Overall Booking and Fare Summary](queries/unit4/q4_1.sql) | What are the platform's overall booking volume, fare statistics, and number of unique passengers? |
| 4.1 Q2 | [Booking Volume and Average Fare by Flight](queries/unit4/q4_1.sql) | How do booking volume and average fare vary across flights? |
| 4.1 Q3 | [High-Volume Flight Analysis](queries/unit4/q4_1.sql) | Which flights have at least 10 bookings, and what are their average fares and no-show rates? |
| 4.1 Q4 | [Flight and Regional Booking Analysis](queries/unit4/q4_1.sql) | How do booking volume, average fares, and no-show counts vary by flight and booking country? |
| 4.2 Part A | [Flight-Level No-show Analysis](queries/unit4/q4_2.sql) | How many bookings and passenger no-shows does each flight have, and which flights have the highest no-show rates? |
| 4.2 Part B | [Regional and Platform-Level Summary](queries/unit4/q4_2.sql) | How do booking volume and no-show rates vary across regions and the platform as a whole? |
| 4.2 Part C | [No-show Baseline for Busy Flights](queries/unit4/q4_2.sql) | What is the combined passenger no-show rate for flights with at least 10 bookings? |

### Unit 5: Joins, Set Operations, and Query Performance

| Task | Query | Business Question |
| --- | --- | --- |
| 5.1 Q1 | [Passenger and Flight Booking Details](queries/unit5/q5_1.sql) | Who made each booking, which flight was booked, and what is the booking status? |
| 5.1 Q2 – Part 1 | [Shared Airport Analysis](queries/unit5/q5_1.sql) | Which airports are associated with Flights 1, 2, and 3, and do these flights share common airports? |
| 5.1 Q2 – Part 2 | [SGN Airport Flight Analysis](queries/unit5/q5_1.sql) | Which flights are associated with SGN airport, and how do their booking volumes and no-show counts compare? |
| 5.1 Q3 | [Similar Flight Comparison](queries/unit5/q5_1.sql) | Which other flights have the same seat capacity as the focus flights, and what are their booking volumes and no-show rates? |
| 5.2 Part A-1 | [All Flights Using LEFT JOIN](queries/unit5/q5_2.sql) | How many bookings does each flight have, including flights with no recorded bookings? |
| 5.2 Part A-2 | [Flights with Bookings Using INNER JOIN](queries/unit5/q5_2.sql) | Which flights have at least one recorded booking, and how many bookings does each have? |
| 5.2 Part A-3 and A-4 | [Excluded Flight Analysis](queries/unit5/q5_2.sql) | How many flights are excluded by INNER JOIN, and which specific flights are excluded? |
| 5.2 Part B-1 and B-2 | [RIGHT JOIN and Result Validation](queries/unit5/q5_2.sql) | Can RIGHT JOIN produce the same booking report as LEFT JOIN, and how can the equivalence be verified? |
| 5.2 Part B-3 | [Matched and Unmatched Records](queries/unit5/q5_2.sql) | Are there flights without bookings or bookings without matching flights? |
| 5.2 Part C-1 and C-2 | [Flights Without Bookings Using NOT EXISTS and EXCEPT](queries/unit5/q5_2.sql) | Which flights have no recorded bookings, and how can they be identified using two different SQL approaches? |
| 5.2 Part C-3 | [NOT EXISTS and EXCEPT Validation](queries/unit5/q5_2.sql) | Do NOT EXISTS and EXCEPT identify the same flights without bookings? |
| 5.3 Part A-1 and A-2 | [CROSS JOIN and Row Count Validation](queries/unit5/q5_3.sql) | What are all possible airport-flight combinations, and does the resulting row count match the expected Cartesian product? |
| 5.3 Part B-1 | [Estimated Query Execution Plan](queries/unit5/q5_3.sql) | How does PostgreSQL plan to execute the three-table booking query? |
| 5.3 Part B-2 | [Actual Query Execution Performance](queries/unit5/q5_3.sql) | How does the actual query execution performance compare with the estimated execution plan? |

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

Throughout this project, several SQL techniques were applied to improve reporting accuracy, organize complex queries, and support business decision-making.

### 1. NULL Handling

NULL handling was used to prevent records from being unintentionally excluded from query results. In Unit 3, a query using an inequality condition on `cancellation_reason` incorrectly excluded rows containing NULL values. Adding an `IS NULL` condition corrected the booking count. This technique was important for maintaining accurate and reliable reports.

- Related query: [Task 3.2](queries/unit3/q3_2.sql)

### 2. Aggregations and Conditional Aggregation

Aggregate functions such as `COUNT()`, `SUM()`, and `AVG()` were used to summarize booking volume, fares, and passenger no-show rates. Conditional aggregation using `CASE` allowed total bookings and no-shows to be calculated within a single grouped query. This made it easier to compare flight performance and identify flights that may require further investigation.

- Related queries: [Task 4.1](queries/unit4/q4_1.sql), [Task 4.2](queries/unit4/q4_2.sql)

### 3. Common Table Expressions (CTEs)

CTEs were used to break complex queries into smaller and more manageable steps. For example, flight-level booking and no-show counts were calculated first before determining the overall no-show baseline for flights with at least 10 bookings. CTEs improved query readability, maintainability, and the ability to validate intermediate results.

- Related queries: [Task 4.2](queries/unit4/q4_2.sql), [Task 6.3](queries/unit6/q6_3.sql)

### 4. JOINs

Different types of JOINs were used to connect passengers, bookings, flights, and airports. In particular, comparing `INNER JOIN` and `LEFT JOIN` demonstrated how flights without bookings could be unintentionally excluded from operational reports. Using the appropriate JOIN type helped maintain complete and accurate reporting.

- Related queries: [Task 5.1](queries/unit5/q5_1.sql), [Task 5.2](queries/unit5/q5_2.sql)

### 5. Window Functions

Window functions such as `AVG() OVER`, `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, and `LEAD()` were used to perform advanced analytical calculations without collapsing individual rows. These functions supported fare comparisons, flight rankings, running totals, moving averages, and period-over-period analysis. They were particularly useful for evaluating changes in passenger no-show rates over time and supporting operational recommendations.

- Related queries: [Task 6.1](queries/unit6/q6_1.sql), [Task 6.2](queries/unit6/q6_2.sql), [Task 6.3](queries/unit6/q6_3.sql)

## Findings and Recommendations

The SQL analyses conducted throughout this project identified several important findings related to passenger no-shows, flight activity, and booking performance.

### 1. Passenger No-show Rates Show Improvement but Remain Inconsistent

**Finding:**

Of the 200 recorded bookings in 2023, 12 were identified as passenger no-shows, resulting in an overall no-show rate of 6.00%.

The quarterly no-show rates were:

| Quarter | No-show Rate |
| --- | ---: |
| Q1 | 7.55% |
| Q2 | 6.25% |
| Q3 | 5.88% |
| Q4 | 4.17% |

Although the quarterly no-show rate decreased by 3.38 percentage points from Q1 to Q4, the monthly results showed considerable fluctuations. In December, the no-show rate increased to 12.50% after two consecutive months with no recorded no-shows.

**Business Implication:**

The quarterly results suggest improvement in the observed no-show rate. However, the monthly fluctuations indicate that sustained improvement has not yet been established.

**Recommendation:**

Management should monitor both monthly and quarterly no-show rates, investigate the circumstances surrounding no-show cases, and evaluate preventive measures such as passenger reminders and booking confirmations. The Q4 rate of 4.17% can serve as a preliminary benchmark for the following quarter.

- Supporting queries: [Task 4.2](queries/unit4/q4_2.sql), [Task 6.3](queries/unit6/q6_3.sql)

### 2. Active Flights Without Recorded Bookings

**Finding:**

The database contains 15 flights, but only 13 have recorded bookings. Flight VN214 (Flight ID 14) and Flight VN215 (Flight ID 15) are marked as active despite having no recorded bookings.

These flights were excluded when using an INNER JOIN but were successfully identified using LEFT JOIN, NOT EXISTS, and EXCEPT.

**Business Implication:**

Reports that include only flights with existing bookings may provide an incomplete picture of platform activity. Active flights without bookings may indicate low demand, outdated flight records, or potential configuration issues that require further investigation.

**Recommendation:**

The operations team should review these two flights to determine whether they are available for booking, whether their routes and airport information are configured correctly, and whether their active status remains appropriate. Operational reports should include flights with zero bookings to ensure complete visibility.

- Supporting query: [Task 5.2](queries/unit5/q5_2.sql)

### 3. Booking Volume and Recorded Fares Do Not Always Follow the Same Trend

**Finding:**

In March 2023, booking volume decreased by 47.62%, from 21 to 11 bookings, while total recorded fares decreased by 70.01%.

However, in April, booking volume remained unchanged at 11 bookings, while total recorded fares increased by 91.02%.

**Business Implication:**

Booking volume alone is not sufficient to evaluate financial performance. Changes in recorded fares may reflect differences in pricing, fare composition, or booking characteristics rather than changes in customer demand alone.

**Recommendation:**

Management should monitor booking volume, average fares, and total recorded fares together. Significant month-over-month changes should trigger a review of flight availability, pricing, cancellation records, and potential data quality issues.

- Supporting query: [Task 6.3](queries/unit6/q6_3.sql)

### Detailed Analysis

Additional findings, supporting evidence, and operational recommendations are available in the following documents:

- [Unit 6 Analysis and Reflection](analysis/unit6.md)
- [Final Findings and Closing Memo](analysis/unit6-finding.md)


## Limitations and Future Improvements

Although the SQL analyses provided useful insights into booking activity, fare patterns, and passenger no-show rates, several limitations should be considered when interpreting the results.

### 1. Limited Data Coverage

**Limitation:**

The reference dataset contains only 200 booking records from January through December 2023. Because of the relatively small dataset, even one or two additional passenger no-shows can substantially affect the calculated monthly no-show rate. Although the quarterly results showed improvement, one year of data is not sufficient to establish a sustained long-term trend or identify recurring seasonal patterns.

**Future Improvement:**

Collecting booking records over multiple years would allow management to compare performance across equivalent periods, identify seasonal patterns, and evaluate whether improvements in passenger no-show rates are sustained over time.

### 2. Limited Timestamp Information

**Limitation:**

The `booked_at` column represents the time a reservation was created rather than the scheduled departure time or the actual time a passenger failed to show up. Therefore, the monthly and quarterly no-show analyses reflect booking creation periods rather than the periods in which the no-show events actually occurred.

**Future Improvement:**

Adding scheduled departure timestamps, actual departure timestamps, and no-show event timestamps would support more accurate operational reporting. These additional fields would also allow management to analyze the relationship between booking lead time and passenger no-show rates.

### 3. Limited Information About Operational Causes

**Limitation:**

The current dataset allows the identification of unusual patterns, such as active flights without bookings, extended booking activity gaps, and significant changes in recorded fares. However, it does not provide sufficient information to determine the underlying causes of these patterns.

**Future Improvement:**

Additional data, including flight schedules, booking availability, pricing and promotion history, cancellation details, and booking system logs, would help distinguish between changes in customer demand, operational disruptions, configuration issues, and data quality problems.

These improvements would support more reliable analysis, stronger operational recommendations, and better-informed business decisions.

For additional discussion of data coverage and analytical limitations, see:

- [Unit 6 Analysis and Reflection](analysis/unit6.md)
- [Final Findings and Closing Memo](analysis/unit6-finding.md)

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

## Unit-Specific Documentation
### Unit 4: Booking Fare and No-Show Analysis

Used the same airline booking data from Unit 3. The metric is fare_paid, the actor is passenger_id, and the producer is flight_id. booking_country was used as a region label. For this report, failure means a booking with cancellation_reason = 'Passenger no show'.

#### SQL Queries and Analysis

- [queries/unit4/q4_1.sql](queries/unit4/q4_1.sql): Overall booking and fare summary, booking counts by flight, HAVING, and flight and regional analysis.
- [queries/unit4/q4_2.sql](queries/unit4/q4_2.sql): Total bookings and no-shows in one query, country subtotals, platform grand total, and a CTE baseline for flights with at least 10 bookings.
- [analysis/unit4.md](analysis/unit4.md): Explanations for Tasks 4.1 and 4.2, query results, and reflection.
- [analysis/unit4-finding.md](analysis/unit4-finding.md): Main findings and recommended flights for further investigation.
- [screenshots/unit4](screenshots/unit4): pgAdmin screenshots showing SQL queries and their corresponding results.

### Unit 6: Window Functions and Analytics

Used the same airline booking data from previous units to analyze individual booking fares, flight popularity, booking patterns, and passenger no-show trends using SQL window functions. The metric is `fare_paid`, the actor is `passenger_id`, and the producer is `flight_id`. As defined in Unit 4, failure means a booking with `cancellation_reason = 'Passenger no show'`.

#### SQL Queries and Analysis

- [queries/unit6/q6_1.sql](queries/unit6/q6_1.sql): Comparison of individual booking fares with flight averages, comparison of window functions and GROUP BY, flight popularity rankings using ROW_NUMBER, RANK, and DENSE_RANK, and flight grouping using NTILE.
- [queries/unit6/q6_2.sql](queries/unit6/q6_2.sql): Comparison of consecutive booking fares using LAG and LEAD, running fare totals, moving averages, revenue target progress, and detection of booking gaps.
- [queries/unit6/q6_3.sql](queries/unit6/q6_3.sql): Top three booking fares per flight, month-over-month booking and fare comparisons, monthly and quarterly passenger no-show rates, and data coverage analysis.
- [analysis/unit6.md](analysis/unit6.md): Explanations, query results, business interpretations, and write-ups for Tasks 6.1, 6.2, and 6.3, including the supporting analyses and reflection.
- [analysis/unit6-finding.md](analysis/unit6-finding.md): Closing memo for Task 6.4, including passenger no-show trends, data limitations, supporting evidence, and recommendations for the next quarter.
- [screenshots/unit6](screenshots/unit6): Screenshots from pgAdmin showing the executed SQL queries and their results.

#### Key Findings

- Window functions preserved all 200 individual booking records, while GROUP BY returned only 13 flight-level summary rows.
- A total of 12 passenger no-shows were identified across 200 bookings, resulting in an overall recorded no-show rate of 6.00%.
- The quarterly passenger no-show rate decreased from 7.55% in Q1 to 4.17% in Q4, suggesting improvement at the quarterly level.
- Monthly no-show rates remained inconsistent, including an increase to 12.50% in December after two months without recorded no-shows.
- The limited sample size and historical coverage prevent a definitive conclusion about sustained improvement.

#### Recommendations for the Next Quarter

- Monitor monthly and quarterly passenger no-show rates.
- Investigate recurring passenger no-show cases and test preventive measures.
- Expand historical data coverage and improve the collection of flight departure and no-show occurrence timestamps.

Additional findings, supporting SQL queries, and detailed recommendations are available in the [Unit 6 Closing Memo](analysis/unit6-finding.md).
