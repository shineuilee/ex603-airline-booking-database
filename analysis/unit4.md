# EX603 - Project Assignment 4: From Rows to Insight

## Task 4.1: Measure the platform

The bookings table was used for this assignment. Each booking is an event, flight_id is the producer, and passenger_id is the actor. The numeric metric is fare_paid. The booking_country column was used for the region because it contains the country information in this dataset. However, it does not show the exact flight route or where a problem happened.

All 200 bookings were checked. There are 30 different passengers, and the total fare amount is $3,628.19. The average fare is $18.14, with a minimum of $0.00 and a maximum of $70.86. The $0.00 fares were also checked because they could be a data issue. All 34 cancelled bookings have a fare of $0.00 in this dataset. This may be normal for cancelled bookings, but the company's payment and refund rules would need to be checked before using these numbers in a real financial report.

The most bookings were recorded for Flight ID 6 with 21 bookings, followed by Flight ID 8 with 20 and Flight ID 10 with 19. A minimum of 10 bookings was selected for the HAVING condition. This helps avoid comparing flights with very few bookings because even one no-show can make the percentage look high. Ten bookings is still a small sample, but it was used as a starting point. A total of 12 flights meet this condition, with 194 bookings altogether.

If the minimum was changed from 10 to 15 bookings, some flights would be excluded. For example, Flights 1 and 3 would not be included even though their no-show rates are higher than the overall rate. This shows how changing the minimum booking count can affect which flights are selected for further review.

The data was also grouped by flight_id and booking_country to compare bookings across two categories. This produced 62 flight-country groups. The results show how booking activity and average fares differ depending on the flight and booking country.

These results would be useful for the airline operations manager when deciding which flights need more attention. However, the average fare does not show how much individual ticket prices differ, and the total booking count does not explain the reasons behind cancellations or no-shows. More information about cancellation reasons, booking dates, and booking countries would be needed. A longer period of data would also help determine whether these problems happen regularly.


## Task 4.2: Build the breakdown leadership asked for

### Part A: Conditional Aggregation
Two questions were answered in the same query: How many total bookings does each flight have, and how many of those bookings were passenger no-shows?

COUNT(*) was used to count all bookings, while SUM with CASE WHEN was used to count only the passenger no-shows. Both results were calculated together without using a WHERE clause to remove other bookings.

The results show that Flight ID 2 had 3 no-shows out of 16 bookings (18.75%), and Flight ID 3 had 2 no-shows out of 13 bookings (15.38%). These flights had higher no-show rates than the overall platform rate of 6.00%.

This makes it easier to compare the total bookings and no-shows for each flight without running separate queries.

### Part B: Regional Subtotals and Grand Total

The regional director needs the country totals instead of the detailed results for every flight. ROLLUP was used to show the booking totals and no-shows for each country, along with the overall platform total.

The rows marked "Regional subtotal" show the results for Japan, Korea, Singapore, Thailand, and Vietnam. The row marked "Grand total" shows the combined results for the entire platform.

The grand total includes 200 bookings and 12 passenger no-shows, giving an overall no-show rate of 6.00%.

The country totals help the regional director see which countries may need more attention. The grand total shows the overall no-show rate for the whole platform. This helps leadership decide whether the problem should be reviewed in a specific country or across the entire airline.

### Part C: CTE Analysis Pipeline

The purpose of this query was to answer one question: What is the combined no-show rate for flights with at least 10 bookings?

A CTE was used to calculate the total bookings and passenger no-shows for each flight first. After that, the second part of the query selected only flights with 10 or more bookings and calculated the combined results.

A total of 12 flights met this condition, with 194 bookings and 11 passenger no-shows. The combined no-show rate was 5.67%.

The rate was calculated by dividing the total number of no-shows by the total number of bookings, instead of averaging each flight's individual percentage. This is important because some flights have more bookings than others.

This baseline can be used to compare higher-volume flights and identify which ones may need further investigation.

---

## Reflection

Before Unit 4, most SQL practice was about finding certain rows using SELECT and WHERE. In this assignment, the focus was different. The data was grouped to compare flight activity, and HAVING was used to keep flights with at least 10 bookings. This made the results easier to compare, although 10 bookings is still a small sample.

Conditional aggregation was one of the most useful parts. COUNT(*) showed the total bookings, while SUM with CASE WHEN counted passenger no-shows in the same query. With two separate filtered queries, the results would have to be matched by flight ID. That could take extra time and make it easier to miss something. For a table with one million rows, running separate queries may also repeat a lot of database work. One conditional aggregation query can calculate both numbers together.

ROLLUP was helpful because it showed country subtotals and one platform total without separate queries. The CTE was useful for breaking the calculation into two steps. First, bookings and no-shows were counted for each flight. Then only flights with at least 10 bookings were included in the baseline. This assignment showed how SQL results can help an operations manager decide which flights need more review.

---
