# Guided Project for End of SQL + Google Sheets for Data Analytics Course with [Datafied Technologies](https://www.linkedin.com/company/datafiedhub)
Author: [Solomon Ayuba](https://www.linkedin.com/in/solomonayuba/)

## Project Overview

This project involves analyzing a dataset from a car-sharing company. The data spans from January 2017 to August 2018 and includes time-based and weather-related variables to understand customer demand patterns. The project is divided into three main parts: 
1. Data manipulation in Google Sheets
2. Database management in SQL
3. Query generation for business reporting.
   
The deliverables include a structured database and SQL queries to answer key business questions. This documentation outlines the steps taken and the final results. 
## Data Source and License
The original dataset was obtained from a car-sharing company and includes hourly data on customer demand rates, weather conditions, and temperature. Due to privacy considerations, the dataset has been anonymized and sanitized.

This project is licensed under the [Datafied Technologies](https://www.linkedin.com/company/datafiedhub/posts/?feedView=all) License


## Project Structure and Deliverables
### Repository Structure:

  ```- README.md (this document)
  - /ERD
      - ER diagram.png (ER diagram representing database relationships)
  - /Tables
      - CarSharing_df.csv
      - temperature.csv
      - weather.csv
      - time.csv
      - Solomon_Final Project.xlsx
  - /Project files (database & script)
      - Solomon_Final Project (database).db (SQL database)
      - Solomon_Final Project(project file).sqbpro (SQLite Browser project file)
      - Solomon_Final Project (script).sql (SQL script containing solutions to the Business Questions)
  ```
### Links for Download:
Click to download: [Google Drive Folder with CSVs](https://drive.google.com/drive/folders/1YYuZQ3CN6tMq6vOzdI59jr6bT-If10mX?usp=drive_link)

## Part 1: Data Preparation in Google Sheets
### Data Dictionary
<img width="700" alt="Data Dictionary" src="https://github.com/user-attachments/assets/0a2aedb6-4557-44fd-9956-d4d927f5751b">

### 1. Handling Missing Values:
   Missing values in the `temp` and `temp_feel` columns were filled using the average of their respective columns. This was accomplished using:
  ```markdown
  =IF(ISBLANK(I2),ROUND(AVERAGE(I2:I8710),2),I2)
  =IF(ISBLANK(I2),ROUND(AVERAGE(I2:I8710),2),I2)
   ```

### 2. Creating New Columns:
  - Added a column `temp_category` using `nested IF functions`:
  ```markdown
  =IF(G2:G8709<10, "Cold", IF(AND(G2:G8709>=10, G2:G8709<=25),"Mild", IF(G2:G8709>25, "Hot")))
  ```

  - Created `temp_code` as a unique identifier for `temperature` features:
  ```markdown
  =CONCATENATE(G2, "-",H2,"-", P2)
  ```

### 3. Weather Coding:
   Added a `weather_code` column based on `weather conditions`:
  ```markdown
  =IF(F2 = "Clear or partly cloudy", -1,IF(F2 = "Mist",-2,IF(F2="Light snow or rain",-3, IF(F2="heavy rain/ice pellets/snow + fog",-4))))
  ```

### 4. Date and Time Extraction:
   Extracted `hour`, `weekday name`, and `month name` from timestamp using the `TEXT function`:
  ```markdown
     =TEXT(B3, "HH")
     =TEXT(B3, "DDD")
     =TEXT(B3, "MMMM")
  ```
### 5. Creation of Separate Sheets:
  - Created the `weather` sheet with `weather` and `weather_code`, removed duplicates, and deleted the `weather` column from `CarSharing_df`.
  - Created the `temperature` sheet with `temp`, `temp_feel`, `temp_category`, and `temp_code`, removed duplicates, and deleted all but `temp_code` column from `CarSharing_df`.
  - Created the `time` sheet with `id`, `timestamp`, `season`, `hour`, `weekday name`, and `month name`, and removed all but `id` column from `CarSharing_df`.

## Part 2: Database Management with MySQL Workbench
### 1. Database Creation:
  - Created an SQLite database named `carsharing.db` and imported the four CSV files (`CarSharing_df.csv`, `temperature.csv`, `weather.csv`, `time.csv`) as tables.

### 2. Table Relationships:
  - Established relationships between tables as per the ER diagram:
  - `CarSharing_df` linked to `temperature` using `temp_code`.
  - `CarSharing_df` linked to `weather` using `weather_code`.
  - `CarSharing_df` linked to `time` using `id`.

### ERD
<img width="669" alt="ER Diagram" src="https://github.com/user-attachments/assets/4ee8290b-18eb-4ccf-a0c1-2e832b0be3da">


## Part 3: Business Queries and Analysis
Linda happens to be the Boss of the company. She requested a report containing the following information: 

1. Please tell me which date and time we had the highest demand rate in 2017.
2. Give me a table containing the name of the weekday, month, and season in which we had the highest and lowest average demand throughout 2017. Please include the calculated average demand values as well.
3. For the weekday(s) selected in (2), please give me a table showing the average demand we had at different hours of that weekday throughout 2017. Please sort the results in descending order based on the average demand.
4. Please tell me what the weather was like in 2017. Was it mostly cold, mild, or hot?
   
   a. Which weather condition (shown in the weather column) was the most prevalent in 2017?
     
   b. What was the average, highest, and lowest wind speed and humidity for each month in 2017? Please organize this information in two tables for the wind speed and humidity.
   
   c. Please also give me a table showing the average demand for each cold, mild, and hot weather in 2017 sorted in descending order based on their average demand.
     
6. Give me another table showing the information requested in (4) for the month we had the highest average demand in 2017 so that I can compare it with other months.


## The requested queries were answered as follows using SQLite
#### 1. What date and time did we have the Highest Demand in 2017? 
```sql
SELECT 
      strftime('%Y-%m-%d', datetime(timestamp)) AS date,
      strftime('%H-%M-%S', datetime(timestamp)) AS time,
      t.weekday_name AS weekday,
ROUND(MAX(cs.demand),2)highest_demand_rate
FROM carsharing_df cs
JOIN time t 
ON t.id = cs.id
WHERE t.timestamp LIKE "%2017%";
```
#### 2. What are the names of the weekday, month, and season in which we had the highest and lowest average demand throughout 2017? 
   ```sql
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
   ```
#### 3. What was the Average demand at different hours of that weekday throughout 2017? 
   ```sql
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
   ```
#### 4. What was the weather like in 2017? 
   ```sql
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
  ```
- Findings: The weather in 2017 was mostly Mild i.e between 10 and 25 degrees.
 
 #### 4a. Which weather condition (shown in the weather column)was the most prevalent in 2017? 
   ```sql
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
   ```
- Findings: 'Clear or partly cloudy' was the prevalent weather condition in 2017
 
 
#### 4b. What was the average, highest, and lowest wind speed and humidity for each month in 2017?
**Table for windspeed:**
 ```sql
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
   ```
**Table for humidity:**
   ```sql
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
   ```
#### 4c. A table showing the average demand for cold, mild, and hot weather in 2017. Sorted in descending order based on their average demand: 
   ```sql
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
   ```	      
#### 5. A table showing the information requested in (4) for the month with the highest average demand in 2017:
   ```sql
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
   ```

## Visual and Data Access
- **ER Diagram:** Visual representation stored in `/ERD/ER diagram.png`.
- **SQL Queries:** Available in `/Project files/Solomon_Final Project(script).sql` for detailed code and execution.
- **Database File:** The final database is stored in `/Project files/Solomon_Final Project(database).db`.

## Conclusion

This project successfully manipulates and restructures data using Google Sheets, creates a relational database, and extracts business insights with SQL. These results provide valuable information on customer demand patterns and weather influences on car-sharing behavior in 2017.
 
© Datafied Technologies: [GitHub](https://github.com/Datafyde/Datafyde) |  [LinkedIn](https://www.linkedin.com/company/datafiedhub/posts/?feedView=all) 15.11.2024

[Miva Open University](https://miva.university/)
