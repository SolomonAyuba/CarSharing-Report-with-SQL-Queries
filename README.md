# Guided Project for End of SQL + Google Sheets for Data Analytics Course with [Datafied Technologies](https://www.linkedin.com/company/datafiedhub)

## Project Overview

This project involves analyzing a dataset from a car-sharing company. The data spans from January 2017 to August 2018 and includes time-based and weather-related variables to understand customer demand patterns. The project is divided into three main parts: 
1. Data manipulation in Google Sheets
2. Database management in SQL
3. Query generation for business reporting.
   
The deliverables include a structured database and SQL queries to answer key business questions. This documentation outlines the steps taken and the final results. 

### Links for Download:
[Google Drive Folder with CSVs](https://drive.google.com/drive/folders/1YYuZQ3CN6tMq6vOzdI59jr6bT-If10mX?usp=drive_link)

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
      - Solomon_Final Project (script).sql (SQL script containing solutions for Task 6)
  ```

## Part 1: Data Preparation in Google Sheets
### Data Dictionary
<img width="700" alt="Data Dictionary" src="https://github.com/user-attachments/assets/0a2aedb6-4557-44fd-9956-d4d927f5751b">

### 1. Handling Missing Values:
  - Missing values in the `temp` and `temp_feel` columns were filled using the average of their respective columns. This was accomplished using:
  ```google speadsheet
  =IF(ISBLANK(G3), ROUND(AVERAGE(G3:G8710), 2), G3)
   ```

### 2. Creating New Columns:
  - Added a column `temp_category` using `nested IF functions`:
  ```google speadsheet
  =IF(H3 < 10, "Cold", IF(H3 <= 25, "Mild", "Hot"))
  ```

  - Created `temp_code` as a unique identifier for `temperature` features:
  ```google spreadsheet
  =CONCATENATE(G3, "-", H3, "-", I3)
  ```

### 3. Weather Coding:
  - Added a `weather_code` column based on `weather conditions`:
  ```google spreadsheet
  =IF(J3="Clear or partly cloudy", 1, IF(J3="Mist", 2, IF(J3="Light snow or rain", 3, 4)))
  ```

### 4. Date and Time Extraction:
  - Extracted `hour`, `weekday name`, and `month name` from timestamp using the `TEXT function`:
  ```google spreadsheet
  =TEXT(A3, "HH")
  =TEXT(A3, "dddd")
  =TEXT(A3, "mmmm")
  ```
### 5. Creation of Separate Sheets:
  - Created the `weather` sheet with `weather` and `weather_code`, removed duplicates, and deleted the `weather` column from `CarSharing_df`.
  - Created the `temperature` sheet with `temp`, `temp_feel`, `temp_category`, and `temp_code`, removed duplicates, and deleted all but `temp_code` column from `CarSharing_df`.
  - Created the `time` sheet with `id`, `timestamp`, `season`, `hour`, `weekday name`, and `month name`, and removed all but `id` column from `CarSharing_df`.

## Part 2: Database Management with SQLite
### 1. Database Creation:
  - Created an SQLite database named `carsharing.db` and imported the four CSV files (`CarSharing_df.csv`, `temperature.csv`, `weather.csv`, `time.csv`) as tables.

### 2. Table Relationships:
  - Established relationships between tables as per the ER diagram:
  - CarSharing_df linked to temperature using temp_code.
  - CarSharing_df linked to weather using weather_code.
  - CarSharing_df linked to time using id.
### ERD
<img width="669" alt="ER Diagram" src="https://github.com/user-attachments/assets/4ee8290b-18eb-4ccf-a0c1-2e832b0be3da">


## Part 3: Business Queries and Analysis
Linda happens to be the boss at the company. She requested for a report containing the following information: 

  - (a) Please tell me which date and time we had the highest demand rate in 2017.
  - (b) Give me a table containing the name of the weekday, month, and season in which we had the highest and lowest average demand throughout 2017. Please include the calculated average demand values as well.
  - (c) For the weekday(s) selected in (b), please give me a table showing the average demand we had at different hours of that weekday throughout 2017. Please sort the results in descending order based on the average demand.
  - (d) Please tell me what the weather was like in 2017. Was it mostly cold, mild, or hot? which weather condition (shown in the weather column) was the most prevalent in 2017? What was the average, highest, and lowest wind speed and humidity for each month in 2017? Please organize this information in two tables for the wind speed and humidity. Please also give me a table showing the average demand for each cold, mild, and hot weather in 2017 sorted in descending order based on their average demand.
  - (e) Give me another table showing the information requested in (d) for the month we had the highest average demand in 2017 so that I can compare it with other months.


Requested queries were answered as follows:
### 1. 	Highest Demand in 2017:
```sql
SELECT date, hour, MAX(demand)
FROM CarSharing_df
WHERE strftime('%Y', timestamp) = '2017';
```
### 2. Weekday, Month, and Season with Highest/Lowest Average Demand:
   ```sql
   SELECT weekday_name, month_name, season, AVG(demand) AS avg_demand
   FROM CarSharing_df
   WHERE strftime('%Y', timestamp) = '2017'
   GROUP BY weekday_name, month_name, season
   ORDER BY avg_demand DESC;
   ```
### 3. Hourly Average Demand on the Selected Weekday:
   ```sql
   SELECT hour, AVG(demand) AS avg_demand
   FROM CarSharing_df
   WHERE strftime('%Y', timestamp) = '2017' AND weekday_name = 'Monday'
   GROUP BY hour
   ORDER BY avg_demand DESC;
   ```
### 4. Weather Analysis in 2017:
   ```sql
   SELECT weather, COUNT(*) AS count, AVG(wind_speed), MIN(wind_speed), MAX(wind_speed),
       AVG(humidity), MIN(humidity), MAX(humidity)
   FROM CarSharing_df
   JOIN weather ON CarSharing_df.weather_code = weather.weather_code
   WHERE strftime('%Y', timestamp) = '2017'
   GROUP BY month_name;
   ```
### 5. Comparison of the Month with the Highest Average Demand:
   ```sql
   SELECT temp_category, AVG(demand) AS avg_demand
   FROM CarSharing_df
   WHERE strftime('%Y', timestamp) = '2017' AND month_name = 'July'
   GROUP BY temp_category
   ORDER BY avg_demand DESC;
   ```

## Visual and Data Access
- **ER Diagram:** Visual representation stored in `/ERD/ER_diagram.png`.
- **SQL Queries:** Available in `/Project files/queries.sql` for detailed code and execution.
- **Database File:** The final database is stored in `/Project files/carsharing.db`.

## Conclusion

This project successfully manipulates and restructures data using Google Sheets, creates a relational database, and extracts business insights with SQL. These results provide valuable information on customer demand patterns and weather influences on car-sharing behavior in 2017.
 
© Datafied Technologies: [GitHub](https://github.com/Datafyde/Datafyde) |  [LinkedIn](https://www.linkedin.com/company/datafiedhub/posts/?feedView=all) 15.11.2024
