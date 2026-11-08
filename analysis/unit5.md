# Unit 5: Combining Data with Joins

Theme: Airline Booking

In this dataset, passengers is the actor, flights is the producer, bookings is the event, airports is the catalog, and flight_routes is the junction table.

In Assignment 4, Flights 1, 2, and 3 had higher no-show rates than the baseline (5.67% for flights with 10 or more bookings). In this write-up, I call them the "focus flights."

---

## Task 5.1: Connect Producers to Their Data

### Results

**Q1 (three-table join)**

I joined bookings, passengers, and flights. The query returned all 200 bookings. Each row now shows the passenger name, the flight number, and when the booking was made, so it is easier to read than just ID numbers.

**Q2 (junction table)**

First, I checked which airports the focus flights use.

- Flight 1: HAN, SGN
- Flight 2: NRT, SGN, SIN
- Flight 3: HAN, SIN

There is no airport that all three flights share.

Then I picked SGN (Tan Son Nhat International) as my catalog tag, because it is used by the most flights (9 out of 15). Flights 1 and 2 use SGN, but Flights 5, 8, and 10 also use SGN and they had zero no-shows. So I don't think the airport is the reason for the high no-show rates.

**Q3 (self join)**

I joined the flights table to itself to find flights with the same seat capacity. All three focus flights have 320 seats. The only other 320-seat flights are Flight 4 and Flight 5.

- Flight 4 also had a high no-show rate (16.67%), but it only had 6 bookings.
- Flight 5 had no no-shows.

When I added up the five 320-seat flights, they had 7 of the 12 no-shows on the whole platform (7 out of 64 bookings, 10.94%). The other flights had 5 no-shows out of 136 bookings (3.68%). The focus flights start from different countries (Thailand, Japan, Korea), so seat size looks like a more common point than country. But the dataset is small, so this is just a pattern I noticed. It does not prove that bigger planes cause more no-shows.

### Write-up

**What feature or report on your platform could use the three-table join from Question 1? What information would it display?**

It could be used for a passenger list page for each flight. The operations team or customer service staff could use it to check who booked a flight. The page would show the passenger name, flight number, booking time, booking status, and cancellation reason. This way, staff don't have to look up passenger IDs and flight IDs in different tables.

**Why is the junction table important for answering Question 2? What would make this analysis more difficult without it?**

One flight can stop at several airports, and one airport has many flights. This is a many-to-many relationship. The flight_routes table saves each flight and airport pair as one row, so I could connect flights to airports with two joins.

Without this table, the flights table would need many airport columns (like airport_1, airport_2, airport_3), or one column with a list of airports. Then, to find all SGN flights, I would have to check every column or split the text. It would also be easy to make mistakes when adding or changing data.

---

## Task 5.2: Find Records That Joins May Exclude

### Part A: INNER JOIN and LEFT JOIN

The LEFT JOIN returned 15 flights and the INNER JOIN returned 13 flights. I used COUNT(DISTINCT flight_id) so that a flight with many bookings is only counted once.

**The INNER JOIN excluded 2 flights.**

The two missing flights are:

- Flight 14 (VN214, Vietnam, 303 seats)
- Flight 15 (VN215, Thailand, 132 seats)

They are missing because they don't have any bookings. INNER JOIN only keeps rows that match in both tables, so these flights disappear. LEFT JOIN keeps all flights, so they show up with a booking count of 0.

### Part B: RIGHT JOIN and FULL OUTER JOIN

For the RIGHT JOIN, I switched the table order (bookings RIGHT JOIN flights). To make sure it gives the same result as the LEFT JOIN, I compared the two results with EXCEPT in both directions. Both had 15 rows, and there were 0 rows that appeared in only one of them. So the two queries return the same records.

The FULL OUTER JOIN gave:

- 200 matched rows (13 flights)
- 2 flights without bookings
- 0 bookings without a flight

A FULL OUTER JOIN shows the unmatched rows from both tables at the same time. A LEFT JOIN or RIGHT JOIN only shows the unmatched rows from one side. In my data, there were no bookings without a flight. I think this is because of the foreign key on bookings.flight_id, which does not let a booking use a flight_id that doesn't exist. Even so, running the FULL OUTER JOIN was useful because I could check this with the real data instead of just assuming it.

### Part C: NOT EXISTS and EXCEPT

Both methods found Flights 14 and 15, and my check query showed no difference between them. NOT EXISTS checks each flight one by one, so I can also show other columns like flight_number. EXCEPT takes one list of flight IDs and removes the other list, so both sides need the same columns.

### Write-up

**Which producers were excluded by the inner join? Report their identifiers.**

Flight IDs 14 and 15.

**What does it mean when a producer has no events? What are some possible explanations?**

It means the flight is in the system, but nobody has booked it. Some possible reasons:

- The flight was never opened for sale.
- It is a new or seasonal flight.
- The flight was canceled but nobody changed it to inactive.
- The flight was not set up correctly in the booking system.

