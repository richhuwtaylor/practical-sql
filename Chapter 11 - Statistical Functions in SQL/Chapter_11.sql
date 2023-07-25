----------------------------------------------------------------------------
-- Chapter 11: Statistical Functions in SQL
----------------------------------------------------------------------------

-- 1. In Listing 11-2, the correlation coefficient, or r value, of the
-- variables pct_bachelors_higher and median_hh_income was about .70.
-- Write a query using the same dataset to show the correlation between
-- pct_masters_higher and median_hh_income. Is the r value higher or lower?
-- What might explain the difference?

SELECT
    round(
      corr(median_hh_income, pct_bachelors_higher)::numeric, 2
      ) AS bachelors_income_r,
    round(
      corr(median_hh_income, pct_masters_higher)::numeric, 2
      ) AS masters_income_r
FROM acs_2014_2018_stats;

-- The r value for the relationship between pct_masters_higher and median_hh_income
-- is about 0.60, suggesting that having a masters degree may not have as strong
-- an effect on income as having a bachelor's degree. 


-- 2. Using the exports data, create a 12-month rolling sum using the values
-- in the column soybeans_export_value and the query pattern from 
-- Listing 11-8. Copy and paste the results from the pgAdmin output 
-- pane and graph the values using Excel. What trend do you see?  

SELECT year, month, soybeans_export_value,
	round(
		sum(soybeans_export_value)
			OVER(ORDER BY year, month
					ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), 0)
	AS twelve_month_sum
FROM us_exports
ORDER BY year, month;

-- Graphing the data show that soybean exports started to drop during the late
-- 2000s.


-- 3. As a bonus challenge, revisit the libraries data in the table
-- pls_fy2018_libraries in Chapter 9. Rank library agencies based on the rate
-- of visits per 1,000 population (variable popu_lsa), and limit the query to
-- agencies serving 250,000 people or more.

SELECT libname, stabr, visits, popu_lsa,
    round(
        (visits::numeric / popu_lsa) * 1000, 1
        ) AS visits_per_1000,
    rank() OVER (ORDER BY (visits::numeric / popu_lsa) * 1000 DESC) AS ranking
FROM pls_fy2018_libraries
WHERE popu_lsa >= 250000;

-- Running this query shows that Pinella Public Library Coop is highest ranking,
-- with 9705 visits per 1000 people.