## Task 6.1: Compute Across a Window Without Collapsing

### Q1. Comparing Individual Booking Fares with Flight Averages

**Business Question:** Which bookings have unusually high or low fares compared with the average fare of their respective flights?

In my flight booking platform, knowing the average fare of each flight is useful, but it does not tell us how much an individual passenger paid compared with other passengers on the same flight. I used `AVG(fare_paid) OVER (PARTITION BY flight_id)` to calculate the average fare for each flight while preserving individual booking records.

The window function returned 200 rows, while the `GROUP BY` query returned only 13 rows. Although the average fares were consistent between the two queries, the `GROUP BY` query removed individual booking details.

For example, booking 1 had a fare of 19.74, while the average fare for flight 1 was 16.03. The individual booking was therefore 3.71 above its flight average. In contrast, booking 2 had a fare of 7.40, which was 8.63 below the same flight average.

The `GROUP BY` result alone cannot answer this business question because it does not show which individual bookings contributed to the average or how far each booking deviated from it. Preserving individual records allows the platform to identify unusual fares and investigate potential pricing inconsistencies, discounts, or other factors affecting booking fares.

### Q2. Ranking Flights and Handling Ties

**Business Question:** How should the platform rank flights based on booking volume when multiple flights have the same number of bookings?

A flight popularity leaderboard could use ranking functions to help management identify flights with higher booking demand and support marketing and resource allocation decisions.

The results demonstrated how the three ranking functions handle ties differently. Flights VN205 and VN207 both had 18 bookings.

| Flight | Booking Count | ROW_NUMBER | RANK | DENSE_RANK |
|---|---:|---:|---:|---:|
| VN206 | 21 | 1 | 1 | 1 |
| VN208 | 20 | 2 | 2 | 2 |
| VN210 | 19 | 3 | 3 | 3 |
| VN205 | 18 | 4 | 4 | 4 |
| VN207 | 18 | 5 | 4 | 4 |
| VN212 | 17 | 6 | 6 | 5 |

`ROW_NUMBER()` assigned different positions to VN205 and VN207 even though they had the same booking count. `RANK()` assigned both flights fourth place and skipped fifth place. `DENSE_RANK()` also assigned both flights fourth place but continued with fifth place without leaving a gap.

For a flight popularity leaderboard, I would choose `DENSE_RANK()` because flights with the same booking volume should receive the same recognition. It also provides consecutive ranking positions, making the leaderboard easier to interpret.

Although `ROW_NUMBER()` would be useful when the platform needs an exact number of flights for a limited display, it would not be my first choice for a popularity leaderboard because assigning different ranks to equally popular flights could be misleading.

### Q3. Dividing Flights into Four Performance Bands

I used `NTILE(4)` to divide all 15 flights into four performance bands based on booking volume. The resulting bands contained four, four, four, and three flights, respectively.

However, the results revealed a limitation of using `NTILE()` for performance classification. Flights VN205 and VN207 both had 18 bookings, but VN205 was assigned to Band 1 while VN207 was assigned to Band 2.

The validation query confirmed that two flights with the same booking count of 18 were distributed across two different performance bands.

This occurred because `NTILE()` attempts to distribute rows into approximately equal-sized groups rather than preserve ties. I used `flight_id` as a secondary ordering criterion to make the assignment deterministic, but this does not eliminate the difference in classification.

If these performance bands were used to allocate marketing resources or determine performance incentives, treating equally performing flights differently could create an unfair outcome. Therefore, I would use `NTILE()` when approximately equal-sized groups are important, but I would consider a tie-preserving classification method when equal performance should receive equal treatment.

## Task 6.2: Compare Each Row to Its Neighbors

### Part A. Row-to-Row Comparison

**Business Question:** How does each booking fare change compared with the previous and next booking for the same flight?

I used `LAG()` and `LEAD()` to compare booking fares within each flight, ordered by booking timestamp and booking ID. I selected flight 1 for the final output, which returned 11 booking records.

The fare delta represents the difference between the current booking fare and the previous booking fare. A positive delta indicates an increase, while a negative delta indicates a decrease.

For example, the fare increased from 7.40 to 29.07 between two consecutive bookings, resulting in a positive delta of 21.67. The following booking had a fare of 7.07, resulting in a negative delta of 22.00.

A large delta could indicate a significant change in pricing, a promotional discount, a change in fare class, or a potential data quality issue. However, the delta alone cannot explain why the fare changed.

Management should investigate large fare changes by reviewing the associated booking records, pricing rules, promotional activities, and cancellation or refund information before deciding whether corrective action is necessary.

The first booking has a NULL previous fare, and the last booking has a NULL next fare because there are no preceding or following records, respectively.

