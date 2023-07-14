/* Google Certificate Case Study - Bike Sharing */

/* 
This case study is about a bike sharing company that is looking to develop marketing 
strategies to convert existing casual riders to annual membership riders.

I've been tasked with identifying how casual riders utilize the bikes differently from 
membership riders. 

I downloaded 12 months worth of .csv files containing trip data between the months of April 2020 
and April 2021. (I did not upload the data for Dec. 2020 because of poor data quality)

My initial look at the files show that some months have significantly less data than other months. Specifically,
summer months contain around 200,000+ rows, whereas the winter months have around 80,000 rows of data.  The column 
names across all the files seem consistent, so no need to adjust the column names for importing. 

I've already spotted some problems I'm going to have to troubleshoot, so I'll add those to my to-do list. 

For now, I'm going to:
	- Create a table for the data 
		- Identify primary key (ride_id)
		- Identify additional constraints
	- Import the data
	- Inspect the data
		- Add indexes (member_casual)
*/

CREATE TABLE trip_data (
	ride_ID text CONSTRAINT ride_key PRIMARY KEY,
	rideable_type text,
	started_at timestamp,
	ended_at timestamp,
	start_station_name text,
	start_station_id integer,
	end_station_name text,
	end_station_id integer,
	start_lat real,
	start_lng real,
	end_lat real,
	end_lng real,
	member_casual text NOT NULL
);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/TripData-04_2020 - 2020_04-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

/* 
First issue, I had initially added a CHECK constraint for the columns started_at & ended_at
to make sure that the ended_at timestamp was never < the started_at timestamp.  Unfortunately, I immediately got an 
error during import because of violations to the check constraint, so I updated the table to remove the constraint,
and I'll add reconciling ill-logical trip durations to my to-do list. 

Import successful. 
*/

SELECT *
FROM trip_data;
-- Cool, we're good!  84,776 rows & 13 columns for the first month's data set.

-- Let's add the next month of data.
COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_05-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

SELECT *
FROM trip_data;
-- Yay! we now have a total of 285,050 rows!

-- Let's add the remaining data
COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_06-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_07-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_08-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_09-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_10-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_11-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_12-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);
-- We got an error for this import because of an invalid entry for 'end_station_id' which should be an integer but instead 
-- lists "TA1306000003". I'm going to continue with the remaining imports for now, then revisit this.

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2021_01-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);
-- Ughh, same error, but with "KA1504000135"

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2021_02-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);
-- same error, I'm going to add reconciling inconsistent station_id convention to the to-do list

/* 
The erros are all listed on preliminary rows, but not the first, so I doubt that it is a change in identification
convention.  Let's take a look at those files and see how pervasive the issue is. Like I mentioned before, Decemeber,
the first file that had an issue importing, had A LOT of missing station info.  Looking at the problem id, there was a 
address listed for the station.  

Looking at previous month data files that imported just fine, I searched for the same station address and low and behold,
there was a regular old integer id for that station!  I can double check the long/lat listing to make sure.

For now, let's just cast that column as a text data type rather than an integer. We can handle the change in entry convention 
for the column once the data is imported.
*/ 
SELECT 
	start_station_id::text,
	end_station_id::text
FROM trip_data;
--Cool, now let's finish importing the remaining data
-- Nevermind, that only changed the existing data to the data type 'text', but didn't alter the table itself

ALTER TABLE trip_data ALTER COLUMN start_station_id SET DATA TYPE text;

ALTER TABLE trip_data ALTER COLUMN end_station_id SET DATA TYPE text;
-- Okay, let's try again

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2020_12-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);
-- Got a different error this time, for a duplicate entry for ride_key. Let's find it in the data already imported

SELECT *
FROM trip_data
WHERE ride_id = 'CDA12952E2FC2D99';

/* 
Yep, the ride_id already exists for a trip on 11/25/20 9:59am to 10:16am. The trip that's listed in December, has a started_at 
timestamp for 12/15/2020 11:39am, but a ended_at timestamp on 11/25/20 @ 10:16am. Looking further at the issue, there are 
about 377 rows in the Dec. dataset that have this issue.  I'm making an executive decision, based on ALL the issues this file
has, to just throw it out, and instead import the dataset for 4/2021 to still have 12 months worth of data.
*/

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2021_01-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2021_02-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2021_03-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);

COPY trip_data
FROM '/Users/hannahbdr/Desktop/DataAnalysis/Portfolios/GoogleCert CS1/Apr2020-Mar2021- TripData(.csv)/2021_04-divvy-tripdata.csv'
WITH (FORMAT CSV, HEADER);
-- Yay!! We FINALLY have all 12 months worth of data imported.

-- Now, let's take a look!
SELECT *
FROM trip_data;
-- Wow, ~3.7 million rows of data! (3,695,405)

/* Since the main goal for this project is to analyze the bike useage between casual and member riders, let's add an index for 
column, since we'll be analyzing the trip data in reference to that information.
*/

CREATE INDEX member_casual_idx ON trip_data (member_casual);

-- Let's see what the ratio of casual riders to membership riders is.
SELECT count(*)
FROM trip_data
WHERE member_casual = 'member';
-- 2,158,508, so 58.41% of riders are member riders. 

SELECT count(*)
FROM trip_data
WHERE member_casual = 'casual';
--1,536,897, so 41.59% of riders are casual riders 



