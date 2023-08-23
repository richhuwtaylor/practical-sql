--------------------------------------------------------------
-- Chapter 10: Inspecting and Modifying Data
--------------------------------------------------------------

-- In this exercise, you’ll turn the meat_poultry_egg_establishments table
-- into useful information. You need to answer two questions: How many 
-- of the companies in the table process meat, and how many process poultry?

-- Your tasks are as follows:

-- 1. Create two new columns called meat_processing and poultry_processing. Each
-- can be of the type boolean.

-- 2. Using UPDATE, set meat_processing = TRUE on any row where the activities
-- column contains the text 'Meat Processing'. Do the same update on the
-- poultry_processing column, but this time look for the text
-- 'Poultry Processing' in activities.

-- Use the data from the new, updated columns to count how many companies
-- perform each type of activity. For a bonus challenge, count how many
-- companies perform both activities.

ALTER TABLE meat_poultry_egg_establishments ADD COLUMN meat_processing boolean;
ALTER TABLE meat_poultry_egg_establishments ADD COLUMN poultry_processing boolean;

UPDATE meat_poultry_egg_establishments
SET meat_processing = TRUE
WHERE activities ILIKE '%Meat Processing%';

UPDATE meat_poultry_egg_establishments
SET poultry_processing = TRUE
WHERE activities ILIKE '%Poultry Processing%';

-- Produce counts for establishments which process each type

SELECT count(meat_processing) As meat_count, count(poultry_processing) AS poultry_count
FROM meat_poultry_egg_establishments;

-- Produce a count of establishments which process both

SELECT count(*) AS both_count
FROM meat_poultry_egg_establishments
WHERE meat_processing = TRUE 
AND poultry_processing = TRUE;