I found one clue in the data. Flights 14 and 15 have no rows in flight_routes, which means no airports are connected to them. But Flight 13 also has no routes and still has 11 bookings, so missing routes can't be the full answer.

**How could a report based only on an inner join give leadership an incomplete picture of the platform?**

An inner join report only shows flights that already have bookings. Flights 14 and 15 would not appear at all. Leadership would see 13 flights instead of 15 and might think every flight is being used. Problems like unused planes or setup mistakes would stay hidden.

**Why might leadership want to identify producers who have never been active?**

A flight with no bookings can still cost money, for example for the plane, crew planning, and airport slots, but it brings in no revenue. Also, both flights are marked as active and were first scheduled in 2022 (February and May), but all the bookings in this dataset are from 2023. Having no bookings for that long might mean there is a sales or system problem.

**What action could leadership take based on these findings?**

Leadership could ask the operations team to check Flights 14 and 15. The team should check if each flight is really open for sale, if its route and airports are set up in the system, and if it should still be active. If a flight is not needed anymore, it could be changed to inactive so it doesn't affect future reports.

**Distinguish between what your data shows and what would require further investigation.**

What the data shows: Flights 14 and 15 are marked as active, have no bookings, and have no airports in flight_routes.

What the data doesn't show: why this happened. From the database alone, I can't tell if the flights were never put on sale, if there was a system error, or if there was just no demand. To find the reason, we would need information from outside the database, like sales settings, schedule change records, or talking to the operations team.

---

## Task 5.3: Understand Join Performance and Execution Plans

### Part A: CROSS JOIN

The airports table has 5 rows and the flights table has 15 rows. The CROSS JOIN returned 75 rows, which is 5 × 15 = 75. Every airport was paired with every flight, because a CROSS JOIN has no join condition.

A Cartesian product can be useful when I actually need every possible combination. For example, I could make a list of all flight and airport pairs and then check which pairs don't have a route yet. But it can also be a sign of a mistake. If I forget the ON condition or write it wrong, the number of rows can suddenly get very big. With large tables, this would make the query very slow and the numbers wrong.

### Part B: Execution Plan

I used EXPLAIN and EXPLAIN ANALYZE on the three-table join from Task 5.1 Q1.

**EXPLAIN (Part B-1)**

This only shows the plan and the estimated cost. It does not run the query.

```
Sort  (cost=35.98..36.48 rows=200 width=558)
  Sort Key: b.booked_at, b.booking_id
  ->  Nested Loop  (cost=12.40..28.34 rows=200 width=558)
        ->  Hash Join  (cost=12.25..17.80 rows=200 width=304)
              Hash Cond: (b.passenger_id = p.passenger_id)
              ->  Seq Scan on bookings b  (cost=0.00..5.00 rows=200 width=50)
              ->  Hash  (cost=11.00..11.00 rows=100 width=262)
                    ->  Seq Scan on passengers p  (cost=0.00..11.00 rows=100 width=262)
        ->  Memoize  (cost=0.15..0.41 rows=1 width=262)
              Cache Key: b.flight_id
              Cache Mode: logical
              ->  Index Scan using flights_pkey on flights f  (cost=0.14..0.40 rows=1 width=262)
                    Index Cond: (flight_id = b.flight_id)
```

**EXPLAIN ANALYZE (Part B-2)**

This actually runs the query and also shows the real time, row counts, and loops. This output is from the run in my screenshot.

```
Sort  (cost=35.98..36.48 rows=200 width=558) (actual time=0.197..0.202 rows=200 loops=1)
  Sort Key: b.booked_at, b.booking_id
  Sort Method: quicksort  Memory: 41kB
  ->  Nested Loop  (cost=12.40..28.34 rows=200 width=558) (actual time=0.042..0.127 rows=200 loops=1)
        ->  Hash Join  (cost=12.25..17.80 rows=200 width=304) (actual time=0.033..0.076 rows=200 loops=1)
              Hash Cond: (b.passenger_id = p.passenger_id)
              ->  Seq Scan on bookings b  (cost=0.00..5.00 rows=200 width=50) (actual time=0.011..0.024 rows=200 loops=1)
              ->  Hash  (cost=11.00..11.00 rows=100 width=262) (actual time=0.013..0.013 rows=30 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 10kB
                    ->  Seq Scan on passengers p  (cost=0.00..11.00 rows=100 width=262) (actual time=0.006..0.008 rows=30 loops=1)
        ->  Memoize  (cost=0.15..0.41 rows=1 width=262) (actual time=0.000..0.000 rows=1 loops=200)
              Cache Key: b.flight_id
              Cache Mode: logical
              Hits: 187  Misses: 13  Evictions: 0  Overflows: 0  Memory Usage: 2kB
              ->  Index Scan using flights_pkey on flights f  (cost=0.14..0.40 rows=1 width=262) (actual time=0.001..0.001 rows=1 loops=13)
                    Index Cond: (flight_id = b.flight_id)
Planning Time: 0.151 ms
Execution Time: 0.233 ms
```

