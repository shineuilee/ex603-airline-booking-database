**Task 1.1**: all five relation schemas, their attributes, domains, and primary keys. 

# Relation Schema Definitions

## Actor: passengers
* Attributes (Domains)
  * passenger_id (BIGINT) - **Primary Key**. 
  * first_name (VARCHAR(50))
  * middle_name (VARCHAR(50))
  * last_name (VARCHAR(50))
  * email (VARCHAR(250))
  * phone_number (VARCHAR(20))
  * registration_date (TIMESTAMPTZ) 
    
  
## Producer: flights
* Attributes (Domains)
  * flight_id (BIGINT) - **Primary key**.
  * flight_number (VARCHAR(10))
  * departure_time (TIMESTAMPTZ)
  * arrival_time (TIMESTAMPTZ)
  * base_fare (NUMERIC(10,2))
  * total_seats (INTEGER)
  * is_active (BOOLEAN)
     

## Event: bookings
* Attributes (Domains)
  * booking_id (BIGINT) - **Primary key**
  * booking_reference(CHAR(6))
  * passenger_id (BIGINT) - Foreign key referencing passanger_id from passangers
  * flight_id (BIGINT) - Foreign key referencing flight_id from flights
  * seat_number (VARCHAR(5))
  * fare_paid (NUMERIC(10,2))
  * booking_status(VARCHAR(20))
  * ticket_purchased_time (TIMESTAMPTZ)  

## Catalog: airports
* Attributes (Domains)
  * airport_code (CHAR(3)) - **Primary key**
  * airport_name (VARCHAR(100))
  * airport_city (VARCHAR(100))
  * airport_country (VARCHAR(100))


## Junction: flight_routes
* Attributes (Domains)
  * flight_id (BIGINT) - Foreign key referencing flight_id from flights
  * airport_code (CHAR(3)) - Foreign key referencing airport_code from airports 
  * point_type (VARCHAR(20))
 
  * **Primary key**: (flight_id, airport_code) 

