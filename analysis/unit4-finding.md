# EX603 - Project Assignment 4: From Rows to Insight

## Airline Booking Finding

All 200 bookings were checked to find the actual passenger no-show rate. The same definition from Unit 3 was used. A booking was counted as a no-show when the cancellation reason was "Passenger no show." There were 12 no-shows out of 200 bookings, so the overall no-show rate was 6.00%. The previous dashboard had a problem because bookings with blank cancellation reasons were not included in the results.

There were also 34 bookings marked as cancelled, which is 17.00% of all bookings. However, not all cancellations were passenger no-shows. The cancellation reasons included 12 passenger no-shows, 8 passenger cancellations, 7 payment failures, and 7 flight cancellations. The 188 bookings from the corrected Unit 3 query were bookings that were not passenger no-shows. This does not mean all 188 bookings were completed flights.

Based on the results, Flight IDs 2, 3, and 1 should be reviewed first.

Flight ID 2 had 3 no-shows out of 16 bookings (18.75%), which was the highest number of no-shows among all flights. Flight ID 3 had 2 no-shows out of 13 bookings (15.38%). Flight ID 1 had 1 no-show out of 11 bookings (9.09%). All three flights had higher no-show rates than the 5.67% combined rate for flights with at least 10 bookings.

Flight ID 4 also had a high no-show rate of 16.67%, but it only had 6 bookings. Because the number of bookings was small, it was not selected as one of the first three flights to investigate.

The booking dates and countries for Flight IDs 2, 3, and 1 should be checked more closely. More booking records over a longer period would also help determine whether the same problems happen regularly. These results show which flights may need more attention, but they do not prove that the flights themselves caused the passenger no-shows.
