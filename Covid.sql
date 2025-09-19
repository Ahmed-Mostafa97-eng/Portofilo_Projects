Use coviddeaths;
USE covidvaccinations;
SELECT * 
FROM coviddeaths
ORDER BY 3,4;

-- Fill the blanks with NULLS
/*UPDATE coviddeaths
SET continent = NULL
WHERE continent = '';*/
    
-- select the data that I am going to use it
SELECT location, date, total_cases,new_cases,total_deaths,population
FROM coviddeaths
ORDER BY 1,3;

-- Looking at Total cases Vs Total Deathes
-- show likelihood of dying percentages in Egypt
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Deathes_percentage
FROM coviddeaths
WHERE location LIKE '%Austria%'
order by 1,3;

-- Looking at Total cases Vs Population
-- show percentge of infected people in Egypt
SELECT location, date, total_cases, Population , (total_cases/Population)*100 AS Infected_percentage
FROM coviddeaths
WHERE location LIKE '%Egypt%'
order by 1,3;

-- Looking at the most infected country COMPARED TO population

SELECT location,Population ,MAX(total_cases) AS Highest_infected_cases , MAX((total_cases/Population))*100 AS Infected_percentage
FROM coviddeaths
where continent is not NULL
GROUP BY location, Population
ORDER BY Infected_percentage DESC;

-- Showing location with Highest Death count per population

SELECT location,MAX(CAST(total_deaths AS SIGNED)) AS Highest_Deathes_numbers
FROM coviddeaths
where continent is not NULL
GROUP BY location
ORDER BY  Highest_Deathes_numbers DESC;

-- Let's breakdown things by continets
-- Showing continents with Highest Death count per population

SELECT continent,MAX(CAST(total_deaths AS SIGNED)) AS Highest_Deathes_numbers
FROM coviddeaths
where continent is not NULL
GROUP BY continent
ORDER BY  Highest_Deathes_numbers DESC;


-- Global 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Deathes_percentage
FROM coviddeaths
-- WHERE location LIKE '%Egypt%'
where continent is not NULL
order by 1,3;

SELECT  SUM(new_cases) as Total_cases , SUM(new_deaths) AS Total_deathes,  (SUm(new_deaths)/SUM(new_cases)) *100 AS Death_percentage
FROM coviddeaths
-- where location LIKE "%Egypt%"
where continent is not NULL
-- GROUP BY date
order by 1,2;


-- Looking at Total population VS Total Vacinations
with popvsVac (continent,location,date,population,new_vaccinations,Rollig_Vaccinated_people)
as (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (partition by dea.location order by dea.location,dea.date ) AS Rollig_Vaccinated_people
FROM coviddeaths dea 
JOIN covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
	AND dea.continent <> ''
-- ORDER by 2,3
)
select *, (Rollig_Vaccinated_people/population) *100  as Percentage_of_vaccinated_people
from popvsVac
order by 2,3 DESC;


-- TEMP Table

CREATE TEMPORARY TABLE PerecentVaccinatedPopulation (
continent VARCHAR(255),
location VARCHAR(255),
date date,
population numeric,
new_vaccinations numeric,
Rollig_Vaccinated_people numeric );

INSERT INTO PerecentVaccinatedPopulation
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%m/%d/%y') AS date,
    dea.population, 
    NULLIF(vac.new_vaccinations, '') AS new_vaccinations,
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%m/%d/%y')) AS Rollig_Vaccinated_people
FROM coviddeaths dea
JOIN covidvaccinations vac
      ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
  AND dea.continent <> '';

select *, (Rollig_Vaccinated_people/population) *100  as Percentage_of_vaccinated_people
from PerecentVaccinatedPopulation;


-- Creare view to store data for for later visualizations
CREATE VIEW PerecentVaccinatedPopulations AS
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%m/%d/%y') AS date,
    dea.population, 
    NULLIF(vac.new_vaccinations, '') AS new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
      ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
  AND dea.continent <> '';

SELECT *,
       SUM(CAST(new_vaccinations AS UNSIGNED)) 
           OVER (PARTITION BY location ORDER BY date) AS Rollig_Vaccinated_people,
       (SUM(CAST(new_vaccinations AS UNSIGNED)) 
           OVER (PARTITION BY location ORDER BY date) / population) * 100 AS Percentage_of_vaccinated_people
FROM PerecentVaccinatedPopulations  
ORDER BY location, date DESC;






