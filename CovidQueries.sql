SELECT *
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL 
	ORDER BY 3,4;

-- Looking at total cases vs. total deaths
-- Likelyhood of dying if one has covid
SELECT location, date, total_cases, total_deaths, ROUND(((total_deaths/total_cases)*100),2) AS  DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location LIKE '%states%' AND continent IS NOT NULL
	ORDER BY location, date;

-- Total cases vs population
-- Percentage of how many got covid
SELECT location, date, population, total_cases, ROUND(((total_cases/population)*100),2) AS  CasePercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location = 'Mexico'
	WHERE continent IS NOT NULL
	ORDER BY location, date;

SELECT location, date, population, total_cases, ROUND(((total_cases/population)*100),2) AS  CasePercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location = 'United States' AND continent IS NOT NULL
	ORDER BY location, date;

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND(((total_cases/population)*100),2)) AS  PercentPopulationInfected
	FROM PortfolioProject..CovidDeaths
	--WHERE location = 'United States'
	WHERE continent IS NOT NULL
	GROUP BY location, population
	ORDER BY PercentPopulationInfected DESC;

SELECT location, MAX(CAST(total_deaths AS int)) AS totaldeathcount
	FROM PortfolioProject..CovidDeaths
	--WHERE location = 'United States'
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY totaldeathcount DESC;


-- Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS totaldeathcount
	FROM PortfolioProject..CovidDeaths
	--WHERE location = 'United States'
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY totaldeathcount DESC;

-- Showing continents with highest death count
SELECT location, MAX(CAST(total_deaths AS int)) AS totaldeathcount
	FROM PortfolioProject..CovidDeaths
	--WHERE location = 'United States'
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY totaldeathcount DESC;

-- Global numbers
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100,3) AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 1,2;

-- GLobal numbers by day
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100,3) AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY 1,2; 

-- Total population vs. vaccinations - MEXICO/USA
-- cd = coviddeaths      cv = covidvaccinations
SELECT cd.continent, cd.location,cd.date, cd.population,cv.people_fully_vaccinated, cv.new_vaccinations, 
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS NumberOfVaccinations
	FROM PortfolioProject..CovidDeaths AS cd
	JOIN PortfolioProject..CovidVaccinations AS cv
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL AND cd.location = 'United States'
	ORDER BY 2,3;

SELECT cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths AS cd
	JOIN PortfolioProject..CovidVaccinations AS cv
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL AND cd.location = 'Mexico'
	ORDER BY 2,3;

-- Percentage of people that died from covid
SELECT location, population, MAX(CAST(total_deaths AS bigint)) AS TotalDeaths, ROUND(MAX(CAST(total_deaths as bigint)/population*100),3) AS PercentDeathsVsPop
	FROM PortfolioProject..CovidDeaths
	WHERE location = 'United States' OR location = 'Mexico'
	GROUP BY location, population


-- Vaccination percentage Vs. Population
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths AS cd
	JOIN PortfolioProject..CovidVaccinations AS cv
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL AND cd.location = 'United States'
	--ORDER BY 2,3;

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,3) AS VaccinationPercentVsPop
	FROM #PercentPopulationVaccinated

--******             VIEWS             ******
--******             VIEWS             ******
--******             VIEWS             ******


CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths AS cd
	JOIN PortfolioProject..CovidVaccinations AS cv
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL

--Chance of Death from Covid
USE PortfolioProject
GO
CREATE VIEW ChanceOfDeath AS
	SELECT location, date, total_cases, total_deaths, ROUND(((total_deaths/total_cases)*100),2) AS  DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location = 'United States' OR location = 'Mexico' AND continent IS NOT NULL

-- Total cases vs population
-- Percentage of how many got covid
USE PortfolioProject
GO
CREATE VIEW CasesVsPop AS
SELECT location, date, population, total_cases, ROUND(((total_cases/population)*100),2) AS  CasePercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location = 'Mexico' OR location = 'United States' AND continent IS NOT NULL

-- Showing countries with highest death count per population
USE PortfolioProject
GO
CREATE VIEW CountriesDeathCount AS
SELECT location, MAX(CAST(total_deaths AS int)) AS totaldeathcount
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY location

-- GLobal numbers by day
USE PortfolioProject
GO
CREATE VIEW GlobalNumbers AS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100,3) AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY date

-- Hospital patients from covid
USE PortfolioProject
GO
CREATE VIEW HospitalPatientsCovid AS
SELECT date, location, population, total_cases AS TotalCases, hosp_patients AS HospitalPatients
	FROM PortfolioProject..CovidDeaths
	WHERE location = 'United States'
		AND continent IS NOT NULL
		AND date > '2020-07-14 00:00:00.000'
	--ORDER BY location, date

SELECT *
	FROM PortfolioProject..CovidDeaths
	WHERE location = 'United States'
SELECT *
	FROM PortfolioProject..CovidVaccinations
	WHERE location = 'United States'

USE PortfolioProject
GO
CREATE VIEW ICUPatientsVsHospPatients AS
SELECT date, location, CAST(hosp_patients AS int) AS HospitalPatients, CAST(icu_patients AS int) AS ICUpatients
	FROM PortfolioProject..CovidDeaths
	WHERE location = 'United States' 
		AND location IS NOT NULL
		AND date > '2020-07-14 00:00:00.000'
	