### Part B. Cumulative and Smoothed Fare Analysis

**Business Question:** How does the cumulative recorded fare change over time, and how close does the platform get to its fare target?

I used a running total to track cumulative recorded fares across all 200 bookings in chronological order.

A regular `SUM()` returns the final total but does not show how that total accumulated over time. In contrast, a running total allows management to monitor progress at each booking, identify periods of slower accumulation, and determine whether the platform is approaching its target.

For this analysis, I selected an illustrative cumulative fare target of 50,000. This is an analytical benchmark rather than a confirmed organizational revenue target.

The final results were:

| Metric | Result |
|---|---:|
| Total Bookings | 200 |
| Fare Target | 50,000.00 |
| Final Running Total | 3,628.19 |
| Target Progress | 7.26% |
| Remaining to Target | 46,371.81 |
| Final Seven-Booking Moving Average | 24.86 |

The platform reached only 7.26% of the illustrative target within the available dataset. However, this result alone does not establish poor business performance because the dataset is limited and the target was selected for analytical purposes.

#### Moving-Average Window Selection

I selected a seven-booking moving average using `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW`.

A single booking fare can fluctuate considerably, making it difficult to identify broader pricing patterns. A seven-booking window provides some smoothing while remaining responsive to recent changes.

A smaller window, such as three bookings, would react more quickly to sudden fare changes but would also be more sensitive to individual unusually high or low fares. A larger window, such as 30 bookings, would provide a smoother trend but could delay the detection of recent changes.

It is important to distinguish seven bookings from seven calendar days. Since bookings do not necessarily occur every day, the seven-booking moving average may cover a much longer period than seven days. During the first six bookings, the calculation uses the current booking and all available preceding bookings.

#### ROWS versus RANGE

`ROWS` defines the window frame using individual row positions, while `RANGE` defines it using the values of the ordering expression and can include multiple rows with the same ordering value.

For example, if two bookings have the same timestamp and the window is ordered only by that timestamp, a cumulative `RANGE` frame may include both bookings at once, while a cumulative `ROWS` frame processes them according to their individual row positions. I included `booking_id` as a secondary ordering criterion to ensure deterministic ordering.

### Part C. Detecting Booking Gaps

**Business Question:** Which flights have periods of at least 30 days between consecutive recorded bookings?

I used `LAG()` to retrieve the previous booking timestamp for each flight. A CTE calculated the difference between consecutive booking timestamps, and the outer query filtered the results to retain only gaps of at least 30 days.

The query identified 50 booking gaps that met this condition.

The five longest gaps were:

| Flight ID | Booking Gap (Days) |
|---|---:|
| 9 | 112.58 |
| 12 | 106.74 |
| 5 | 93.01 |
| 11 | 89.47 |
| 2 | 86.63 |

Flight 9 had the longest recorded booking gap of approximately 112.58 days, between January 5 and April 28, 2023.

In my platform, a gap represents a period without recorded bookings for a particular flight. However, it does not necessarily indicate that the flight stopped operating or that passengers stopped using the platform.

The gap could reflect a genuine decrease in booking activity, missing booking records, seasonal demand, or the way the available dataset was collected.

Based on the available data, I can confirm that these are gaps in recorded booking activity, but I cannot determine their underlying cause. The booking timestamps alone do not provide sufficient evidence to distinguish an actual interruption in activity from a data collection issue.

Management should compare these gaps with flight schedules, booking system logs, and more complete historical booking records. If the gap reflects missing data, the appropriate response would be to investigate data collection and integration processes. If it reflects an actual decrease in demand, management could review pricing, marketing strategies, or flight availability.

## Task 6.3: Build the Reporting Patterns

### Part A. Top Three Bookings per Flight

**Business Question:** Which three bookings have the highest recorded fares for each flight, and how do they compare with the highest fare for that flight?

I used `ROW_NUMBER()` partitioned by `flight_id` to rank individual bookings by fare in descending order. A CTE was used to calculate the rankings before filtering the results to retain the top three bookings per flight.

I also used `FIRST_VALUE()` to retrieve the highest fare within each flight and calculated the difference between that fare and each selected booking fare.

The query returned 39 records, representing three bookings for each of the 13 flights with recorded bookings. Although the platform contains 15 flights, flights VN214 and VN215 had no booking records and therefore did not appear in the results.

For example, the three highest recorded fares for flight VN201 were:

| Booking ID | Fare Paid | Fare Rank | Highest Fare | Difference from Top |
|---|---:|---:|---:|---:|
| 10 | 29.07 | 1 | 29.07 | 0.00 |
| 7 | 26.17 | 2 | 29.07 | 2.90 |
| 11 | 22.46 | 3 | 29.07 | 6.61 |

