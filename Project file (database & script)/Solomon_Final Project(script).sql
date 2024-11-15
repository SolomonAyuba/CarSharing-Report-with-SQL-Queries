-- (a) Please tell me which date and time we had the highest demand rate in 2017.
SELECT 
				strftime('%Y-%m-%d', datetime(timestamp)) AS date,
				strftime('%H-%M-%S', datetime(timestamp)) AS time,
				t.weekday_name AS weekday,
				ROUND(MAX(cs.demand),2)highest_demand_rate
FROM carsharing_df cs
JOIN time t 
ON t.id = cs.id
WHERE t.timestamp LIKE "%2017%";

/* 
	(b) Give me a table containing the name of the weekday, month, and season 
	in which we had the highest and lowest average demand throughout 2017. 
	Please include the calculated average demand values as well.
*/
WITH AvgDemand AS (
SELECT 
				t.weekday_name AS weekday,
				t.month_name AS month,
				t.season,
				strftime('%Y', date(t.timestamp)) AS year,
				round(avg(cs.demand),2) as avg_demand
FROM time t
JOIN CarSharing_df cs ON t.id = cs.id
WHERE year = "2017"
GROUP BY weekday, month, t.season
),
HighestLowestAvgDemand AS (
SELECT
				max(avg_demand) AS highest_avg_demand,
				min(avg_demand) AS lowest_avg_demand
FROM AvgDemand
)
SELECT
				ad.year, 
				ad.weekday,
				ad.month,
				ad.season,
				ad.avg_demand,
				hlad.highest_avg_demand,
				hlad.lowest_avg_demand
FROM AvgDemand  ad
JOIN HighestLowestAvgDemand hlad
WHERE ad.avg_demand = hlad.highest_avg_demand
OR			 ad.avg_demand = hlad.lowest_avg_demand;
				
/* 
	(c) For the weekday(s) selected in (b), 
	please give me a table showing the average demand we had at different hours of that weekday throughout 2017.
	Please sort the results in descending order based on the average demand. 
 */
 WITH AvgDemand AS (
SELECT 
				t.weekday_name AS weekday,
				t.month_name As month,
				t.season,
				t.hour,
				strftime('%Y', date(t.timestamp)) AS year,
				round(avg(cs.demand),2) as avg_demand
FROM time t
JOIN CarSharing_df cs ON t.id = cs.id
WHERE year = "2017"
GROUP BY weekday, month, t.season,t.hour
ORDER BY avg_demand DESC
),
HighestLowestAvgDemand AS (
SELECT
				max(avg_demand) AS highest_avg_demand,
				min(avg_demand) AS lowest_avg_demand
FROM AvgDemand
)
SELECT
				ad.year,
				ad.weekday,
				ad.month,
				ad.season,
				ad.hour,
				ad.avg_demand
FROM AvgDemand  ad
JOIN HighestLowestAvgDemand hlad
WHERE ad.avg_demand = hlad.highest_avg_demand
OR			 ad.avg_demand = hlad.lowest_avg_demand;
 
/* 
	(d1) Please tell me what the weather was like in 2017. Was it mostly cold, mild, or hot? 
	
	(d2) which weather condition (shown in the weather column)was the most prevalent in 2017? 
	
	(d3) What was the average, highest, and lowest wind speed and humidity for each month in 2017? 
	          Please organize this information in two tables for the wind speed and humidity. 
	
	(d4)Please also give me a table showing the average demand for each cold, mild,  and hot weather in 2017 
	sorted in descending order based on their average demand.
 */
 
 -- (d1) Please tell me what the weather was like in 2017. Was it mostly cold, mild, or hot? 
 SELECT 
				strftime('%Y', date(t.timestamp))year,
				CASE
					WHEN cs.temp_code LIKE "%Mild" THEN "Mild"
					WHEN cs.temp_code LIKE "%Cold" THEN "Cold"
					WHEN cs.temp_code LIKE "%Hot" THEN "Hot"
				ELSE "NA"
				END AS weather_temp,
				count(*)weather_temp_occurence
 FROM time t
 JOIN CarSharing_df cs ON t.id = cs.id
 WHERE year = "2017"
 GROUP BY weather_temp
 ORDER BY weather_temp_occurence DESC; 
