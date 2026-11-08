# Airline Booking Finding: Two Groups of Flights That Need Attention

This memo looks at two different groups of flights. The first group has bookings, but too many passengers do not show up. The second group has never had a single booking. These two groups have different problems, so they need different actions.

## Group 1: Flights where passengers often don't show up

**Flights 1, 2, and 3**

These flights get bookings, but more passengers miss their flights than on other flights.

- Flight 2: 3 no-shows out of 16 bookings (18.75%)
- Flight 3: 2 no-shows out of 13 bookings (15.38%)
- Flight 1: 1 no-show out of 11 bookings (9.09%)

For flights with 10 or more bookings, the usual no-show rate is 5.67%. All three flights are higher than that.

I also found that all three flights use the same large plane size (320 seats). Flight 4, which has the same size, also had a high no-show rate, but it only had 6 bookings, so I did not include it in the main list. The five 320-seat flights had 7 of the 12 no-shows on the whole platform. When a large plane flies with empty seats, the airline loses more potential revenue.

**Recommended action:** Send a reminder message (email or text) to every passenger on Flights 1, 2, and 3 one day before departure. The message should include the flight time and an easy way to cancel or change the booking. After three months, compare the no-show rate on these flights with the 5.67% baseline to see if the reminders helped.

Here, the problem is with passengers who already booked. So the action should focus on helping customers show up, or on letting them cancel early so the seat can be sold again.

## Group 2: Flights that have never had a booking

**Flights 14 and 15**

These two flights are listed as active in the system, but nobody has ever booked them. They were first scheduled in 2022, but all bookings in this dataset are from 2023. They also have no airports connected to them in the system.

**Recommended action:** Ask the operations team to check Flights 14 and 15 within the next two weeks. The team should answer three questions:

1. Are these flights actually open for sale?
2. Are their routes and airports set up correctly in the booking system?
3. Does the airline still plan to fly them?

If the flights are no longer needed, they should be changed to inactive so they don't make future reports confusing. If they should be on sale, the setup problem should be fixed first.

For these flights, sending reminders or doing marketing would not help, because there are no customers to remind. The problem is most likely inside the company, such as a setup mistake or an old schedule that was never cleaned up. So the first step is to check the system, not to contact customers.

## What we know and what we still need to check

What the data shows:

- Flights 1, 2, and 3 have higher no-show rates than other flights.
- Flights 14 and 15 are active but have no bookings and no airports connected to them.

What the data does not show:

- Why passengers on Flights 1, 2, and 3 don't show up. It could be the time of day, the booking country, or the price, but this needs more checking.
- Why Flights 14 and 15 have no bookings. Flight 13 also has no airports connected but still has 11 bookings, so the missing airports may not be the only reason.

This dataset only has 200 bookings from one year, so even a few no-shows can change the rates a lot. These results show where to look first, but they don't prove the cause. Collecting data over a longer period would help confirm whether these problems keep happening.