#### Platform Feature and Top-N Selection

This reporting pattern could support a premium-fare monitoring dashboard that allows management to review the three highest-fare bookings for each flight.

Displaying only the highest-fare booking would provide limited information and could make the analysis overly dependent on a single unusual transaction. Displaying ten bookings could introduce unnecessary detail, especially for flights with relatively few bookings.

Three bookings provide a practical balance between simplicity and useful comparison. Management can examine whether the highest fare is consistent with other relatively high fares or represents an unusual transaction that requires further investigation.

#### Tie-Handling Policy

I selected `ROW_NUMBER()` because the dashboard is intended to display a maximum of three bookings per flight. If multiple bookings have the same fare at the third position, the booking with the lower `booking_id` receives the earlier position.

This secondary ordering criterion provides a deterministic result. It does not imply that one booking has greater financial value than another booking with the same fare.

Unlike the flight popularity leaderboard in Task 6.1, where equally performing flights should receive equal recognition, this feature prioritizes a consistent display size. Therefore, `ROW_NUMBER()` is more appropriate for this particular reporting requirement.

### Part B. Month-over-Month Comparison

**Business Question:** How do monthly booking volume and total recorded fares change compared with the previous calendar month?

I grouped booking records by calendar month using `DATE_TRUNC('month', booked_at)` and calculated monthly booking counts and total recorded fares.

I then used `LAG()` to retrieve the previous month's values and calculated the percentage change in both booking volume and total fare. `NULLIF()` was used to prevent division-by-zero errors.

To ensure that `LAG()` compares consecutive calendar months rather than simply consecutive available rows, I created a complete monthly calendar using `GENERATE_SERIES()` and joined it with the monthly booking results.

The query returned 12 months, from January through December 2023. All `missing_month_flag` values were false, indicating that every calendar month within the observed date range contained booking records.

The most significant month-over-month changes were:

| Metric | Month | Percentage Change |
|---|---|---:|
| Largest Booking Volume Decrease | March | -47.62% |
| Largest Booking Volume Increase | May | +54.55% |
| Largest Total Fare Decrease | March | -70.01% |
| Largest Total Fare Increase | April | +91.02% |

March showed a significant decrease in both booking volume and total recorded fares. Booking volume decreased from 21 to 11, while total recorded fares decreased from 453.44 to 135.98.

An interesting observation occurred in April. Booking volume remained unchanged at 11 bookings, but total recorded fares increased from 135.98 to 259.75, representing a 91.02% increase.

This demonstrates that booking volume and recorded fares do not necessarily change in the same direction or at the same rate. A platform may generate higher recorded fares without increasing its number of bookings.

#### Business Implications and Recommended Actions

A large month-over-month decrease in booking volume could indicate lower customer demand, seasonal changes, reduced flight availability, or a problem with the booking process. A large change in total recorded fares could also reflect changes in pricing, discounts, cancellations, or the composition of bookings.

Management should investigate significant changes by reviewing individual flight performance, fare distributions, cancellation records, and booking system activity.

For example, the decrease observed in March should prompt an investigation into whether the decline was associated with fewer available flights, lower demand, pricing changes, or data quality issues. The increase in April's total recorded fares, despite unchanged booking volume, should prompt a review of the fare composition rather than an assumption that customer demand increased.

These metrics are useful because they identify specific periods that require investigation and support more informed operational decisions.

### Supporting Analysis 1. Monthly Passenger No-show Rate

**Business Question:** Is the passenger no-show rate improving or worsening over time?

Booking volume and total recorded fares provide useful information about platform activity, but they do not directly measure whether passengers are successfully completing their bookings.

To support the Task 6.4 closing memo, I selected passenger no-shows as a specific recorded failure category.

I defined the no-show rate as the number of bookings with a cancellation reason of `Passenger no show` divided by the total number of recorded bookings within the same booking month.

I used a complete monthly calendar, calculated the monthly no-show rate, and used `LAG()` to compare each month with the previous month. The difference between consecutive rates was expressed in percentage points rather than relative percentage change.

| Booking Month | Total Bookings | No-show Count | No-show Rate |
|---|---:|---:|---:|
| January | 21 | 2 | 9.52% |
| February | 21 | 0 | 0.00% |
| March | 11 | 2 | 18.18% |
| April | 11 | 0 | 0.00% |
| May | 17 | 2 | 11.76% |
| June | 20 | 1 | 5.00% |
| July | 17 | 1 | 5.88% |
| August | 18 | 1 | 5.56% |
| September | 16 | 1 | 6.25% |
| October | 18 | 0 | 0.00% |
| November | 14 | 0 | 0.00% |
| December | 16 | 2 | 12.50% |
| **Total** | **200** | **12** | **6.00%** |

