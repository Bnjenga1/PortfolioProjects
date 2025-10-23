USE portfolio_projects;

SELECT * FROM covid_deaths WHERE continent is not null AND TRIM(continent) != '' ORDER BY 3, 4;

SELECT * FROM covid_vaccinations ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent is not null AND TRIM(continent) != ''
ORDER BY 1, 2;

-- Looking at Total Cases VS Total Deaths in my country
-- Shows likelihood of dying if you contract covid in Kenya
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE location like '%kenya%' AND continent is not null AND TRIM(continent) != ''
ORDER BY 1, 2;

-- Looking at the Total cases vs Population
-- Shows what percentage of people in Kenya have Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageContracted
FROM covid_deaths
WHERE location like '%kenya%' AND continent is not null AND TRIM(continent) != ''
ORDER BY 1, 2;

-- Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageContracted
FROM covid_deaths
-- WHERE location like '%kenya%'
WHERE continent is not null AND TRIM(continent) != ''
GROUP BY location, population
ORDER BY PercentageContracted DESC;

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
-- WHERE location like '%kenya%'
WHERE continent is not null AND TRIM(continent) != ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's Break things down by continent
-- Showing the continents with the highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
-- WHERE location like '%kenya%'
WHERE TRIM(continent) = ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM covid_deaths
-- WHERE location like '%kenya%' 
WHERE continent is not null AND TRIM(continent) != ''
GROUP BY date
ORDER BY 1, 2;

-- Looking at Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location =vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null AND TRIM(dea.continent) != ''
ORDER BY 2, 3;

-- Use CTE
WITH PopvsVac (continent, location, date, population, vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location =vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND TRIM(dea.continent) != ''
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac;

-- TEMP TABLE
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated  numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location =vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null AND TRIM(dea.continent) != ''
ORDER BY 2, 3;

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location =vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null AND TRIM(dea.continent) != '';

SELECT * FROM PercentPopulationVaccinated;

