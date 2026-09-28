# Unit 2 Analysis

**Name:** Shin Eui Lee  
**Theme:** Airline Booking  

---

## 1. Table Creation Order

I made the tables in this order because child tables need their parent tables to exist first.

1. **passengers**: Independent table which only references itself (referred_by), so it has no dependencies on other tables.
2. **airports**: Independent catalog table for airport codes. It also does not depend on any other table. 
3. **flights**: Independent table with no foreign keys as well. Created before routes and bookings so those tables can point to it.
   - Tables 1–3 can be created in any order among themselves since they do not depend on each other.
4. **flight_routes**: Junction table connecting flights and airports. Both parent tables must exist before this table can be created.
5. **bookings**: Transaction table needing foreign keys from both passengers and flights to work.
   - While it only technically depends on tables 2 and 3 at the schema level, it is created last to reflect the business logic (a flight must have defined routes before passengers can book it).

---

## 2. Foreign Key Decisions

| **Foreign Key** | ON DELETE Choice | Reason in One Sentence |

| **fk_passengers_referrer (passengers.referred_by)** | `ON DELETE SET NULL` | If a user leaves the airline, the person they invited should still keep their account. |
| **fk_flight_routes_flight (flight_routes.flight_id)** | `ON DELETE CASCADE` | If a flight schedule is removed before it runs, its stops associated should be deleted too. |
| **fk_flight_routes_airport (flight_routes.airport_code)** | `ON DELETE RESTRICT` | An airport should not be deleted if flights are still scheduled to use it. |
| **fk_bookings_passenger (bookings.passenger_id)** | `ON DELETE RESTRICT` | A passenger cannot be deleted if they already bought a ticket. |
| **fk_bookings_flight (bookings.flight_id)** | `ON DELETE RESTRICT` | A flight cannot be deleted if passengers have already booked seats on it. |

### Real-World Events and Why Alternatives Do Not Work

* **passengers.referred_by (SET NULL)**
  * When a passenger deletes their account, setting this to **SET NULL** simply clears the referral box for the person they invited.
  * If I used **CASCADE** here, deleting one passenger referred other users would also delete their friends' accounts, which would lose real customers.

* **flight_routes.flight_id (CASCADE)**
  * When an airline cancels an empty flight schedule before tickets go on sale, the stops in **flight_routes** are useless on their own. **CASCADE** cleans them up automatically.
  * If I used **RESTRICT**, the airline staff would have to delete every single stop manually before deleting the flight, which is unnecessary and waste of resource.

* **flight_routes.airport_code (RESTRICT)**
  * If someone tries to delete an airport while flights are still flying there, the system stops them.
  * If I used **CASCADE**, deleting one airport by mistake would delete all the flight routes using that airport, messing up the whole schedule.

* **bookings.passenger_id (RESTRICT)**
  * A booking is a paid ticket. If someone wants to delete their passenger account, the airline must change the status to 'canceled' instead of deleting the row.
  * If I used **CASCADE**, deleting a customer would erase the payment record, which ruins accounting and flight history.

* **bookings.flight_id (RESTRIC)**
  * Same logic as above. If the airline cancels a flight, the airline must mark the flight status as 'canceled' instead of deleting the row.
  * If I used **CASCADE**, deleting a flight would wipe out all passenger tickets and payment records tied to it.
---

## 3. CHECK Constraints

* **chk_passengers_no_self_referral** (referred_by IS DISTINCT FROM passenger_id)
  * Stops someone from using their own ID as a referral to get a free sign-up bonus.
* **chk_flights_base_fare** (base_fare > 0)
  * Stops flights from being saved with a $0 or negative price because of a typing error.
* **chk_flights_total_seats** (total_seats > 0)
  * Makes sure a plane cannot be saved with 0 seats by accident.
* **chk_flights_schedule** (arrival_time > departure_time)
  * Stops arrival time from being earlier than departure time if someone mixes up AM/PM or dates.
* **chk_flight_routes_point_type** (point_type IN ('origin', 'destination', 'layover'))
  * Stops typos like 'start' or 'dest' so only these three options can be saved.
* **chk_bookings_fare_paid** (fare_paid >= 0)
  * Makes sure a paid ticket amount is never a negative number.
* **chk_bookings_status** (booking_status IN ('confirmed', 'checked_in', 'canceled', 'completed'))
  * Keeps status values consistent and blocks spelling mistakes like 'cancelled' with two l's.

---

## 4. Changes from Unit 1

* I changed IDs to `INTEGER GENERATED ALWAYS AS IDENTITY` to follow the PostgreSQL 14 guide for this class.
* I added a check so arrival time must be after departure time.
* I added `referred_by` to the passenger table so passengers can refer each other for self-referral.
