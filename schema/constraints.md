**Task 1.3: Specify Integrity Constraints**
Write the constraints that protect your data. For each foreign key, state and justify the ON DELETE behavior.

# Integrity Constraints

## Primary Keys Constraints
* passengers(passenger_id): Uniquely identifies each passenger.
* flights(flight_id): Uniquely identifies each scheduled flight.
* airports(airport_code): identifies each airport using 3 letter airport code.
* flight_routes(flight_id, airport_code): Composite key to ensure an airport cannot be added to the same flight more than once.
* bookings(booking_id): Uniquely identifies each ticket reservation.

## Foreign Keys & ON DELETE
* flight_routes.flight_id -> flights(flight_id)
  * Rule: ON DELETE CASCADE
  * Reason: If a flight record is deleted, its route stops have no meaning and should be removed automatically.

* flight_routes.airport_code -> airports(airport_code)
  * Rule: ON DELETE RESTRICT
  * Reason: An airport should not be deleted if active flight routes still reference it.

* bookings.passenger_id -> passengers(passenger_id)
  * Rule: ON DELETE RESTRICT
  * Reason: A passenger cannot be deleted if they have existing booking and payment records.

* bookings.flight_id -> flights(flight_id)
  * Rule: ON DELETE RESTRICT
  * Reason: A flight cannot be deleted if passengers already hold tickets for it.

## Check & Business Rules
* fare_paid >= 0: Ticket price cannot be negative.
* base_fare > 0: Base flight fare must be a positive amount.
* total_seats > 0: Aircraft seat capacity must be at least 1.
* point_type IN ('origin', 'destination', 'layover'): Routes must use one of these three valid stop types.
* booking_status IN ('confirmed', 'checked_in', 'canceled', 'completed'): Limits booking statuses to valid values.