The monthly results showed considerable fluctuations rather than a consistent downward trend. March had the highest no-show rate of 18.18%, while February, April, October, and November had no recorded passenger no-shows.

Although October and November showed encouraging results, the no-show rate increased to 12.50% in December.

These results suggest that a single month with a low or zero no-show rate should not automatically be interpreted as sustained improvement. Monthly booking counts are relatively small, so even one or two additional no-show cases can substantially affect the calculated rate.

### Supporting Analysis 2. Quarterly Passenger No-show Rate

**Business Question:** Does grouping bookings by quarter reveal a clearer pattern in the passenger no-show rate?

Because the monthly results fluctuated considerably, I grouped bookings into calendar quarters to examine whether a broader time interval would reveal a more consistent pattern.

I calculated the quarterly no-show rate using the total number of recorded no-shows divided by the total number of bookings within each quarter. I then used `LAG()` to compare each quarter with the previous quarter.

| Quarter | Total Bookings | No-show Count | No-show Rate | Change (Percentage Points) |
|---|---:|---:|---:|---:|
| Q1 | 53 | 4 | 7.55% | N/A |
| Q2 | 48 | 3 | 6.25% | -1.30 |
| Q3 | 51 | 3 | 5.88% | -0.37 |
| Q4 | 48 | 2 | 4.17% | -1.72 |

Unlike the monthly analysis, the quarterly results showed a consistent decrease in the recorded no-show rate throughout 2023.

The rate decreased from 7.55% in the first quarter to 4.17% in the fourth quarter, representing a decrease of approximately 3.38 percentage points.

Quarterly aggregation provides a broader view of the observed pattern and reduces the influence of individual monthly fluctuations. However, it can also conceal short-term increases, such as the increase observed in December.

Therefore, I would use both monthly and quarterly reporting. Monthly reporting can help identify emerging operational issues, while quarterly reporting can help management evaluate broader performance patterns.

### Supporting Analysis 3. Data Coverage and Limitations

**Business Question:** Does the available dataset provide sufficient evidence to establish sustained improvement in the passenger no-show rate?

I used `MIN(booked_at)`, `MAX(booked_at)`, and `COUNT(*)` to verify the date range and size of the available booking dataset.

| Data Coverage Metric | Result |
|---|---|
| First Recorded Booking | January 1, 2023, 15:48 |
| Last Recorded Booking | December 28, 2023, 02:28 |
| Total Recorded Bookings | 200 |
| Total Recorded Passenger No-shows | 12 |
| Overall Recorded No-show Rate | 6.00% |

The dataset covers nearly one calendar year and contains 200 booking records, including only 12 recorded passenger no-shows.

Although the quarterly analysis suggests improvement, the limited number of no-show cases makes it difficult to determine whether the observed decrease represents a sustained operational improvement or normal variation within a relatively small dataset.

Another limitation is that the analysis groups records by `booked_at`, which represents the booking creation timestamp rather than the actual flight departure date or the date on which the passenger failed to appear. Therefore, the results describe no-show outcomes associated with booking periods rather than the actual timing of no-show incidents.

The analysis also does not establish whether any specific operational intervention caused the observed decrease.

Additional historical booking records, flight departure information, actual no-show timestamps, and information about operational changes would help determine whether the observed improvement is sustained and whether specific interventions contributed to it.

These supporting analyses provide the quantitative evidence and limitations used in the Task 6.4 closing memo.

## Reflection

One reporting question in my flight booking platform that would be difficult to answer using `GROUP BY` alone is whether an individual booking fare is unusually high or low compared with both the flight's average fare and the previous booking fare for the same flight.

Although `GROUP BY` can calculate the average fare for each flight, it collapses individual booking records into aggregated rows. In my Task 6.1 analysis, the `GROUP BY` query returned only 13 rows, while the window function preserved all 200 booking records. Without preserving individual records, management cannot directly identify which bookings deviate from the average or examine how fares change between consecutive bookings.

Window functions make this analysis easier by allowing individual and aggregated information to appear together. Using `AVG()` with `PARTITION BY flight_id` provides the flight average, while `LAG()` provides the previous booking fare. For example, booking 1 had a fare of 19.74, which was 3.71 above its flight average of 16.03. Combining these window functions would allow management to investigate unusual pricing patterns without losing individual booking details.

Through this assignment, I learned that the choice between aggregate and window functions depends on the business question and the level of detail required. Window functions are particularly valuable when individual records need to be evaluated within a broader context rather than summarized into a single value.
