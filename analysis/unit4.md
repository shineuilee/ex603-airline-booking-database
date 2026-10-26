# EX603 - Project Assignment 4: From Rows to Insight

## Task 4.1 and Task 4.2, plus the reflection

### 1.1 Platform Baseline Statistics (Task 4.1.1)
* **Total Volume:** The dataset contains exactly 200 booking transactions across all records.
* **Financial Overview:** Total gross revenue generated across the entire platform is $3,747.01, with an average ticket fare of $18.74. Fares range from a minimum of $0.00 to a maximum of $70.86. The $0.00 entries represent cancelled bookings where the fare was either waived or fully credited.
* **Customer Distribution:** A total of 30 unique passengers (passenger_id) accounted for these 200 bookings, indicating substantial repeat reservation activity across the customer base.

### 1.2 Per-Producer Activity & Volume Threshold (Task 4.1.2 & 4.1.3)
* Booking volume is unevenly distributed among the 13 distinct flights (flight_id). Flight 6 recorded the highest volume with 21 bookings, followed closely by Flight 8 with 20 bookings and Flight 10 with 19 bookings.
* To avoid statistical distortion from low-volume routes, I applied a threshold filter using HAVING COUNT(*) >= 15. 
* Across the 13 flights, the average volume per route is approximately 15.38 bookings. Flights with fewer than 15 bookings (such as Flight 4 with only 6 bookings) have small sample sizes where a single extreme ticket price can heavily bias the calculated average fare. 
* Filtering with COUNT(*) >= 15 isolated the 8 most active flights (Flights 6, 8, 10, 11, 12, 5, 2, and 7), providing a more reliable foundation for performance comparison.

### 1.3 Multi-dimensional Grouping & Hierarchical ROLLUP (Task 4.1.4 & 4.2.2)
* Grouping across both flight and booking country (GROUP BY flight_id, booking_country) split the platform's activity into 62 distinct sub-segments.
* Implementing ROLLUP(flight_id, booking_country) generated a structured analytical hierarchy in a single execution pass. Rather than running separate queries to compute route-country intersections, individual route totals, and platform-wide sums, ROLLUP generated:
  1. The 62 granular flight-country combinations.
  2. Subtotals for each flight route (where region is NULL).
  3. A platform grand total row (where both producer_id and region are NULL), confirming the 200 bookings and $3,747.01 total revenue.

### 1.4 Single-Pass Failure Analysis & Net Revenue (Task 4.2.1)
* Using conditional aggregation inside aggregate functions (COUNT(CASE WHEN booking_status = 'cancelled' THEN 1 END)), I calculated completed versus cancelled bookings and net revenue without repeatedly scanning the table.
* The failure rate varies dramatically across flights:
  * **Critical Outlier:** Flight 11 logged 16 bookings, but 5 were cancelled, yielding an exceptionally high failure rate of 31.25%.
  * **Top Reliability:** Flight 10 processed 19 bookings with 0 cancellations (0.00% failure rate), capturing $393.88 in net revenue.
  * **Top Commercial Producer:** Flight 8 generated $473.08 in gross revenue with only 1 cancellation (5.00% failure rate), retaining $447.85 in net revenue.

---

## 2. Personal Reflection

Working through Unit 4 provided a valuable shift from simply filtering rows to thinking about database execution efficiency and analytical data modeling. In previous assignments, SQL felt primarily like retrieving existing rows using WHERE. In this assignment, using GROUP BY, HAVING, and conditional expressions required structuring queries around real business metrics and understanding how PostgreSQL processes data at each stage.

One important concept I worked through was the distinction between WHERE and HAVING. Understanding that WHERE filters rows before grouping happens, while HAVING filters aggregated values after grouping, made it clear why setting our volume threshold (HAVING COUNT(*) >= 15) had to be handled at the group level. Choosing 15 based on the dataset average of 15.38 bookings helped me see how small sample sizes can easily distort route averages if low-volume groups are not isolated.

Learning single-pass conditional aggregation with CASE expressions was another highlight. Previously, I might have considered writing separate queries or subqueries to get total bookings, cancellations, and net revenue, and then joining them. Calculating all three metrics in a single pass over the table is far more efficient and prevents unnecessary table scans. Similarly, using ROLLUP demonstrated how SQL can directly deliver hierarchical reporting data—like subtotals and grand totals—without requiring application-level data manipulation. Overall, this assignment helped bridge the gap between technical SQL syntax and meaningful backend data reporting.

---

## 3. Query Catalogue & Screenshot Index

| Requirement | Query File | Description | Screenshot Reference |
| :--- | :--- | :--- | :--- |
| **Task 4.1.1** | queries/unit4/q4_1.sql | Platform Baseline Statistics | screenshots/unit4/task4.1.1.png |
| **Task 4.1.2** | queries/unit4/q4_1.sql | Per-Producer Activity & Average Fare | screenshots/unit4/task4.1.2.png |
| **Task 4.1.3** | queries/unit4/q4_1.sql | Volume Filtering (HAVING >= 15) | screenshots/unit4/task4.1.3.png |
| **Task 4.1.4** | queries/unit4/q4_1.sql | Multi-dimensional Grouping (Flight & Region) | screenshots/unit4/task4.1.4.png |
| **Task 4.2.1** | queries/unit4/q4_2.sql | Single-Pass Cancellation Rate & Net Revenue | screenshots/unit4/task4.2.1.png |
| **Task 4.2.2** | queries/unit4/q4_2.sql | Hierarchical Aggregation with ROLLUP | screenshots/unit4/task4.2.2.png |
| **Task 4.2.3** | queries/unit4/q4_2.sql | CTE Pipeline Comparing Producers to Baseline | screenshots/unit4/task4.2.3.png |

> *\*Note on Task 4.2.3 Screen Captures:*  
> Because the CTE pipeline query is quite lengthy, the main capture (task4.2.3.png) shows the active query execution environment. For full visibility without editor height constraints, please refer to:
> - screenshots/task4.2.3_query.png: Displays the complete, uncut SQL query code.
> - screenshots/task4.2.3_output.png: Displays the full Data Output result table.
