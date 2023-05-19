SELECT *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4


--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Select Data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2


-- Looking at the total cases VS Total Deaths
-- Shows the likelihood of dying if you get infected by covid
SELECT location, Date, total_cases, total_deaths, round((total_deaths / total_cases)*100, 2) AS DeathRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'South Africa'
order by 1,2


-- Looking at total cases VS population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS PercentageOfInfectedPeople
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'South Africa'
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageOfInfectedPeople
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'South Africa'
GROUP BY location, population
order by PercentageOfInfectedPeople DESC

-- Showing the countries with the highest death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'South Africa'
where continent is not null
GROUP BY location
order by TotalDeathCount DESC



-- LETS break things down by location
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'South Africa'
where continent is null
GROUP BY location
order by TotalDeathCount DESC

-- Lets break things down by continent with higest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'South Africa'
where continent is null
GROUP BY location
order by TotalDeathCount DESC



-- Showing the continent with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'South Africa'
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC


-- GlobL numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 3) as PercentageDeathRate
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'South Africa'
where continent is not null
group by date
order by 1,2

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 3) as PercentageDeathRate
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location = 'South Africa'
where continent is not null
--group by date
order by 1,2



-- Selecting the CovidVaccination table
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) AS RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE
WITH PopulationVSVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) AS RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageOFVaccinatedPeople
FROM PopulationVSVaccination



-- USING TEMP TABLE
-- Code below does not work
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) AS RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store datae for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.Date) AS RollingPeopleVaccinated 
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated





