-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,1) AS Death_Percentage
FROM CovidDeaths
WHERE location='Ghana' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
--shows the percentage of the population that contracted covid

SELECT location, date, total_cases, population, round((total_cases/population)*100,1) AS CaseCount
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT continent,MAX(total_cases) AS Highest_InfectionCount,  round(MAX((total_cases/population))*100,1) AS PopulationInfectedPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PopulationInfectedPercent desc



-- This is showing Countries with Highest Death Count compared to Population

SELECT location,  MAX(CAST(total_deaths AS INT)) AS Total_Death_Count, ROUND(MAX((total_deaths/population))*100,1) AS DeathCountPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathCountPercent DESC

-- This is showing Continents with Highest Death Count compared to Population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count, ROUND(MAX((total_deaths/population))*100,1) AS DeathCountPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCountPercent DESC


 --Total Population vs Vaccination by Location
 Select v.location, SUM(CAST(total_vaccinations AS numeric)) AS Total_Vaccinated, SUM(population) AS Total_Population   from
CovidDeaths d
join CovidVaccinations v
on d.location = v.location
 AND d.date = v.date
 WHERE d.continent IS NOT NULL
 GROUP BY v.location


-- GLOBAL NUMBERS 1

SELECT SUM(new_cases) AS NewCasesTotal, SUM(CAST(new_deaths AS INT)) AS NewDeathsTotal, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,1) AS DeathPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- GLOBAL NUMBERS 2


SELECT date, SUM(new_cases) AS NewCasesTotal, SUM(CAST(new_deaths AS INT)) AS NewDeathsTotal, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,1) AS DeathPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2




Select * from
CovidDeaths d
join CovidVaccinations v
on d.location = v.location
 AND d.date = v.date


 -- Looking at Total Population vs Vaccination

 Select d.continent, d.location, d.date,d.population,v.new_vaccinations, SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
 --, ROUND((RollingPeopleVaccinated/d.population)*100,1) AS PopulationVaccinatedPercent
 from CovidDeaths d
join CovidVaccinations v
on d.location = v.location
 AND d.date = v.date
  WHERE d.continent IS NOT NULL
 ORDER BY 2,3


 -- ## CTE USE

 -- USE CTE
 -- NUMBER OF COLUMNS IN THE SELECT WITHIN CTE SHOULD BE SAME AS NUMBER EXPRESSED IN CTE
 -- WE USED PARTITION BY BECAUSE WE WANTED A CUMULATIVE COUNT DOWNWARDS WITH EVERY PASSING DAY. NEW VACCINATIONS GET ADDED TO ROLLINGPEOPLEVACCINATED AFTER EVERY CHANGE IN NEW VACCINATIONS.  
 WITH PopVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)  AS
 (
 
 Select d.continent, d.location, d.date,d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
 --, ROUND((RollingPeopleVaccinated/d.population)*100,1) AS PopulationVaccinatedPercent #THIS CAN'T BE HERE AS RollingPeopleVaccinated IS NOT AN ORIGINAL COLUMN REASON THIS IS IN A CTE
 from CovidDeaths d
join CovidVaccinations v
on d.location = v.location
 AND d.date = v.date
  WHERE d.continent IS NOT NULL
 --ORDER BY 2,3 #can't be in here
 )

 --YOU CAN NOW SELECT AND MANIPULATE THIS HOW YOU LIKE COURTESY OF THE CTE
 Select *,ROUND((RollingPeopleVaccinated/Population)*100,1) AS PopulationVaccinatedPercent from PopVac


 -- ## END OF CTE USE

 --WE COULD ALSO USE A TEMP TABLE 
 --TEMP TABLE


 DROP TABLE IF EXISTS #PopulationVaccinated

 CREATE TABLE #PopulationVaccinated

 (Continent NVARCHAR(255),
 Location NVARCHAR(255),
 Date datetime,
 Population NUMERIC,
 New_Vaccinations NUMERIC,
 RollingPeopleVaccinated NUMERIC)

 INSERT INTO #PopulationVaccinated
 Select d.continent, d.location, d.date,d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS NUMERIC)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
 --, ROUND((RollingPeopleVaccinated/d.population)*100,1) AS PopulationVaccinatedPercent #THIS CAN'T BE HERE AS RollingPeopleVaccinated IS NOT AN ORIGINAL COLUMN REASON THIS IS IN A CTE
 from CovidDeaths d
join CovidVaccinations v
on d.location = v.location
 AND d.date = v.date
  WHERE d.continent IS NOT NULL

Select *,ROUND((RollingPeopleVaccinated/Population)*100,1) AS PopulationVaccinatedPercent from #PopulationVaccinated



 -- Creating View to store data for later visualizations
 

 CREATE VIEW PercentPopulationVaccinated AS
 
 Select d.continent, d.location, d.date,d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
 --, ROUND((RollingPeopleVaccinated/d.population)*100,1) AS PopulationVaccinatedPercent #THIS CAN'T BE HERE AS RollingPeopleVaccinated IS NOT AN ORIGINAL COLUMN REASON THIS IS IN A CTE
 from CovidDeaths d
join CovidVaccinations v
on d.location = v.location
 AND d.date = v.date
  WHERE d.continent IS NOT NULL
 --ORDER BY 2,3 #can't be in here



 -- Creating View to store Death Percentage in Ghana

 CREATE VIEW DeathPercentageGhana AS
 SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,1) AS Death_Percentage
FROM CovidDeaths
WHERE location='Ghana' AND continent IS NOT NULL
--ORDER BY 1,2

--Creating View for Case Count by Location

CREATE VIEW CaseCountLocation AS 
SELECT location, date, total_cases, population, round((total_cases/population)*100,1) AS CaseCount
FROM CovidDeaths
WHERE continent IS NOT NULL
--ORDER BY 1,2

-- Creating View to check Population Infected per Continent

CREATE VIEW PopulationInfectedContinent AS
SELECT continent,MAX(total_cases) AS Highest_InfectionCount,  round(MAX((total_cases/population))*100,1) AS PopulationInfectedPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY PopulationInfectedPercent desc


--Creating View to check Death Count By Location

CREATE VIEW DeathCountLocation AS
SELECT location,  MAX(CAST(total_deaths AS INT)) AS Total_Death_Count, ROUND(MAX((total_deaths/population))*100,1) AS DeathCountPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY DeathCountPercent DESC

--Creating View Death Count by Continent

CREATE VIEW DeathCountContinent AS 
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count, ROUND(MAX((total_deaths/population))*100,1) AS DeathCountPercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY DeathCountPercent DESC
