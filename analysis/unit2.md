# Unit 2 Analysis

**Name:** Shin Eui Lee  
**Theme:** Airline Booking  

---

## 1. Table Creation Order

I made the tables in this order because child tables need their parent tables to exist first:

1. `passengers`: Created first because it only connects to itself for referrals.
2. `airports`: Independent lookup table for airport codes.
3. `flights`: Created before routes and bookings so other tables can point to it.
4. `flight_routes`: Created next because it connects `flights` and `airports`.
5. `bookings`: Created last because it needs both `passengers` and `flights` to work.

---

## 2. Foreign Key Decisions

| Foreign Key | ON DELETE Choice | Reason in One Sentence |

| `fk_passengers_referrer` (`passengers.referred_by`) | `ON DELETE SET NULL` | If a user leaves the airline, the person they invited should still keep their account. |
| `fk_flight_routes_flight` (`flight_routes.flight_id`) | `ON DELETE CASCADE` | If a flight schedule is removed before it runs, its stops should be deleted too. |
| `fk_flight_routes_airport` (`flight_routes.airport_code`) | `ON DELETE RESTRICT` | An airport should not be deleted if flights are still scheduled to use it. |
| `fk_bookings_passenger` (`bookings.passenger_id`) | `ON DELETE RESTRICT` | A passenger cannot be deleted if they already bought a ticket. |
| `fk_bookings_flight` (`bookings.flight_id`) | `ON DELETE RESTRICT` | A flight cannot be deleted if people have already booked seats on it. |

### Real-World Events and Why Alternatives Do Not Work

* **`passengers.referred_by` (SET NULL):**
  * When a passenger deletes their account, setting this to `SET NULL` simply clears the referral box for the person they invited.
  * If I used `CASCADE` here, deleting one person would also delete their friends' accounts, which would lose real customers.

* **`flight_routes.flight_id` (CASCADE):**
  * When an airline cancels an empty flight schedule before tickets go on sale, the stops in `flight_routes` are useless on their own. `CASCADE` cleans them up automatically.
  * If I used `RESTRICT`, the airline staff would have to delete every single stop by hand before deleting the flight, which is annoying and unnecessary.

* **`flight_routes.airport_code` (RESTRICT):**
  * If someone tries to delete an airport while flights are still flying there, the system stops them.
  * If I used `CASCADE`, deleting one airport by mistake would delete all the flight routes using that airport, messing up the whole schedule.

* **`bookings.passenger_id` and `bookings.flight_id` (RESTRICT):**
  * A booking is a paid ticket. If someone wants to cancel a flight or their account, the airline must change the status to `'canceled'` instead of deleting the row.
  * If I used `CASCADE`, deleting a flight or customer would erase the payment record, which ruins accounting and flight history.

---

## 3. CHECK Constraints

* **`chk_passengers_no_self_referral` (`referred_by IS DISTINCT FROM passenger_id`):**
  * Stops someone from using their own ID as a referral to get a free sign-up bonus.
* **`chk_flights_base_fare` (`base_fare > 0`):**
  * Stops flights from being saved with a $0 or negative price because of a typing error.
* **`chk_flights_total_seats` (`total_seats > 0`):**
  * Makes sure a plane cannot be saved with 0 seats by accident.
* **`chk_flights_schedule` (`arrival_time > departure_time`):**
  * Stops arrival time from being earlier than departure time if someone mixes up AM/PM or dates.
* **`chk_flight_routes_point_type` (`point_type IN ('origin', 'destination', 'layover')`):**
  * Stops typos like `'start'` or `'dest'` so only these three words can be saved.
* **`chk_bookings_fare_paid` (`fare_paid >= 0`):**
  * Makes sure a paid ticket amount is never a negative number.
* **`chk_bookings_status` (`booking_status IN ('confirmed', 'checked_in', 'canceled', 'completed')`):**
  * Keeps status values consistent and blocks spelling mistakes like `'cancelled'` with two l's.

---

## 4. Changes from Unit 1

* I changed IDs to `INTEGER GENERATED ALWAYS AS IDENTITY` to follow the PostgreSQL 14 guide for this class.
* I added a check so arrival time must be after departure time.
* I added `referred_by` to the passenger table so passengers can refer each other.
