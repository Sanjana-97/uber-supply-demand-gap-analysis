CREATE DATABASE uber_project;
USE uber_project;
drop table uber_data;
CREATE TABLE uber_data (
    request_id INT,
    pickup_point VARCHAR(20),
    driver_id INT NULL,
    status VARCHAR(30),
    request_timestamp DATETIME,
    drop_timestamp DATETIME NULL,
    hour_of_request INT,
    request_time_slot VARCHAR(20),
    trip_duration_mins FLOAT NULL,
    ride_outcome VARCHAR(10),
    request_weekday VARCHAR(15)
);

-- View the first few records from the Uber dataset to understand the structure
SELECT *
FROM uber_data
LIMIT 10;
/* A quick preview of the first 10 rows confirms the dataset structure is intact */


-- Count the total number of ride requests recorded in the dataset
SELECT COUNT(*) AS total_requests
FROM uber_data;
/* Total requests recorded: 6,745 */


-- Group ride requests by outcome to understand success vs failure patterns
SELECT ride_outcome, COUNT(*) AS total_rides,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM uber_data), 2) AS percentage
FROM uber_data
GROUP BY ride_outcome;
/* 42% of rides were successful, while 58% failed, indicating a supply-demand imbalance */


-- Analyze how many requests originated from each pickup location
SELECT pickup_point, COUNT(*) AS total_requests
FROM uber_data
GROUP BY pickup_point
ORDER BY total_requests DESC;
/* City had higher demand (3,507 requests) compared to Airport (3,238) — a nearly even split */


-- Analyze the number of ride requests received at each hour of the day
SELECT hour_of_request, COUNT(*) AS request_count
FROM uber_data
GROUP BY hour_of_request
ORDER BY hour_of_request;
/* Peak request hours were 18–21, with the highest at 18:00 (510 requests). Early morning hours (1–4 AM) saw the least demand */


-- Count total ride requests per weekday to identify high-demand days
SELECT request_weekday, COUNT(*) AS total_requests
FROM uber_data
GROUP BY request_weekday
ORDER BY FIELD(request_weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
/* Demand was fairly consistent across weekdays, with Friday having the highest (1,381) and Tuesday the lowest (1,307) ride requests */


-- Analyze ride outcomes and failure rate by pickup point
SELECT pickup_point, ride_outcome,COUNT(*) AS total_rides,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY pickup_point), 2) AS Failure_Rates
FROM uber_data
GROUP BY pickup_point, ride_outcome;
/* Failure rates are high at both locations, with Airport slightly worse */


-- Analyze how trip success and failure vary by hour of the day
SELECT hour_of_request,
  SUM(CASE WHEN ride_outcome = 'Success' THEN 1 ELSE 0 END) AS successful_rides,
  SUM(CASE WHEN ride_outcome = 'Failed' THEN 1 ELSE 0 END) AS failed_rides
FROM uber_data
GROUP BY hour_of_request
ORDER BY hour_of_request;
/* Failures peak from 5 PM to 9 PM, showing high evening demand-supply gap. Late mornings to afternoons show better success rates */


-- Compare ride outcomes across weekdays to find when failures are highest
SELECT request_weekday,ride_outcome, COUNT(*) AS total_rides
FROM uber_data
GROUP BY request_weekday, ride_outcome
ORDER BY FIELD(request_weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), ride_outcome;
/* Failures are highest on Thursday and Friday, indicating peak pre-weekend demand */


-- Identify how trip completion varies by pickup point and time of day
SELECT pickup_point, request_time_slot, ride_outcome, COUNT(*) AS total_rides
FROM uber_data
GROUP BY pickup_point, request_time_slot, ride_outcome
ORDER BY pickup_point, request_time_slot, ride_outcome desc;
/* At the Airport, failure rates spike in the Evening
In the City, Morning and Early Morning show the most failures, indicating city supply issues during early hours */


-- Compare average trip duration between City and Airport
SELECT pickup_point, ROUND(AVG(trip_duration_mins), 2) AS avg_trip_duration
FROM uber_data
WHERE ride_outcome = 'Success'
GROUP BY pickup_point;
/* Trip duration is almost the same for both pickup points */


-- Find shortest and longest successful trips
SELECT request_id, pickup_point, trip_duration_mins
FROM uber_data
WHERE ride_outcome = 'Success'
ORDER BY trip_duration_mins ASC
LIMIT 5;

SELECT request_id, pickup_point, trip_duration_mins
FROM uber_data
WHERE ride_outcome = 'Success'
ORDER BY trip_duration_mins DESC
LIMIT 5;
/* Despite variations in pickup location, the overall trip duration remains consistent 
However, City trips show a slightly wider range, indicating more variability in trip lengths */








