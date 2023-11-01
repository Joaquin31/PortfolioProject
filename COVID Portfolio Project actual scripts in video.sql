SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location ='Chile'
ORDER BY 1,2 


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Chile'
ORDER BY 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Chile'
GROUP BY location, population
ORDER BY InfectedPercentage DESC


-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--convert nvchar into integer
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Chile'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Breaking down by Continent

-- Showing continents with the highest Death Counts per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

-- Total Global

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 


-- Looking at Total Population vs Vaccinations
-- New Vaccinations per day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Creating View to store data for later visualizations

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *
from PercentPopulationVaccinated