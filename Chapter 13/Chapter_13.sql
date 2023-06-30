----------------------------------------------------------------------------
-- Chapter 13: Advanced Query Techniques
----------------------------------------------------------------------------

-- 1. Revise the code in Listing 13-21 to dig deeper into the nuances of
-- Waikiki’s high temperatures. Limit the temps_collapsed table to the Waikiki
-- maximum daily temperature observations. Then use the WHEN clauses in the
-- CASE statement to reclassify the temperatures into seven groups that would
-- result in the following text output:

-- '90 or more'
-- '88-89'
-- '86-87'
-- '84-85'
-- '82-83'
-- '80-81'
-- '79 or less'

-- In which of those groups does Waikiki’s daily maximum temperature fall most
-- often?

WITH temps_collapsed (station_name, max_temperature_group) AS
    (SELECT station_name,
           CASE WHEN max_temp >= 90 THEN '90 or more'
                WHEN max_temp >= 88 AND max_temp < 90 THEN '88-89'
                WHEN max_temp >= 86 AND max_temp < 88 THEN '86-87'
                WHEN max_temp >= 84 AND max_temp < 86 THEN '84-85'
                WHEN max_temp >= 82 AND max_temp < 84 THEN '82-83'
                WHEN max_temp >= 90 AND max_temp < 82 THEN '80-81'
                ELSE '79 or less'
            END
    FROM temperature_readings
    WHERE station_name = 'WAIKIKI 717.2 HI US')

SELECT station_name, max_temperature_group, count(*)
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY station_name, max_temperature_group DESC;

-- Waikiki's daily temperature most often falls in the 86-87 degree range.


-- 2. Revise the ice cream survey crosstab in Listing 13-17 to flip the table.
-- In other words, make flavor the rows and office the columns. Which elements
-- of the query do you need to change? Are the counts different?

-- Answer: You need to re-order the columns in the first subquery so flavor is
-- first and office is second. count(*) stays third. Then, you must change
-- the second subquery to produce a grouped list of office. Finally, you must
-- add the office names to the output list.

SELECT *
FROM crosstab('SELECT flavor,
                      office,
                      count(*)
               FROM ice_cream_survey
               GROUP BY flavor, office
               ORDER BY flavor',

              'SELECT office
               FROM ice_cream_survey
               GROUP BY office
               ORDER BY office')

AS (flavor text,
    downtown bigint,
    midtown bigint,
    uptown bigint);

-- The counts stay the same, although the elements for flavor
-- and office need to change position and roles within the query.