The plan was the same in both outputs. EXPLAIN was enough to see which joins PostgreSQL would use, but the real numbers (like 30 passenger rows and 187 cache hits) only show up in EXPLAIN ANALYZE. When I ran EXPLAIN ANALYZE again, the plan and row counts didn't change, but the time was a little different (Planning Time 0.199 ms, Execution Time 0.266 ms). I think this is normal because the query really runs each time, so small time differences don't mean much.

**How I read the plan**

The plan is read from the inside (the most indented lines) to the outside.

1. PostgreSQL read the whole bookings table and the whole passengers table (Seq Scan).
2. It joined them with a **Hash Join**. It put the passengers into a hash table in memory, then matched each of the 200 bookings to it.
3. Then it joined the result to flights with a **Nested Loop**. For each booking, it found the flight using the primary key index (flights_pkey).
4. The Memoize step saved flights it had already found. So it only used the index 13 times (Misses: 13), and the other 187 times it used the saved result (Hits: 187). This 13 is the same as the 13 flights with bookings that I found in Task 5.2.
5. Finally, it sorted the rows (Sort) because of my ORDER BY.

**Why PostgreSQL may have chosen these**

The tables are very small. Bookings has 200 rows, passengers has 30, and flights has 15. Also, bookings has no index on passenger_id or flight_id. Only the primary keys have indexes.

- For passengers, PostgreSQL has to read the whole table anyway, so making one small hash table is cheap. "Batches: 1" and "Memory Usage: 10kB" show that the hash table fit in memory.
- For flights, there is already a primary key index on flight_id, and many bookings have the same flight. So looking up the flight with the index and saving the result was the cheapest way.

**Something I noticed**

PostgreSQL guessed 100 rows for passengers, but the real number was 30. I think this happened because the table statistics were not updated yet. Running ANALYZE on the table should make the guess more accurate.

**What could get slower as the data grows**

- **Seq Scan on bookings:** This is the part I'm most worried about. If bookings has millions of rows, PostgreSQL will read the whole table every time.
- **Sort:** Right now it only uses 41kB of memory. If the data gets bigger than the memory limit, PostgreSQL has to sort using the disk, which is slower.
- **Hash:** If passengers gets much bigger, the hash table might not fit in memory, and it would need more than one batch.

### Write-up

**Give an example of when a Cartesian product could be useful on your platform, or explain why you would not need one.**

It could be useful for route planning. If I CROSS JOIN airports and flights, I get every possible flight and airport pair (75 rows). Then I can compare this list with flight_routes to find airports that no flight goes to, or to check that a new flight is connected to the right airports. For normal booking reports, I wouldn't need it, because every row should be a real booking.

**Which join algorithms did PostgreSQL choose for your query?**

A Hash Join for bookings and passengers, and a Nested Loop (with Memoize and an Index Scan) for joining flights. It did not use a Merge Join.

**What information in the execution plan helps explain those choices?**

- "Seq Scan on bookings" and "Seq Scan on passengers" show that both tables were read completely. This works well with a Hash Join.
- "Batches: 1, Memory Usage: 10kB" shows the hash table was small enough to stay in memory.
- "Index Scan using flights_pkey" shows there was an index on flights that PostgreSQL could use.
- "Hits: 187, Misses: 13" shows that most lookups were for the same 13 flights, so saving the results saved work.
- The low total cost (36.48) and short run time (0.233 ms) show that the data is small.

**Why is it useful to understand the selected join algorithms?**

It helps me understand why a query is fast or slow and which step is doing the most work. For example, a Seq Scan on a big table could be where a query slows down later. If I know this, I can decide what to fix, like adding an index or updating statistics, instead of just guessing.

**What changes to the data or database might make another join algorithm more appropriate?**

- If bookings became very large and I only needed the bookings for one passenger or one flight, an index on bookings.passenger_id or bookings.flight_id would let PostgreSQL find just those rows. Then a Nested Loop with an index would be faster than reading the whole table.
- If both tables in a join were big and already sorted by the join column, PostgreSQL might choose a Merge Join.
- If there were many more different flights, Memoize would have fewer hits, and a Hash Join might become cheaper for the flights join too.

---

## Reflection

Before this unit, I thought PostgreSQL just ran my query the way I wrote it. The execution plan showed me that it actually makes its own choices. In my three-table join, it used a Hash Join for bookings and passengers, and a Nested Loop with an index for flights. These choices make sense because all of my tables are very small, and the whole query only took 0.233 ms.

I think a few changes could make PostgreSQL choose differently. The first one is table size. If bookings had millions of rows, reading the whole table every time would be slow. If passengers also got bigger, the hash table might not fit in memory anymore, and the plan would show more than one batch. The second one is indexes. Right now, bookings has no index on passenger_id or flight_id. If I only wanted the bookings for one passenger and there was an index, a Nested Loop with an Index Scan would probably be faster because it only reads a few rows. An index on booked_at might also help skip the Sort step. The third one is the number of matching rows. Memoize worked well because 200 bookings only used 13 flights. With thousands of flights, it would not save as much. I also learned that statistics matter, because PostgreSQL guessed 100 passengers when there were only 30.
