# Task 6.4: Closing Memo

**To:** Flight Booking Platform Leadership  
**From:** Data Analyst  
**Subject:** Passenger No-show Performance and Recommendations for the Next Quarter  
**Analysis Period:** January–December 2023

## Executive Summary

The analysis indicates that the passenger no-show problem is showing signs of improvement at the quarterly level, although the available data does not establish that this improvement is sustained.

Across 200 recorded bookings in 2023, 12 bookings were associated with the cancellation reason `Passenger no show`, resulting in an overall no-show rate of 6.00%. While quarterly no-show rates consistently decreased throughout the year, monthly results showed considerable fluctuations.

The team should continue monitoring passenger no-shows, investigate the underlying causes, and improve data collection before concluding that the problem has been resolved.

**Supporting Evidence:** [q6_3.sql](../queries/unit6/q6_3.sql) — Supporting Analyses 1, 2, and 3.

## 1. Is the Failure Problem Getting Better or Worse?

### Monthly Performance

The monthly no-show analysis revealed considerable variation throughout 2023. The highest recorded monthly no-show rate occurred in March at 18.18%, representing two no-shows out of 11 bookings.

February, April, October, and November had no recorded passenger no-shows. However, following two consecutive months without recorded no-shows in October and November, the rate increased to 12.50% in December.

These results indicate that the absence of no-shows in a particular month does not necessarily demonstrate sustained improvement. Because monthly booking volumes are relatively small, even one or two additional no-show cases can significantly affect the monthly rate.

**Query Evidence:** 
- [q6_3.sql](../queries/unit6/q6_3.sql) — Supporting Analysis 1: Monthly Passenger No-show Rate.
- [Monthly No-show Rate Results](../screenshots/unit6/6_3_support_monthly_no_show_rate.png)

### Quarterly Performance

To examine whether a broader reporting period would reveal a clearer pattern, I compared passenger no-show rates across calendar quarters.

| Quarter | Total Bookings | No-show Count | No-show Rate |
|---|---:|---:|---:|
| Q1 | 53 | 4 | 7.55% |
| Q2 | 48 | 3 | 6.25% |
| Q3 | 51 | 3 | 5.88% |
| Q4 | 48 | 2 | 4.17% |
| **Total** | **200** | **12** | **6.00%** |

Unlike the monthly results, the quarterly results demonstrated a consistent decrease in the recorded passenger no-show rate.

The rate decreased from 7.55% in Q1 to 4.17% in Q4, representing an improvement of approximately 3.38 percentage points.

This suggests that the failure problem was improving over the observed period at the quarterly level. However, the December increase demonstrates that short-term fluctuations remain a concern.

**Query Evidence:** 
- [q6_3.sql](../queries/unit6/q6_3.sql) — Supporting Analysis 2: Quarterly Passenger No-show Rate.
- [Quarterly No-show Rate Results](../screenshots/unit6/6_3_partB_quarterly_no_show_rate.png)

### Data Limitations

The available dataset contains 200 booking records between January 1 and December 28, 2023, including only 12 recorded passenger no-shows.

Although the quarterly results are encouraging, the limited sample size and observation period make it difficult to determine whether the decrease represents sustained operational improvement or normal variation.

Additionally, the analysis groups bookings by `booked_at`, rather than the actual flight departure date or no-show occurrence date. Therefore, the results represent no-show outcomes associated with booking periods, not necessarily the periods in which the no-shows occurred.

The available evidence also does not establish whether any specific operational intervention caused the observed improvement.

**Query Evidence:** 
- [q6_3.sql](../queries/unit6/q6_3.sql) — Supporting Analyses 1, 2, and 3.
- [Data Coverage Results](../screenshots/unit6/6_3_partB_data_coverage.png)

## 2. What Should the Team Do Next Quarter?

### Recommendation 1: Establish Monthly and Quarterly No-show Monitoring

The team should establish a dashboard that tracks total bookings, passenger no-show counts, no-show rates, and percentage-point changes from previous reporting periods.

Monthly reporting should be used to identify emerging issues, while quarterly reporting should be used to evaluate broader performance trends.

As a provisional benchmark, the team could aim to maintain a quarterly no-show rate at or below the observed Q4 rate of 4.17%. However, both the number of no-shows and the total number of bookings should be reviewed alongside the rate.

**Supporting Evidence:** [q6_3.sql](../queries/unit6/q6_3.sql) - Supporting Analyses 1 and 2 demonstrated that monthly fluctuations can differ substantially from quarterly trends.

### Recommendation 2: Investigate No-show Cases and Test Preventive Measures

The team should review recorded passenger no-show cases to identify potential contributing factors, including booking behavior, communication issues, and passenger confirmation processes.

Based on the findings, the team could pilot pre-departure reminders or booking confirmation notifications and evaluate whether these measures reduce future no-shows.

The current analysis does not establish that communication issues caused the recorded no-shows or that reminders would necessarily prevent them. Therefore, these measures should be tested and evaluated before broader implementation.

**Supporting Evidence:** [q6_3.sql](../queries/unit6/q6_3.sql) - Supporting Analysis 1 identified recurring passenger no-shows, including an increase to 12.50% in December after two months without recorded no-shows.

### Recommendation 3: Improve Data Collection and Expand Historical Coverage

The team should collect additional historical booking records and ensure that actual flight departure timestamps, no-show occurrence dates, and cancellation reasons are consistently recorded.

Additional data would help distinguish sustained improvement from short-term variation and allow the team to evaluate whether preventive measures are effective.

The team should also consider reporting no-show rates by flight departure period, rather than relying exclusively on booking creation dates.

**Supporting Evidence:** [q6_3.sql](../queries/unit6/q6_3.sql) - Supporting Analysis 3 confirmed that the available dataset contains only 200 bookings within a single calendar year. Supporting Analyses 1 and 2 identified only 12 recorded passenger no-shows during that period.

## Final Conclusion

The passenger no-show problem appears to be improving at the quarterly level, with the recorded rate decreasing from 7.55% in Q1 to 4.17% in Q4. However, monthly fluctuations, limited historical coverage, and the small number of recorded no-shows prevent a definitive conclusion about sustained improvement.

Leadership should treat the quarterly decline as an encouraging finding rather than evidence that the failure problem has been resolved.

The priority for the next quarter should be to maintain the observed improvement, investigate recurring no-show cases, test preventive measures, and collect more reliable data to support future operational decisions.

## Supporting SQL Queries

All supporting queries are available in [q6_3.sql](../queries/unit6/q6_3.sql).

- Supporting Analysis 1: Monthly Passenger No-show Rate
- Supporting Analysis 2: Quarterly Passenger No-show Rate
- Supporting Analysis 3: Data Coverage and Limitations

Detailed analytical methods and interpretations are available in [Unit 6 Analysis](unit6.md).
