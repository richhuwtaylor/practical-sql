----------------------------------------------------------------------------
-- Chapter 15: Analyzing Spatial Data with PostGIS
----------------------------------------------------------------------------

-- 1. Earlier, you found which US county has the largest area. Now,
-- aggregate the county data to find the area of each state in square
-- miles. (Use the statefp column in the us_counties_2019_shp table.)
-- How many states are bigger than the Yukon-Koyukuk area?

SELECT c.state_name, round((sum(ST_Area(sh.geom::geography)) / 1000000)::numeric, 2) as state_area_sq_km
FROM us_counties_2019_shp sh
JOIN us_counties_pop_est_2019 c
ON sh.statefp = c.state_fips AND sh.countyfp = c.county_fips
GROUP BY c.state_name
HAVING round((sum(ST_Area(sh.geom::geography)) / 1000000)::numeric, 2) > (
    SELECT round((ST_Area(geom::geography) / 1000000)::numeric, 2) as yukon_koyukuk_area_sq_km
    FROM us_counties_2019_shp
    WHERE name = 'Yukon-Koyukuk'
)
ORDER BY state_area_sq_km DESC;

-- By running this query, we can see that just 3 states have areas greater than Yukon-Koyukuk
-- county in Alaska: California, Texas, and Alaska itself.

-- 2. Using ST_Distance(), determine how many miles separate these two farmers’
-- markets: The Oakleaf Greenmarket (9700 Argyle Forest Blvd, Jacksonville,
-- Florida) and Columbia Farmers Market (1701 West Ash Street, Columbia,
-- Missouri). You’ll need to first find the coordinates for both in the
-- farmers_markets table.
-- Tip: you can also write this query using the Common Table Expression syntax
-- you learned in Chapter 13.

WITH oakleaf_market AS
    (
     SELECT geog_point
     FROM farmers_markets
     WHERE market_name = 'The Oakleaf Greenmarket'
    ),
    columbia_market AS
    (
     SELECT geog_point
     FROM farmers_markets
     WHERE market_name = 'Columbia Farmers Market'
    )
SELECT round((ST_Distance(oakleaf_market.geog_point, columbia_market.geog_point) / 1609.344)::numeric, 2) AS dist
FROM oakleaf_market, columbia_market;

-- The above query shows that the distance between the two markets is about 850 miles.


-- 3. More than 500 rows in the farmers_markets table are missing a value
-- in the county column, an example of dirty government data. Using the
-- us_counties_2019_shp table and the ST_Intersects() function, perform a
-- spatial join to find the missing county names based on the longitude and
-- latitude of each market. Because geog_point in farmers_markets is of the
-- geography type and its SRID is 4326, you’ll need to cast geom in the Census
-- table to the geography type and change its SRID using ST_SetSRID().

SELECT sh.name, markets.market_name
FROM us_counties_2019_shp sh
JOIN farmers_markets markets
ON ST_Intersects(markets.geog_point, ST_SetSRID(sh.geom,4326)::geography)
WHERE markets.county IS NULL
ORDER BY sh.name;


-- 4. The nyc_yellow_taxi_trips table you created in Chapter 12 contains
-- the longitude and latitude where each trip began and ended. Use PostGIS
-- functions to turn the dropoff coordinates into a geometry type and 
-- count the state/county pairs where each drop-off occurred. As with the
-- previous exercise, you’ll need to join to the us_counties_2019_shp table
-- and use its geom column for the spatial join.

SELECT c.state_name as state_name, 
	sh.name as county_name,
	count(*) as number_of_dropoffs
FROM nyc_yellow_taxi_trips trips
JOIN us_counties_2019_shp sh
ON ST_Within(
	ST_SetSRID(ST_MakePoint(trips.dropoff_longitude, trips.dropoff_latitude), 4269)::geometry, sh.geom
)
JOIN us_counties_pop_est_2019 c
ON sh.statefp = c.state_fips AND sh.countyfp = c.county_fips
GROUP BY state_name, sh.name
ORDER BY number_of_dropoffs DESC;