--1. What range of years are represented in the data?

SELECT * FROM database;
SELECT DISTINCT Year FROM database ORDER BY Year;

--2. What are the shortest and longest-distanced flights, and between which 2 cities are they?
--Note: When we imported the data from a CSV file, all fields are treated as a string. Make sure to convert the value field into a numeric type if you will be ordering by that field.

SELECT MIN(nsmiles) AS shortest_distanced, city1, city2 FROM database; -- nsmiles=109, city1=Los Angeles, CA (Metropolitan Area), city2=San Diego, CA
SELECT MAX(nsmiles) AS longest_distanced, city1, city2 FROM database; -- nsmiles=2724, city1=Miami, FL (Metropolitan Area), city2=Seattle, WA

--3. How many distinct cities are represented in the data (regardless of whether it is the source or destination)?
-- Hint: We can use UNION to help fetch data from both the city1 and city2 columns. Note the distinction between UNION and UNION ALL.

SELECT DISTINCT city1 FROM database
UNION
SELECT DISTINCT city2 FROM database;

/* Analysis: Further explore and analyze the data.*/

--4. Which airline appear most frequently as the carrier with the lowest fare (ie. carrier_low)? How about the airline with the largest market share (ie. carrier_lg)?

SELECT carrier_low, COUNT(*) FROM database GROUP BY 1 ORDER BY 2 DESC; --WN
SELECT carrier_lg, COUNT(*) FROM database GROUP BY 1 ORDER BY 2 DESC; --WN

--5. How many instances are there where the carrier with the largest market share is not the carrier with the lowest fare? What is the average difference in fare?

SELECT carrier_lg, carrier_low FROM database WHERE carrier_lg != carrier_low; --59851 instances

SELECT ROUND(AVG(fare_lg - fare_low)) AS fare_difference_avg FROM database
WHERE carrier_lg != carrier_low; -- 49.0

/* Intermediate challenge */

--6. What is the percent change in average fare from 2007 to 2017 by flight? How about from 1997 to 2017?
-- Hint: We can use the WITH clause to create temporary tables containing the airfares, then join them together to compare the change over time.

SELECT ROUND(AVG(fare),2) AS 'Average Fare 07 to 17' FROM database WHERE Year = 2017
UNION
SELECT ROUND(AVG(fare),2) FROM database WHERE Year = 2007;

SELECT ROUND((((218.34 - 183.12) / 183.12 ) *100), 2); -- 19.23%

SELECT ROUND(AVG(fare),2) FROM database
WHERE year = 1997
UNION
SELECT ROUND(AVG(fare),2) FROM database
WHERE year = 2017;

SELECT ROUND(((218.34-176.74)/176.74)*100,2) --23.54%

--7. How would you describe the overall trend in airfares from 1997 to 2017, as compared 2007 to 2017?

SELECT Year, ROUND(AVG(fare),2) FROM database WHERE Year BETWEEN 1997 AND 2017 GROUP BY Year;
SELECT Year, ROUND(AVG(fare),2) FROM database WHERE Year BETWEEN 2007 AND 2017 GROUP BY Year;

/*
Overall, from the result above, the average airfare has increased from 1997 to 2017, which is higher than the one between 2007 to 2017 (19.23%).
Meanwhile, there's a sharp decline of average airfare in 2001 (from 191.57 to 176.66) and remains relatively low until 2006.
This can reflect how 911 impacted on the airline industry, and caused many airlines to either merge or go bankruptcy.

*/

/* Advanced challenge */

--8. What is the average fare for each quarter? Which quarter of the year has the highest overall average fare? lowest?
-- Note: Not all flights (ie. each city-pair route) have data from all 4 quarters - which may skew the average. Let’s try considering only flights that have data available for all 4 quarters.

WITH routes AS (
SELECT city1, city2 FROM database
GROUP BY 1, 2
HAVING COUNT(DISTINCT quarter) = 4)

-- apply the condition and calculate the average --
SELECT quarter, ROUND(AVG(fare),2) FROM database
JOIN
routes
ON routes.city1 = database.city1 AND routes.city2 = database.city2
GROUP BY 1 ORDER BY 1;

/* quater1: 195.77 / quater2: 194.79 / quater3: 190.62 / quater4: 190.37 
A: Quater 1 has the highest average fare while quater4 has the lowest one.
*/