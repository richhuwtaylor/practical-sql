----------------------------------------------------------------------------
-- Chapter 12: Working with Dates and Times
----------------------------------------------------------------------------

-- 1. Using the New York City taxi data, calculate the length of each ride using
-- the pickup and drop-off timestamps. Sort the query results from the longest
-- ride to the shortest. Do you notice anything about the longest or shortest
-- trips that you might want to ask city officials about?

-- create the taxi trip table:

CREATE TABLE nyc_yellow_taxi_trips (
    trip_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vendor_id text NOT NULL,
    tpep_pickup_datetime timestamptz NOT NULL,
    tpep_dropoff_datetime timestamptz NOT NULL,
    passenger_count integer NOT NULL,
    trip_distance numeric(8,2) NOT NULL,
    pickup_longitude numeric(18,15) NOT NULL,
    pickup_latitude numeric(18,15) NOT NULL,
    rate_code_id text NOT NULL,
    store_and_fwd_flag text NOT NULL,
    dropoff_longitude numeric(18,15) NOT NULL,
    dropoff_latitude numeric(18,15) NOT NULL,
    payment_type text NOT NULL,
    fare_amount numeric(9,2) NOT NULL,
    extra numeric(9,2) NOT NULL,
    mta_tax numeric(5,2) NOT NULL,
    tip_amount numeric(9,2) NOT NULL,
    tolls_amount numeric(9,2) NOT NULL,
    improvement_surcharge numeric(9,2) NOT NULL,
    total_amount numeric(9,2) NOT NULL
);

COPY nyc_yellow_taxi_trips (
    vendor_id,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    pickup_longitude,
    pickup_latitude,
    rate_code_id,
    store_and_fwd_flag,
    dropoff_longitude,
    dropoff_latitude,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount
   )
FROM 'nyc_yellow_taxi_trips.csv'
WITH (FORMAT CSV, HEADER);

CREATE INDEX tpep_pickup_idx
ON nyc_yellow_taxi_trips (tpep_pickup_datetime);

-- calculate the length of each ride:

SELECT
    trip_id,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    tpep_dropoff_datetime - tpep_pickup_datetime AS length_of_ride
FROM nyc_yellow_taxi_trips
ORDER BY length_of_ride DESC;

-- More than 500 trips last more than 10 hours, which seems excessive.
-- Two records have drop-off times before the pickup time.
-- Several have pickup and drop-off times that are the same.
-- It's worth asking whether these records have timestamp errors.

-- 2. Using the AT TIME ZONE keywords, write a query that displays the date and
-- time for London, Johannesburg, Moscow, and Melbourne the moment January 1,
-- 2100, arrives in New York City.

-- We can retrieve the New York utc offset using

SELECT * FROM pg_timezone_names
WHERE name LIKE '%New_York%'
ORDER BY name;

-- which gives us an offset of -4 (during summertime).

SELECT '2100-01-01 00:00:00-05' AT TIME ZONE 'US/Eastern' AS new_york,
       '2100-01-01 00:00:00-05' AT TIME ZONE 'Europe/London' AS london,
       '2100-01-01 00:00:00-05' AT TIME ZONE 'Africa/Johannesburg' AS johannesburg,
       '2100-01-01 00:00:00-05' AT TIME ZONE 'Europe/Moscow' AS moscow,
       '2100-01-01 00:00:00-05' AT TIME ZONE 'Australia/Melbourne' AS melbourne;

-- 3. As a bonus challenge, use the statistics functions in Chapter 11 to
-- calculate the correlation coefficient and r-squared values using trip time
-- and the total_amount column in the New York City taxi data, which represents
-- total amount charged to passengers. Do the same with trip_distance and
-- total_amount. Limit the query to rides that last three hours or less.

SELECT
    round(
          corr(total_amount, (
              date_part('epoch', tpep_dropoff_datetime) -
              date_part('epoch', tpep_pickup_datetime)
                ))::numeric, 2
          ) AS amount_time_corr,
    round(
        regr_r2(total_amount, (
              date_part('epoch', tpep_dropoff_datetime) -
              date_part('epoch', tpep_pickup_datetime)
        ))::numeric, 2
    ) AS amount_time_r2,
    round(
          corr(total_amount, trip_distance)::numeric, 2
          ) AS amount_distance_corr,
    round(
        regr_r2(total_amount, trip_distance)::numeric, 2
    ) AS amount_distance_r2
FROM nyc_yellow_taxi_trips
WHERE tpep_dropoff_datetime - tpep_pickup_datetime <= '3 hours'::interval;

-- | "amount_time_corr" | "amount_time_r2" | "amount_distance_corr" | "amount_distance_r2" |
-- |--------------------|------------------|------------------------|----------------------|
-- | 0.80               | 0.64             | 0.86                   | 0.73                 |

-- Correlation between trip cost and time lengh is strong,
-- correlation between distance and cost is strong, as we would expect.