create database project_hr;

use project_hr;

select * from hr;  

-- data cleaning and preprocessing--

alter table hr
change column ï»¿id emp_id varchar(20) null;

describe hr

set sql_safe_updates = 0;

update hr 
set birthdate = case 
    when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    else null
    end;
    
    ALTER TABLE HR
    MODIFY COLUMN BIRTHDATE DATE;
    
    ---- CHANGE THE DATA FORMAT AND DATATYPE OF HIRE_DATE COLUMN --- 

UPDATE HR 
SET HIRE_DATE = CASE 
    when HIRE_DATE like '%/%' then date_format(str_to_date(HIRE_DATE,'%m/%d/%Y'),'%Y-%m-%d')
    when HIRE_DATE like '%-%' then date_format(str_to_date(HIRE_DATE,'%m-%d-%Y'),'%Y-%m-%d')
    else null
    end;

ALTER TABLE HR
MODIFY COLUMN HIRE_DATE date; 

---- CHANGE THE DATE FORMAT AND DATATYPE OF TERMDATA COLUMN -- 

UPDATE HR
SET TERMDATE = DATE(str_to_date(TERMDATE,'%Y-%m-%d %H:%i:%s UTC'))
WHERE TERMDATE IS NOT NULL AND TERMDATE !='';

update HR
set termdate = NULL
where termdate = '';

----- CREATE AGE COLUMN---
ALTER TABLE HR 
ADD COLUMN AGE int; 

UPDATE HR
SET AGE = timestampdiff(YEAR,BIRTHDATE,curdate())

select min(age), max(age) from hr

--- 1. what is the gender breadown of employess in th company
select gender, count(*) as count
from hr
where termdate is null
group by gender;

-- 2. what is race breakdown of employees in th company 

select * from hr;

select race, count(*) as count
from hr
where termdate is null 
group by race;

-- 3. what is the age distribution of employees in company

select
   case 
      when age>=18 and age <=24 then '18-24'
      when age>=25 and age <=34 then '25-34'
      when age>=35 and age <=44 then '35-44'
      when age>=45 and age <=54 then '45-54'
      when age>=55 and age <=64 then '55-64'
      else '65+'
      end as age_group,
      count(*) as count
      from hr
     
      group by age_group
      order by age_group;
      
      -- 4. how many employees headquarter and remote
      
      select location,count(*) as count
      from hr
	  where termdate is null
	  group by location;
      
      -- 5. what is the avg length of emp who have been terminated 
      
      select round(avg(year(termdate)-year(hire_date)),0)
      from hr
      where termdate is not null and termdate <=curdate();
      
      
      -- 6. how does the gender distribution vary across dept. and job titles
      
      select department,jobtitle,gender,count(*) as count
      from hr
      where termdate is not null
      group by department,jobtitle,gender
      order by department,jobtitle,gender;
      
      -- 7. what is distribution of jobtitles across the company
      
      select jobtitle,department, count(*) as count
      from hr 
      where termdate is null
      group by department, jobtitle;
      
      
      -- which dept has the higer turnover/ termination rate 
      
      select department, 
                count(*) as total_count,
                count(case 
                            when termdate is not null and termdate <=curdate() then 1
                            end) as termination_count,
                ROUND((count( case 
                            when termdate is not null and termdate <=curdate() then 1
                            end)/count(*))*100,2) AS TERMINATION_RATE
		    from hr
            group by department
            order by termination_rate desc;
      
-- WHAT IS DISTRIBUTION OF EMP ACROSS LOCATION_STATE

     SELECT LOCATION_STATE, COUNT(*) AS COUNT
     FROM HR
     WHERE TERMDATE IS NULL
     GROUP BY LOCATION_STATE;
      
	 SELECT LOCATION_CITY, COUNT(*) AS COUNT
     FROM HR
     WHERE TERMDATE IS NULL
     GROUP BY LOCATION_CITY;
     
     -- 10. HOW THE COMPANY EMP COUNT CHANGED OVER TIME BASED ON HIRE AND TERNIMATION DATE 
     
      SELECT YEAR,
               HIRES,
			TERMINATIONS,
            HIRES-TERMINATIONS AS NET_CHANGE,
            (TERMINATIONS/HIRES)*100 AS CHANGE_PERCENT
     FROM(
             SELECT YEAR(HIRE_DATE) AS YEAR,
             COUNT(*) AS HIRES,
             SUM(CASE
                     WHEN TERMDATE IS NOT NULL AND TERMDATE <= CURDATE() THEN 1
                     END) AS TERMINATIONS
                     FROM HR 
                     GROUP BY YEAR(HIRE_DATE)) AS SUBQUERY
                     
	GROUP BY YEAR 
    ORDER BY YEAR;
    
    -- 11. WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT
    
    SELECT DEPARTMENT, ROUND(AVG(datediff(TERMDATE,HIRE_DATE)/365),0) AS AVG_TENURE
    FROM HR
    WHERE TERMDATE IS NOT NULL AND TERMDATE<= curdate()
    GROUP BY DEPARTMENT;
    
    -- 12. termination and hire breakdown gender wise 
    
    select 
        gender, 
        total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100,2) as termination_rate
	From(
          select gender,
          count(*) as total_hires,
          count( case
                    when termdate is not null and termdate <= curdate() then 1
                    end) as total_terminations
		from hr 
        group by gender) as subquery
group by gender;
    
  -- age    
  
   select 
        age, 
        total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100,2) as termination_rate
	From(
          select age,
          count(*) as total_hires,
          count( case
                    when termdate is not null and termdate <= curdate() then 1
                    end) as total_terminations
		from hr 
        group by age) as subquery
group by age;

-- department

 select 
        department, 
        total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100,2) as termination_rate
	From(
          select department,
          count(*) as total_hires,
          count( case
                    when termdate is not null and termdate <= curdate() then 1
                    end) as total_terminations
		from hr 
        group by department) as subquery
group by department
order by termination_rate desc;

-- race
select 
        race, 
        total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100,2) as termination_rate
	From(
          select race,
          count(*) as total_hires,
          count( case
                    when termdate is not null and termdate <= curdate() then 1
                    end) as total_terminations
		from hr 
        group by race) as subquery
group by race
order by termination_rate desc;

-- year

select 
        year, 
        total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100,2) as termination_rate
	From(
          select year,
          count(*) as total_hires,
          count( case
                    when termdate is not null and termdate <= curdate() then 1
                    end) as total_terminations
		from hr 
        group by year) as subquery
group by year
order by termination_rate desc;
