----------------------------------------------------------------------------
-- Chapter 16: Working with JSON Data
----------------------------------------------------------------------------

-- 1. The earthquakes JSON has a key tsunami that’s set to a value of 1 for 
-- large earthquakes in oceanic regions (though it doesn’t mean a tsunami 
-- actually happened). Using either path or element extraction operators, 
-- find earthquakes with a tsunami value of 1 and include their location, time
-- and magnitude in your results.


-- using field extraction operators:
SELECT earthquake -> 'properties' ->> 'place' AS place,
       to_timestamp((earthquake -> 'properties' ->> 'time')::bigint / 1000) AS timestamp,
       (earthquake -> 'properties' ->> 'mag')::numeric AS mag
FROM earthquakes
WHERE (earthquake -> 'properties' ->> 'tsunami') = '1'
ORDER BY mag DESC;

-- using path extraction operators:
SELECT earthquake #>> '{properties, place}' AS place,
       to_timestamp((earthquake -> 'properties' ->> 'time')::bigint / 1000) AS timestamp,
       (earthquake #>> '{properties, mag}')::numeric AS mag
FROM earthquakes
WHERE (earthquake #>> '{properties, tsunami}') = '1'
ORDER BY mag DESC;


-- 2. Use the following CREATE TABLE statement to add the table earthquakes_from_json
-- to your analysis database:

CREATE TABLE earthquakes_from_json (
    id text PRIMARY KEY,
    title text,
    type text,
    quake_date timestamp with time zone,
    mag numeric,
    place text,
    earthquake_point geography(POINT, 4326),
    url text
);

-- Using field and path extraction operators, write an INSERT statement
-- to fill the table with the correct values for each earthquake. Refer 
-- to the full sample earthquake JSON in your Chapter_16.sql file for any 
-- key names and paths you need.

INSERT INTO earthquakes_from_json
SELECT earthquake ->> 'id',
       earthquake -> 'properties' ->> 'title',
       earthquake -> 'properties' ->> 'type',
       to_timestamp((earthquake -> 'properties' ->> 'time')::bigint / 1000),
       (earthquake -> 'properties' ->> 'mag')::numeric,
       earthquake -> 'properties' ->> 'place',
       ST_SetSRID(
            ST_MakePoint(
                (earthquake #>> '{geometry, coordinates, 0}')::numeric,
                (earthquake #>> '{geometry, coordinates, 1}')::numeric
             ),
                 4326)::geography,
       earthquake -> 'properties' ->> 'url'
FROM earthquakes;


-- 3. Bonus (difficult) question: Try writing a query to generate the 
-- following JSON using the data in the teachers and teachers_lab_access
-- tables from Chapter 13:
{
	"id": 6,
	"fn": "Kathleen",
	"ln": "Roush",
	"lab_access": [{
		"lab_name": "Science B",
		"access_time": "2022-12-17T16:00:00-05:00"
	}, {
		"lab_name": "Science A",
		"access_time": "2022-12-07T10:02:00-05:00"
	}]
}
-- It’s helpful to remember that the teachers table has a one-to-many relationship 
-- with teachers_lab_access; the first three keys must come from teachers, and the 
-- JSON objects in the array of lab_access will come from teachers_lab_access. 
-- Hint: you’ll need to use a subquery in your SELECT list and a function called 
-- json_agg() to create the lab_access array. 

-- Answer:

SELECT to_json(teachers_labs)
FROM (
    SELECT id,
           first_name AS fn,
           last_name AS ln,
        (
            SELECT json_agg(to_json(la))
            FROM (
                SELECT lab_name, access_time
                FROM teachers_lab_access
                WHERE teacher_id = teachers.id
                ORDER BY access_time DESC
            ) AS la
        ) AS lab_access
    FROM teachers 
    WHERE id = 6)
AS teachers_labs;
