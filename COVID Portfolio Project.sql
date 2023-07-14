/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT *
FROM CovidDeaths cd 
WHERE continent IS NOT NULL 
ORDER BY 3,4
-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths cd 
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM CovidDeaths cd 
WHERE location = 'Nigeria'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Population
--Shows what percentage of population got covid 
SELECT location, date,population, total_cases  , (total_cases  / population)*100 AS PercentPopulationInfected
FROM CovidDeaths cd 
WHERE location = 'Nigeria'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population

SELECT location, population,MAX(total_cases) AS HighestInfectionCount , MAX((total_cases  / population))*100 AS PercentPopulationInfected
FROM CovidDeaths cd 
WHERE continent IS NOT NULL
GROUP BY location ,population 
ORDER BY PercentPopulationInfected desc

--Showing the countries with highest Death count by population

SELECT location, MAX(CAST (total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths cd 
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount desc

-- Breaking things down by continent
-- Showing continents with the highest death count per poopulation

SELECT continent , MAX(CAST (total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths cd 
WHERE continent IS NOT NULL
GROUP BY continent  
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths , SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM CovidDeaths cd 
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1, 2

-- Looking at total population vs vaccinations 

SELECT cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations ,
SUM(cast(cv.new_vaccinations as int)) over (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
from CovidDeaths cd 
join CovidVaccinations cv 
     on cd.location = cv.location 
	 and cd.date = cv.date 
where cd.continent is not null
ORDER BY 2,3

-- USING CTE

WITH PopvsVac (continent, location, date, population,new_vaccinations , RollingPeopleVaccinated)
AS
(
SELECT cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations ,
SUM(cast(cv.new_vaccinations as int)) over (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
from CovidDeaths cd 
join CovidVaccinations cv 
     on cd.location = cv.location 
	 and cd.date = cv.date 
where cd.continent is not null
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- USING TEMP TABLE
drop table if exists #PercentagePopulationVaccinated
CREATE Table #PercentagePopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	RollingPeopleVaccinated numeric
)	
INSERT INTO #PercentagePopulationVaccinated
SELECT cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations ,
SUM(cast(cv.new_vaccinations as int)) over (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
from CovidDeaths cd 
join CovidVaccinations cv 
     on cd.location = cv.location 
	 and cd.date = cv.date 
where cd.continent is not null

SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated

-- Creating view to store data for later visualizations
create view PercentagePopulationVaccinated as
SELECT cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations ,
SUM(cast(cv.new_vaccinations as int)) over (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
from CovidDeaths cd 
join CovidVaccinations cv 
     on cd.location = cv.location 
	 and cd.date = cv.date 
where cd.continent is not null


