SELECT *
FROM portfolioproject..coviddeaths
WHERE continent is not null
ORDER by 3,4

--SELECT *
--FROM portfolioproject..covidvaccinations
--ORDER by 3,4

-- Select the data that we are going to be using

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM portfolioproject..coviddeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you get covid in your country
SELECT location, date, total_cases, total_deaths, 
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
order by 1,2


--Looking at the Total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases,
(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2


--Looking at Countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) as HighestInfectionCount,
(MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
group by location,population
order by PercentPopulationInfected desc


--Showing countries with Highest Death Count per Population

SELECT location, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
group by location
order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENTS

SELECT continent, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
group by continent
order by TotalDeathCount desc




--Showing continents with highest death count per population

SELECT continent, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

SELECT SUM(new_cases)as total_cases, SUM(new_deaths) as total_deaths,SUM(convert(float,new_deaths))/SUM(nullif(convert(float,new_cases),0))*100 as DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--group by DATE
order by 1,2


--Looking at total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent is not null
order by 2,3


-- Use CTE

with PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent is not null
--order by 2,3
)
SELECT * , (Convert(float,RollingPeopleVaccinated)/nullif(convert(float,Population),0))*100
--(MAX(CONVERT(float,FIRST_COLUMN_NAME)/NULLIF(CONVERT(float,SECOND_COLUMN_NAME),0)))*100
from PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPeopleVaccinated
Create TABLE #PercentPeopleVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population NUMERIC,
    New_vaccination NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

Insert Into #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent is not null
--order by 2,3

SELECT * , (Convert(float,RollingPeopleVaccinated)/nullif(convert(float,Population),0))*100
from #PercentPeopleVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPeopleVaccinated