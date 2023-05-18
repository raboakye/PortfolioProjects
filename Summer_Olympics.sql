--1. Numbering olympic athletes by medals earned


SELECT
  -- Count the number of medals each athlete has earned
  athlete,
  COUNT(medal) AS Medals
FROM SUMMER_OLYMPICS
GROUP BY Athlete
ORDER BY Medals DESC;

-------------------------------------------------------------------------------------------------------------------------
--2. Numbering olympic athletes by medals earnted improved.

WITH Athlete_Medals AS (
  SELECT
    -- Count the number of medals each athlete has earned
    Athlete,
    COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  GROUP BY Athlete)

SELECT
  -- Number each athlete by how many medals they've earned
  athlete,
  ROW_NUMBER() OVER (ORDER BY medals DESC) AS Row_N
FROM Athlete_Medals
ORDER BY Medals DESC;

-------------------------------------------------------------------------------------------------------------------------
--3. Reigning weightlifting champions

SELECT
  -- Return each year's champions' countries
  year,
  country AS champion
FROM SUMMER_OLYMPICS
WHERE
  Discipline = 'Weightlifting' AND
  Event = '69KG' AND
  Gender = 'Men' AND
  Medal = 'Gold';
	
	-------------------------------------------------------------------------------------------------------------------------
	-- 4. Reigning weightlifting champion improved. 
	WITH Weightlifting_Gold AS (
  SELECT
    -- Return each year's champions' countries
    Year,
    Country AS champion
  FROM SUMMER_OLYMPICS
  WHERE
    Discipline = 'Weightlifting' AND
    Event = '69KG' AND
    Gender = 'Men' AND
    Medal = 'Gold')

SELECT
  Year, Champion,
  -- Fetch the previous year's champion
  LAG(Champion,1) OVER
    (ORDER BY year ASC) AS Last_Champion
FROM Weightlifting_Gold
ORDER BY Year ASC;

------------------------------------------------------------------------------------------------------------------------------------

--5. Reigning Champions by gender. 

WITH Tennis_Gold AS (
  SELECT DISTINCT
    Gender, Year, Country
  FROM SUMMER_OLYMPICS
  WHERE
    Year >= 2000 AND
    Event = 'Javelin Throw' AND
    Medal = 'Gold')

SELECT
  Gender, Year,
  Country AS Champion,
  -- Fetch the previous year's champion by gender
  LAG(country,1) OVER (PARTITION BY gender
            ORDER BY year ASC) AS Last_Champion
FROM Tennis_Gold
ORDER BY Gender ASC, Year ASC;

--------------------------------------------------------------------------------------------------------------------------------------

--6. Reigning Champions by gender and event 

WITH Athletics_Gold AS (
  SELECT DISTINCT
    Gender, Year, Event, Country
  FROM SUMMER_OLYMPICS
  WHERE
    Year >= 2000 AND
    Discipline = 'Athletics' AND
    Event IN ('100M', '10000M') AND
    Medal = 'Gold')

SELECT
  Gender, Year, Event,
  Country AS Champion,
  -- Fetch the previous year's champion by gender and event
  LAG(country,1) OVER (PARTITION BY gender,event
            ORDER BY Year ASC) AS Last_Champion
FROM Athletics_Gold
ORDER BY Event ASC, Gender ASC, Year ASC;

----------------------------------------------------------------------------------------------------------------------------------------------

--7. Future Gold Medalists

WITH Discus_Medalists AS (
  SELECT DISTINCT
    Year,
    Athlete
  FROM SUMMER_OLYMPICS
  WHERE Medal = 'Gold'
    AND Event = 'Discus Throw'
    AND Gender = 'Women'
    AND Year >= 2000)

SELECT
  -- For each year, fetch the current and future medalists
  year,
  Athlete,
  LEAD(Athlete,3) OVER (ORDER BY year ASC) AS Future_Champion
FROM Discus_Medalists
ORDER BY Year ASC;

----------------------------------------------------------------------------------------------------------------------------------------------------

--8. First athlete by name

WITH All_Male_Medalists AS (
  SELECT DISTINCT
    Athlete
  FROM SUMMER_OLYMPICS
  WHERE Medal = 'Gold'
    AND Gender = 'Men')

SELECT
  -- Fetch all athletes and the first athlete alphabetically
  Athlete,
  FIRST_VALUE(athlete) OVER (
    ORDER BY athlete ASC
  ) AS First_Athlete
FROM All_Male_Medalists;

-------------------------------------------------------------------------------------------------------------------------------------------------------

--9. Last country by name

WITH Hosts AS (
  SELECT DISTINCT Year, City
    FROM SUMMER_OLYMPICS)

SELECT
  Year,
  City,
  -- Get the last city in which the Olympic games were held
  LAST_VALUE(city) OVER (
   ORDER BY year ASC
   RANGE BETWEEN
     UNBOUNDED PRECEDING AND
     UNBOUNDED FOLLOWING
  ) AS Last_City
FROM Hosts
ORDER BY Year ASC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--RANKING

--10. Ranking athletes by medals earned

WITH Athlete_Medals AS (
  SELECT
    Athlete,
    COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  GROUP BY Athlete)

SELECT
  Athlete,
  Medals,
  -- Rank athletes by the medals they've won
  RANK() OVER (ORDER BY medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Medals DESC;


--------------------------------------------------------------------------------------------------------------------------------------------------------------

--11. Ranking athletes from multiple countries

WITH Athlete_Medals AS (
  SELECT
    Country, Athlete, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  WHERE
    Country_Code IN ('JPN', 'KOR')
    AND Year >= 2000
  GROUP BY Country, Athlete
  HAVING COUNT(*) > 1)

SELECT
  Country,
  -- Rank athletes in each country by the medals they've won
  athlete,
  DENSE_RANK() OVER (PARTITION BY country
                ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Country ASC, RANK_N ASC;


------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PAGING

--12. Paging Events
WITH Events AS (
  SELECT DISTINCT Event
  FROM SUMMER_OLYMPICS)
  
SELECT
  --- Split up the distinct events into 111 unique groups
  DISTINCT   event,
  NTILE(111) OVER (ORDER BY event ASC) AS Page
FROM Events
ORDER BY Event ASC;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--13. Top, middle and bottom thirds

WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  GROUP BY Athlete
  HAVING COUNT(*) > 1)
  
SELECT
  Athlete,
  Medals,
  -- Split athletes into thirds by their earned medals
  NTILE(3) OVER(ORDER BY medals DESC) AS Third
FROM Athlete_Medals
ORDER BY Medals DESC, Athlete ASC;


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--14. Top, middle and bottom thirds

WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  GROUP BY Athlete
  HAVING COUNT(*) > 1),
  
  Thirds AS (
  SELECT
    Athlete,
    Medals,
    NTILE(3) OVER (ORDER BY Medals DESC) AS Third
  FROM Athlete_Medals)
  
SELECT
  -- Get the average medals earned in each third
  Third,
  AVG(Medals) AS Avg_Medals
FROM Thirds
GROUP BY Third
ORDER BY Third ASC;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--15. Total medals with group by and partition by

WITH Tmedals AS (
	SELECT year, country, medal, COUNT(*) AS medalsum
	FROM SUMMER_OLYMPICS
	WHERE year IS NOT NULL
	GROUP BY year, country, medal
)

SELECT year, country, medal,
	SUM(medalsum) OVER(PARTITION BY country, year,medal ORDER BY year DESC) AS medals_sum
FROM Tmedals
ORDER BY medals_sum desc, country, year, medal;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--16. Running totals of athlete medals

WITH Athlete_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  WHERE
    Country = 'USA' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete)

SELECT
  -- Calculate the running total of athlete medals
  athlete,
  medals,
  SUM(Medals) OVER (ORDER BY Athlete ASC) AS Max_Medals
FROM Athlete_Medals
ORDER BY Athlete ASC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--17. Maximum country medals by year

WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  WHERE
    Country IN ('CHN', 'KOR', 'JPN')
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year, Country)

SELECT
  -- Return the max medals earned so far per country
  year,
  country,
  medals,
  MAX(Medals) OVER (PARTITION BY country
                ORDER BY year ASC) AS Max_Medals
FROM Country_Medals
ORDER BY Country ASC, Year ASC;


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--18. Minimum country medals by year

WITH France_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  WHERE
    Country = 'FRA'
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year)

SELECT
  year,
  medals,
  MIN(medals) OVER (ORDER BY year ASC) AS Min_Medals
FROM France_Medals
ORDER BY Year ASC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--19. Moving maximum of Scandinavian athletes' medals 

WITH Scandinavian_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  WHERE
    Country_Code IN ('DEN', 'NOR', 'FIN', 'SWE', 'ISL')
    AND Medal = 'Gold'
  GROUP BY Year)

SELECT
  -- Select each year's medals
  medals,
  year,
  -- Get the max of the current and next years'  medals
  MAX(medals) OVER (ORDER BY year ASC
             ROWS BETWEEN CURRENT ROW
             AND 1 FOLLOWING) AS Max_Medals
FROM Scandinavian_Medals
ORDER BY Year ASC;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--20. Moving maximum of Chinese athletes' medals

WITH Chinese_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  WHERE
    Country_Code = 'CHN' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete)

SELECT
  -- Select the athletes and the medals they've earned
  Athlete,
  Medals,
  -- Get the max of the last two and current rows' medals 
  MAX(Medals) OVER (ORDER BY Athlete ASC
            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW) AS Max_Medals
FROM Chinese_Medals
ORDER BY Athlete ASC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--21. Moving average of Russian medals 

WITH Russian_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  WHERE
    Country_Code = 'RUS'
    AND Medal = 'Gold'
    AND Year >= 1980
  GROUP BY Year)

SELECT
  Year, Medals,
  --- Calculate the 3-year moving average of medals earned
  AVG(medals) OVER
    (ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM Russian_Medals
ORDER BY Year ASC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--22. Moving total of countries' medals 

WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  GROUP BY Year, Country)

SELECT
  Year, Country, Medals,
  -- Calculate each country's 3-game moving total
  SUM(Medals) OVER
    (PARTITION BY country
     ORDER BY Year ASC
     ROWS BETWEEN
     2 PRECEDING AND CURRENT ROW) AS Medals_MA
FROM Country_Medals
ORDER BY Country ASC, Year ASC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--23. A basic pivot

-- Create the correct extension to enable CROSSTAB
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  SELECT
    Gender, Year, Country
  FROM SUMMER_OLYMPICS
  WHERE
    Year IN (2008, 2012)
    AND Medal = 'Gold'
    AND Event = 'Pole Vault'
  ORDER By Gender ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Gender VARCHAR,
           "2008" VARCHAR,
           "2012" VARCHAR)

ORDER BY Gender ASC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--24. Pivoting with ranking 

CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  WITH Country_Awards AS (
    SELECT
      Country,
      Year,
      COUNT(*) AS Awards
    FROM SUMMER_OLYMPICS
    WHERE
      Country IN ('FRA', 'GBR', 'GER')
      AND Year IN (2004, 2008, 2012)
      AND Medal = 'Gold'
    GROUP BY Country, Year)

  SELECT
    Country,
    Year,
    RANK() OVER
      (PARTITION BY Year
       ORDER BY Awards DESC) :: INTEGER AS rank
  FROM Country_Awards
  ORDER BY Country ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Country VARCHAR,
           "2004" INTEGER,
           "2008" INTEGER,
           "2012" INTEGER)

Order by Country ASC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--25. Country level subtotals

-- Count the gold medals per country and gender
SELECT
  Country_Code,
  gender,
  COUNT(*) AS Gold_Awards
FROM SUMMER_OLYMPICS
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country_Code IN ('DEN', 'NOR', 'SWE')
-- Generate Country-level subtotals
GROUP BY Country_Code, ROLLUP(gender)
ORDER BY Country_Code ASC, Gender ASC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--26. All group level subtotals

-- Count the medals per gender and medal type
SELECT
  gender,
  medal,
  count(*) AS Awards
FROM SUMMER_OLYMPICS
WHERE
  Year = 2012
  AND Country = 'RUS'
-- Get all possible group-level subtotals
GROUP BY CUBE(Gender, Medal)
ORDER BY Gender ASC, Medal ASC;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--27. Cleaning up results

SELECT
  -- Replace the nulls in the columns with meaningful text
  COALESCE(Country_Code, 'All countries') AS Country,
  COALESCE(Gender, 'All genders') AS Gender,
  COUNT(*) AS Awards
FROM SUMMER_OLYMPICS
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country_Code IN ('DEN', 'NOR', 'SWE')
GROUP BY ROLLUP(Country_Code, Gender)
ORDER BY Country_Code ASC, Gender ASC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--28. Summarizing results

WITH Country_Medals AS (
  SELECT
    Country_Code,
    COUNT(*) AS Medals
  FROM SUMMER_OLYMPICS
  WHERE Year = 2000
    AND Medal = 'Gold'
  GROUP BY Country_Code)

  SELECT
    Country_Code,
    -- Rank countries by the medals awarded
    RANK() OVER(PARTITION BY Country_Code order by medals desc) AS Rank
  FROM Country_Medals
  ORDER BY Rank ASC;
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--29. Summarizing results
	
	WITH Country_Medals AS (
  SELECT
    Country_Code,
    COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Year = 2000
    AND Medal = 'Gold'
  GROUP BY Country_Code),

  Country_Ranks AS (
  SELECT
    Country_Code,
    RANK() OVER (ORDER BY Medals DESC) AS Rank
  FROM Country_Medals
  ORDER BY Rank ASC)

-- Compress the countries column
SELECT STRING_AGG(Country_Code, ', ') --space after comma
FROM Country_Ranks
-- Select only the top three ranks
WHERE RANK <=3;
