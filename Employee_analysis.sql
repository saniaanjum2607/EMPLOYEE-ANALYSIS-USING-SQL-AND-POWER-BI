CREATE DATABASE projects_hr;

USE projects_hr;

SELECT * FROM hr;

-- data cleaning and preprocessing --

ALTER TABLE hr
CHANGE COLUMN id emp_id VARCHAR(20) NULL;

DESCRIBE hr

SET sql_safe_updates=0;

UPDATE hr
SET birthdate = CASE
WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

-- change the date formate and datatype of hire_date column

UPDATE hr
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- change the date formate and datatype of termdate column

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate!='';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- create an age column
ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR,birthdate,curdate())

SELECT min(age), max(age) FROM hr

-- 1. What is the gender breakdown of current employees in the company?
SELECT * FROM hr
SELECT gender, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

-- 2. What is the race breakdown of current employees in the company?
SELECT race, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY race;

-- 3. What is the age distribution of the employees in the company?
SELECT
      CASE
          WHEN age>=18 and age<=24 THEN '18-24'
          WHEN age>=25 and age<=34 THEN '25-34'
          WHEN age>=35 and age<=44 THEN '35-44'
          WHEN age>=45 and age<=54 THEN '45-54'
          WHEN age>=55 and age<=64 THEN '55-64'
          ELSE '65+'
          END AS age_group,
          COUNT(*) AS count
          FROM hr
          WHERE termdate IS NULL
          GROUP BY age_group
          ORDER BY age_group;
          
-- 4. How many employees work at headquarters vs remote?
SELECT * FROM hr

SELECT location, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location
ORDER BY location;

-- 5. What is the average of the employement that have been terminated?
SELECT ROUND(AVG(YEAR(termdate) - YEAR(hire_date)),0) AS length_of_emp
FROM hr
WHERE termdate IS NOT NULL AND termdate<=curdate();

-- 6. How does job distribution vary across the departments and job titles?
SELECT * FROM hr

SELECT department, jobtitle, gender, COUNT(*) AS count
FROM hr
WHERE termdate IS NOT NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender

-- 7. What is the distribution of job titles across the country?
SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle;

-- 8. Which department has higher turnover/termination rate?
SELECT * FROM hr
SELECT department,
	   COUNT(*) AS total_count,
       COUNT( CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                  END) AS terminated_count,
       ROUND((COUNT( CASE
                  WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                  END)/COUNT(*))*100,2) AS termination_rate    
       FROM hr
       GROUP BY department
       ORDER BY termination_rate DESC
       
-- 9. What is the distribution of current employees by location state and location city?
SELECT location_state, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location_state

SELECT location_city, COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY location_city

-- 10. How has the company's employee count changed over the time based on hire and termination date?
SELECT * FROM hr
       
       SELECT year,
              hires,
              terminations,
              hires-terminations AS net_change,
              (terminations/hires)*100 AS percent_change
	    FROM(
             SELECT YEAR(hire_date) AS year,
             COUNT(*) as hires,
             SUM(CASE
                     WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                     END) AS terminations
			    FROM hr
                GROUP BY YEAR(hire_date)) AS subquery 
 GROUP BY year
 ORDER BY year;
 
 -- 11. What is the tenure distribution of each department?
 SELECT department, round(avg(datediff(termdate,hire_date)/365),0) AS avg_tenure
 FROM hr       
 WHERE termdate IS NOT NULL AND termdate <= curdate()
 GROUP BY department
 ORDER BY avg_tenure




