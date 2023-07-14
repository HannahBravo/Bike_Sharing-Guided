/* Data Cleaning */
-- Okay, now that we know what to fix, let's get to it!

/* Protecting the Data */

-- Let's export the combined dataset so we have a saved version before making changes
COPY trip_data
TO '/Users/hannahbdr/Desktop/DataAnalysis/Portfolio/04_2020_2021_tripdata.csv'
WITH (FORMAT CSV, HEADER);

-- Cool, now that we have a saved copy, let's begin our modifications

/* Missing Data */

-- Filling in information
SELECT
	start_station_name,
	start_station_id,
	start_lat,
	start_lng
FROM trip_data
WHERE start_station_name IS NULL;
/* 
Unfortunately, there is close to 136,532 rows of missing information for station name AND station id. The latitude and 
longitude information for those rows are also incomplete (some rounded to the nearest 10th, others to the nearest 100th 
which isn't accurate enough). Luckily, this only accounts for ~3% of the data, so I think wr can go ahead and just exclude 
these instances from analysis. 
*/

-- Let's try filling in missing station id's for station where we have the name.
SELECT
	DISTINCT start_station_name,
	start_station_id
FROM trip_data
WHERE start_station_id IS NULL
	AND start_station_name IS NOT NULL;
-- Omg, there are only 5! yay! Let's get to work

SELECT
	end_station_name,
	end_station_id
FROM trip_data
WHERE end_station_name ILIKE '%W Armitage Ave & N Sheffield Ave%';

