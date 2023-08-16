----------------------------------------------------------------------------
-- Chapter 17: Saving Time with Views, Functions, and Triggers
----------------------------------------------------------------------------

-- 1. Create a materialized view that displays the number of New York City
-- taxi trips per hour. Use the taxi data from Chapter 12 and the query in 
-- Listing 12-8. How do you refresh the view if you need to?

CREATE MATERIALIZED VIEW nyc_taxi_trips_per_hour AS
    SELECT date_part('hour', tpep_pickup_datetime) AS trip_hour, count(*)
    FROM nyc_yellow_taxi_trips
    GROUP BY trip_hour
    ORDER BY trip_hour;

SELECT * FROM nyc_taxi_trips_per_hour;

REFRESH MATERIALIZED VIEW nyc_taxi_trips_per_hour;


-- 2. In Chapter 11, you learned how to calculate rates per thousand. Turn that
-- formula into a rate_per_thousand() function that takes three arguments
-- to calculate the result: observed_number, base_number, and decimal_places.

CREATE OR REPLACE FUNCTION
    rate_per_thousand(observed_number numeric,
                      base_number numeric,
                      decimal_places integer DEFAULT 1)
RETURNS numeric(10, 2) AS 
$$
BEGIN
    RETURN
        round(
        (observed_number / base_number) * 1000, decimal_places
        );
END;
$$ 
LANGUAGE plpgsql;

SELECT rate_per_thousand(50, 11000, 2);


-- 3. In Chapter 10, you worked with the meat_poultry_egg_establishments table that
-- listed food processing facilities. Write a trigger that automatically adds an 
-- inspection deadline timestamp six months in the future whenever you insert a new 
-- facility into the table. Use the inspection_deadline column added in Listing 10-19.
-- You should be able to describe the steps needed to implement a trigger and how 
-- the steps relate to each other.

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN inspection_deadline timestamp with time zone;

-- The function that the trigger will execute:
CREATE OR REPLACE FUNCTION add_inspection_deadline()
RETURNS trigger AS 
$$
BEGIN
    NEW.inspection_deadline = now() + '6 months'::interval; -- Here, we set the inspection date to six months in the future
    RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

-- The trigger:
CREATE TRIGGER inspection_deadline_update
    BEFORE INSERT
    ON meat_poultry_egg_establishments
    FOR EACH ROW
    EXECUTE PROCEDURE add_inspection_deadline();

-- Test by inserting a company:
INSERT INTO meat_poultry_egg_establishments(establishment_number, company)
VALUES ('test123', 'testcompany');

SELECT * FROM meat_poultry_egg_establishments
WHERE company = 'testcompany';