-- FINDINGS: The weather in 2017 was mostly Mild i.e between 10 and 25 degrees.
 
 
 -- (d2) which weather condition (shown in the weather column)was the most prevalent in 2017?
SELECT 
				strftime('%Y', date(t.timestamp))year,
				w.weather AS weather_condition,
				count(*) AS weather_condition_occurrence
FROM CarSharing_df cs
JOIN time t ON t.id = cs.id
JOIN weather w ON w.weather_code = cs.weather_code
WHERE year ="2017"
GROUP BY weather_condition
ORDER BY weather_condition_occurrence DESC; 
--FINDINGS: 'Clear or partly cloudy' was the prevalent weather condition in 2017
 
 
 /*
      (d3) What was the average, highest, and lowest wind speed and humidity for each month in 2017? 
      Please organize this information in two tables for the wind speed and humidity. 
*/
-- Table for windspeed
 SELECT
				strftime('%Y', date(timestamp)) year,
				strftime('%m', date(timestamp)) month,
				round(avg(cs.windspeed),2) avg_windspeed,
				max(cs.windspeed)highest_windspeed,
				min(cs.windspeed)lowest_windspeed
FROM time t
JOIN CarSharing_df cs ON t.id = cs.id
WHERE year = "2017"
GROUP BY month;

-- Table for humidity
 SELECT
				strftime('%Y', date(timestamp)) year,
				strftime('%m', date(timestamp)) month,
				round(avg(cs.humidity),2) avg_humidity,
				max(cs.humidity)highest_humidity,
				min(cs.humidity)lowest_humidity
FROM time t
JOIN CarSharing_df cs ON t.id = cs.id
WHERE year = "2017"
GROUP BY month;

/* 
    (d4) Please also give me a table showing the average demand for each cold, mild, and hot weather in 2017 
	sorted in descending order based on their average demand. 
*/
SELECT
				strftime('%Y', date(t.timestamp))year,
				round(avg(demand),2)avg_demand,
				CASE
					WHEN cs.temp_code LIKE "%Cold" THEN "Cold"
					WHEN cs.temp_code LIKE "%Mild" THEN "Mild"
					WHEN cs.temp_code LIKE "%Hot" THEN "Hot"
				ELSE "NA"
				END AS weather_condition
FROM CarSharing_df cs
JOIN time t ON t.id = cs.id
WHERE year = "2017"
GROUP BY t.id
ORDER BY avg_demand DESC;
	
/* 
	(e) Give me another table showing the information requested in (d) for the month we had the highest average demand in 2017 
	so that I can compare it with other months. 
*/

WITH AvgDemand AS (
SELECT 
				strftime('%Y', date(t.timestamp)) AS year,
				round(avg(cs.demand),2) AS avg_demand,
				t.month_name AS month,
				CASE
					WHEN cs.temp_code LIKE "%Cold" THEN "Cold"
					WHEN cs.temp_code LIKE "%Mild" THEN "Mild"
					WHEN cs.temp_code LIKE "%Hot" THEN "Hot"
				ELSE "NA"
				END AS weather_condition
FROM CarSharing_df cs
JOIN time t ON t.id = cs.id
WHERE year = "2017"
GROUP BY month
ORDER BY avg_demand DESC
),
 HighestAvgDemand AS (
SELECT 
				max(avg_demand) AS highest_demand
FROM AvgDemand
)
SELECT
				ad.year,
				ad.month,
				ad.weather_condition,
				ad.avg_demand,
				had.highest_demand
FROM AvgDemand ad
JOIN HighestAvgDemand had ON ad.avg_demand = had.highest_demand;
				
				
