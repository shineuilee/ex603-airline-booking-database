# Task 3.4: Write the Finding

The dashboard reported only 22 valid bookings, making it seem like almost all customers cancelled or missed their flights. 
However, the database actually contained 188 valid bookings out of 200 total records, with only 12 true passenger no-shows.
The dashboard missed 166 completed bookings simply because those records had empty cancellation reasons.

This happened because of how the dashboard filters empty fields. For passengers who completed their trips normally, the cancellation reason was left blank. 
The dashboard searched for bookings where the note was not "Passenger no show", but it accidentally ignored all rows where the note was completely empty. 
Instead of treating a blank note as a normal completed flight, the system dropped them completely.
As a result, only records with actual cancellation notes were counted. 

Because 188 bookings were actually completed without any issues, the frozen payout should be released to the partners immediately. 
The low number was caused by a reporting error in the filter, not by failed services or partner issues. 
The filter has now been updated to include empty cancellation fields, so future dashboard reports will show the correct numbers. 
