SELECT *
FROM PortifolioProject..Dataset01_CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *

--FROM PortifolioProject..Dataset02_CovidVaccinations
--ORDER BY 3,4

-- Select the data that i'm going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortifolioProject..Dataset01_CovidDeaths
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM PortifolioProject..Dataset01_CovidDeaths
WHERE location like '%brazil%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as ContaminationPercentage
FROM PortifolioProject..Dataset01_CovidDeaths
WHERE location like '%brazil%'
ORDER BY 1,2

-- Looking at Countries with higher infection rates compared to population

SELECT location, population, MAX(total_cases) as HighesInfectionCount, MAX((total_cases/population))*100 as ContaminationPercentage
FROM PortifolioProject..Dataset01_CovidDeaths
--WHERE location like '%brazil%'
GROUP BY location, population
ORDER BY ContaminationPercentage Desc


-- Looking at Countries with Highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortifolioProject..Dataset01_CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount Desc


-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortifolioProject..Dataset01_CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc

--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortifolioProject..Dataset01_CovidDeaths
--WHERE continent is null
--GROUP BY location
--ORDER BY TotalDeathCount Desc

-- Global Numbers

-- Contamination by day

SELECT date, SUM(new_cases) as SumOfCases, SUM(cast(new_deaths as int)) as SumOfDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
FROM PortifolioProject..Dataset01_CovidDeaths
--WHERE location like '%brazil%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total Contamination

SELECT SUM(new_cases) as SumOfCases, SUM(cast(new_deaths as int)) as SumOfDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
FROM PortifolioProject..Dataset01_CovidDeaths
--WHERE location like '%brazil%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountVaccination
--, (RollingCountVaccination/population)*100
FROM PortifolioProject..Dataset01_CovidDeaths dea
JOIN PortifolioProject..Dataset02_CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountVaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountVaccination
--, (RollingCountVaccination/population)*100
FROM PortifolioProject..Dataset01_CovidDeaths dea
JOIN PortifolioProject..Dataset02_CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingCountVaccination/Population)*100
FROM PopvsVac


-- TEMP Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination float,
RollingCountVaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountVaccination
--, (RollingCountVaccination/population)*100
FROM PortifolioProject..Dataset01_CovidDeaths dea
JOIN PortifolioProject..Dataset02_CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingCountVaccination/Population)*100
FROM #PercentPopulationVaccinated

-- Creating a View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountVaccination
--, (RollingCountVaccination/population)*100
FROM PortifolioProject..Dataset01_CovidDeaths dea
JOIN PortifolioProject..Dataset02_CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3