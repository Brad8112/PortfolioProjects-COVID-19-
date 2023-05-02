SELECT * FROM CovidDeaths
Where continent IS NOT NULL
Order by 3, 4; 

SELECT location, dateevent, totalcases, newcases, totaldeaths, population
From CovidDeaths
Where continent IS NOT NULL
Order by 1, 2;

--Looking at the Total cases Vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country
SELECT location, dateevent, totalcases, totaldeaths, (Totaldeaths/totalcases)*100 AS DeathPercentage
From CovidDeaths
Where Location like '%Vietnam%'
Order by 1, 2;

--Looking at Total Cases vs Population 
--Shows what percentage of population getting COVID
SELECT location, dateevent, population, totalcases, (TotalCases/Population)*100 AS PercentageOfCases 
From CovidDeaths
Where Location like '%Vietnam%'
Order by Location, dateevent;

--Looking at countries with the highest infection rate compared to population 

SELECT location, population, MAX(totalcases) as HighestInfectionCount, MAX((TotalCases/Population))*100 AS PercentOfPopulationInfected
From CovidDeaths
WHERE location IS NOT NULL AND population IS NOT NULL AND totalcases IS NOT NULL
Group by Location, Population
Order by PercentOfPopulationInfected desc ;

--Showing Countries With Highest Death Count per Population 

SELECT location, MAX(totaldeaths) as TotalDeathsCount
From CovidDeaths
Where TotalDeaths IS NOT NULL AND continent IS NOT NULL
Group by Location
Order by TotalDeathsCount desc ;

--Break Things Down By Continent

SELECT location, MAX(totaldeaths) as TotalDeathsCount From CovidDeaths
Where TotalDeaths IS NOT NULL AND continent IS NULL
AND location NOT IN ('Low income', 'Lower middle income', 'Upper middle income', 'High income')
Group by location
Order by TotalDeathsCount desc ;

--Showing the continents with the highest death count per population 

SELECT location, MAX(totaldeaths) as TotalDeathsCount From CovidDeaths
Where TotalDeaths IS NOT NULL AND continent IS NULL
AND location NOT IN ('Low income', 'Lower middle income', 'Upper middle income', 'High income')
Group by location
Order by TotalDeathsCount desc ;

--Global Numbers

SELECT dateevent, 
SUM(newcases) as TotalCases, 
SUM(newdeaths) AS TotalDeaths, 
100.0 * SUM(newdeaths) / NULLIF(SUM(newcases), 0) as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY dateevent
ORDER BY 1, 2;

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.dateevent, dea.population, vac.newvaccinations,
SUM (vac.newvaccinations) OVER (Partition by dea.Location Order by dea.Location, dea.dateevent) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.dateevent = vac.dateevent
Where dea.continent is not null
ORDER BY 2, 3;


--Use CTE

With PopulationVsVac (Continent, Location, Dateevent, Population, newvaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.dateevent, dea.population, vac.newvaccinations,
SUM (vac.newvaccinations) OVER (Partition by dea.Location Order by dea.Location, dea.dateevent) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.dateevent = vac.dateevent
Where dea.continent is not null)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopulationVsVac;




--TEMP TABLE

CREATE TABLE PercentPopulationVaccinated (
    Continent varchar (225),
    Location varchar (225),
    Dateevent date, 
    Population numeric, 
    NewVaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.dateevent, dea.population, vac.newvaccinations,
SUM(vac.newvaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.dateevent) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.dateevent = vac.dateevent
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PercentPopulationVaccinated;


--Creating View to store data for later visualization

CREATE OR REPLACE VIEW vw_PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.dateevent, dea.population, vac.newvaccinations,
SUM(vac.newvaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.dateevent) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.dateevent = vac.dateevent
WHERE dea.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated 
