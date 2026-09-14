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

This platform is an airline booking system where passengers can sign up, search for flights, book seats, and manage their reservations. Behind the scenes, it helps the airline organize its daily operations by scheduling flight times, connecting flights to departure and arrival airports, and preventing planes from being overbooked. The system keeps all of this information in one place so the company always knows who is flying and how much they paid.

To support everyday operations, the database answers several key questions. For flight tracking, it shows which flights are arriving at or departing from a specific airport and their scheduled times. For customer and revenue management, it helps staff quickly see who is booked on each flight, how many open seats remain, and how much money each flight has generated from ticket sales.


