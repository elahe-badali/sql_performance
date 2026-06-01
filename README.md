# HW01-B — SQL Performance and Metabase Dashboard

This project turns a slow, join-heavy Airbnb analytics query into a fast workflow. The notebook connects to the shared QBC12 PostgreSQL database, inspects the source tables, builds a baseline neighbourhood summary query, measures its latency, reviews the execution plan, and then creates a materialized view. 

## How to Run

1. Create and activate your Python environment.
2. Install the required packages:

```bash
pip install pandas sqlalchemy psycopg2-binary jupyter
```

3. Start Jupyter:

```bash
jupyter notebook
```

4. Open the notebook and run all cells from top to bottom.
5. Confirm that the required files are generated under `sql/` and `reports/`.


## SQL Workflow

The notebook builds the assignment in these steps:

1. **Inspect source tables**  
   It checks table columns and row counts for `core.listing`, `core.calendar_day`, and `core.review`.

2. **Create student schema**  
   It creates the schema named `student_<student_id>` and keeps all database writes inside that schema.

3. **Build baseline SQL**  
   In this step, we build the main SQL query for the neighbourhood summary.
   We use CTEs to make the query easier to read and test.

   `calendar_30`
   This part gets data for the first 30 calendar days.
   It calculates the availability rate for each listing.
   `review_counts`
   This part counts the number of reviews for each listing.
   It gives one total review number per listing.
   `listing_enriched`
   This part joins listing data with review data and calendar data.
   We use left join so listings without reviews are still included.
   `Final summary`
   In the last part, we group listings by neighbourhood.
   We calculate number of listings, average price, median price, average minimum nights, total reviews, reviews per listing, and availability rate.

   Finally, we save the SQL query in sql/01_baseline_neighbourhood_summary.sql.
   
4. **Measure baseline latency**  
   The goal of this cell is to measure how fast or slow the baseline query runs. Later, we can compare this time with the materialized view query.

   We run `EXPLAIN (ANALYZE, BUFFERS)` on the baseline query and save the result in `reports/baseline_explain_analyze.txt`.

   The plan shows that the baseline query has some expensive steps.
   PostgreSQL needs to join tables, sort data, group rows by neighbourhood, and read many review rows.
   These steps make the query slower.

   The final `GroupAggregate` step took about **406 ms**.
   This means the final neighbourhood aggregation needed extra processing time.

   Because of this, we create a materialized view later.
   The materialized view stores the final summary in advance, so the dashboard can read the data faster.


5. **Create the materialized view**
   We create a materialized view named:

```text
student_<student_id>.mv_airbnb_neighbourhood_summary
```

It stores the result of the baseline query.
This helps the dashboard read prepared data faster.

We also add indexes on `neighbourhood` and `num_listings`.
These indexes help filtering and sorting run faster.



6. **Compare dashboard latency**  
   It compares the direct baseline query against the materialized-view read and reports the speedup.
   The baseline query took about `0.36` seconds in the best run.
   The materialized view took about `0.08` seconds in the best run.

   The materialized view is about `4.66x` faster.
   This shows that storing the prepared summary helps the dashboard read data much faster.
