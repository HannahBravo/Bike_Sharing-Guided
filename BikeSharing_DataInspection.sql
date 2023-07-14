/* Data Inspection */
-- We want to get into cleaning the data, but first we need to assess what needs to be done.

/* Identifying Missing Data */
SELECT * 
FROM trip_data
WHERE start_station_name IS NULL;
-- Ruh roh, 136,532 rows of NULL values, let's check the start_station_id is missing for all of those.

SELECT * 
FROM trip_data
WHERE start_station_id IS NULL;
-- 137,158 rows, so 626 rows where we have the station name, but not satition_id.

SELECT * 
FROM trip_data
WHERE start_station_name IS NOT NULL
	AND start_station_id IS NULL;

-- Let's see about end_station_name/id
SELECT * 
FROM trip_data
WHERE end_station_name IS NULL;
-- 158,179 rows

SELECT * 
FROM trip_data
WHERE end_station_id IS NULL;
-- 158,640 rows

-- Let's look for more missing data
SELECT *
FROM trip_data
WHERE end_lat IS NULL
	OR end_lng IS NULL;
-- 4894 rows

/*
Interesting, there were no null values for start_lat/lng. There is no station name/id for these missing 
values either, looks like we'll have to exclude these entries.
*/

/* Inconsistent Data */

SELECT 
	DISTINCT start_station_name
FROM trip_data;
-- Interesting, there are a total of 714 'distinct' start_station_names, there should only be 692 stations listed.

SELECT *
FROM trip_data
WHERE start_station_name = 'WATSON TESTING - DIVVY';
-- This station will be excluded, seems like test data rather than customer data

SELECT *
FROM trip_data
WHERE start_station_name = 'Base - 2132 W Hubbard Warehouse';
-- 26 rows, looks like a station that can be excluded, seems to be company tests rather than customer rides.

-- Let's look for potential test data
SELECT 
	DISTINCT start_station_name
FROM trip_data
WHERE start_station_name ILIKE '%test%';

SELECT *
FROM trip_data
WHERE start_station_name = 'Burling St (Halsted) & Diversey Pkwy (Temp)';
-- These two stations are the same, this *temp status seems to be for dates 4/2020 - 9/2020

SELECT *
FROM trip_data
WHERE start_station_name = 'Burling St & Diversey Pkwy';
-- The station id for this station changes to an inconsistent convention beginning in 2021.

SELECT *
FROM trip_data
WHERE start_station_name = 'Damen Ave & Walnut (Lake) St';
-- Damen Ave & Walnut (Lake) St (*) is the same station 

SELECT *
FROM trip_data
WHERE start_station_name = 'Eggleston Ave & 69th St (*)';
-- The asterik can be removed, same station as Eggleston Ave & 69th St

SELECT *
FROM trip_data
WHERE start_station_name = 'hubbard_test_lws';
-- Trip data for this station name and HUBBARD ST BIKE CHECKING (LBS-WH-TEST) can be excluded.

SELECT *
FROM trip_data
WHERE start_station_name = 'Leavitt St & Belmont Ave (*)';
-- The asterik can be removed, same station as Leavitt St & Belmont Ave.

SELECT *
FROM trip_data
WHERE start_station_name = 'Leavitt St & Division St (*)';
-- Asterik can be removed, same staion as Leavitt St & Division St

SELECT *
FROM trip_data
WHERE start_station_name = 'Malcolm X College';
-- Can be combined with Malcolm X College Vaccination Site, same station id

SELECT *
FROM trip_data
WHERE start_station_name = 'Throop St & Taylor St';
-- Can be combined with Throop (Loomis) St & Taylor St, same station id

SELECT *
FROM trip_data
WHERE start_station_name = 'WATSON TESTING - DIVVY';
-- Data can be excluded, seems to be testing rather than customer data

SELECT *
FROM trip_data
WHERE start_station_name = 'Wentworth Ave & Cermak Rd (Temp)';
-- Can be combined with Wentworth Ave & Cermak Rd, same station name 

SELECT *
FROM trip_data
WHERE start_station_name = 'Western Ave & 28th St';
-- Can be combined with Western & 28th - Velasquez Institute Vaccination Site, 2021 station id's match "KA1504000168"

SELECT *
FROM trip_data
WHERE start_station_name = 'Wood St & Taylor St (Temp)';
-- Can be combined with Wood St & Taylor St, same station id

/* Illogical Trip Duration */

SELECT
	started_at,
	ended_at
FROM trip_data
WHERE ended_at <= started_at;
-- 10,533 which is 0.2% of the data and will need to be excluded since there's no way of reconciling it

/* Unexpected Values */

-- The ride_id for each trip is supposed to be a 16 item alphanumeric code
SELECT *
FROM trip_data
WHERE length(ride_id) < 16
	OR length(ride_id) > 16
GROUP BY ride_id;
-- 19 rows, they all seem to ccur in 4/2020. We'll exclude these instances. 

SELECT
	start_station_name,
	end_station_name,
	(ended_at - started_at) AS trip_duration,
	member_casual
FROM trip_data
WHERE (ended_at - started_at) >= '24:00:00'
GROUP BY member_casual, trip_duration, start_station_name, end_station_name;
-- Wow, almost 3k rows with 2,825 of those instances being casual riders
-- longest duration for a casual rider = 38 days & 16 hrs
-- longest duration for a member rider = 40 days & 18 hrs
-- interestingly enough, there are a lot of instances where the end station is a test site.