
--Data we will be using
SELECT continent, Location, date, total_cases, new_cases, total_deaths, population
FROM DataExploration..CovidDeaths
WHERE continent is not null
ORDER BY 1,2,3


--Total Cases vs Total Deaths
--Shows the percentage of deaths
SELECT continent, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM DataExploration..CovidDeaths
WHERE continent is not null
ORDER BY 1,2,3


--Toal Cases vs Population
--Shows the percentage of the popuation affected by covid
SELECT continent, Location, date, population, total_cases, (total_cases/population)*100 as CovidContractionPecentage
FROM DataExploration..CovidDeaths
WHERE continent is not null
ORDER BY 1,2,3


--Countries with Highest infection rate compared to population
SELECT continent, Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM DataExploration..CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY PercentagePopulationInfected desc


--Coutries with Highest death count per population
SELECT continent, Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM DataExploration..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Contintents with Highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM DataExploration..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM DataExploration..CovidDeaths
WHERE continent is not null
order by 1,2


--Global Numbers by Date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM DataExploration..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2


--Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int))
  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM DataExploration..CovidDeaths dea
JOIN DataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


--Using CTE to perform calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int))
  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM DataExploration..CovidDeaths dea
JOIN DataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Using Temp Tables to perform calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int))
  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM DataExploration..CovidDeaths dea
JOIN DataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later Visualization
CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int))
  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM DataExploration..CovidDeaths dea
JOIN DataExploration..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null