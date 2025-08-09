/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views,
Converting Datatypes

*/

DROP DATABASE IF EXISTS PortfolioProject1;
CREATE DATABASE PortfolioProject1;
USE PortfolioProject1;

CREATE TABLE CovidDeaths (
	iso_code NVARCHAR(255) NULL,
	continent NVARCHAR(255) NULL,
	location NVARCHAR(255) NULL,
	date DATETIME NULL,
	population FLOAT NULL,
	total_cases FLOAT NULL,
	new_cases FLOAT NULL,
	new_cases_smoothed FLOAT NULL,
	total_deaths NVARCHAR(255),
	new_deaths NVARCHAR(255),
	new_deaths_smoothed FLOAT NULL,
	total_cases_per_million FLOAT NULL,
	new_cases_per_million FLOAT NULL,
	new_cases_smoothed_per_million FLOAT NULL,
	total_deaths_per_million NVARCHAR(255),
	new_deaths_per_million NVARCHAR(255),
	new_deaths_smoothed_per_million FLOAT NULL,
	reproduction_rate NVARCHAR(255) NULL,
	icu_patients NVARCHAR(255) NULL,
	icu_patients_per_million NVARCHAR(255) NULL,
	hosp_patients NVARCHAR(255) NULL,
	hosp_patients_per_million NVARCHAR(255) NULL,
	weekly_icu_admissions NVARCHAR(255) NULL,
	weekly_icu_admissions_per_million NVARCHAR(255) NULL,
	weekly_hosp_admissions NVARCHAR(255) NULL,
	weekly_hosp_admissions_per_million NVARCHAR(255) NULL
);

CREATE TABLE CovidVaccinations (
	iso_code NVARCHAR(255) NULL,
	continent NVARCHAR(255) NULL,
	location NVARCHAR(255) NULL,
	date DATETIME NULL,
	new_tests NVARCHAR(255) NULL,
	total_tests NVARCHAR(255) NULL,
	total_tests_per_thousand NVARCHAR(255) NULL,
	new_tests_per_thousand NVARCHAR(255) NULL,
	new_tests_smoothed NVARCHAR(255) NULL,
	new_tests_smoothed_per_thousand NVARCHAR(255) NULL,
	positive_rate NVARCHAR(255) NULL,
	tests_per_case NVARCHAR(255) NULL,
	tests_units NVARCHAR(255) NULL,
	total_vaccinations NVARCHAR(255) NULL,
	people_vaccinated NVARCHAR(255) NULL,
	people_fully_vaccinated NVARCHAR(255) NULL,
	new_vaccinations NVARCHAR(255) NULL,
	new_vaccinations_smoothed NVARCHAR(255) NULL,
	total_vaccinations_per_hundred NVARCHAR(255) NULL,
	people_vaccinated_per_hundred NVARCHAR(255) NULL,
	people_fully_vaccinated_per_hundred NVARCHAR(255) NULL,
	new_vaccinations_smoothed_per_million NVARCHAR(255) NULL,
	stringency_index FLOAT NULL,
	population_density FLOAT NULL,
	median_age FLOAT NULL,
	aged_65_older FLOAT NULL,
	aged_70_older FLOAT NULL,
	gdp_per_capita FLOAT NULL,
	extreme_poverty NVARCHAR(255) NULL,
	cardiovasc_death_rate FLOAT NULL,
	diabetes_prevalence FLOAT NULL,
	female_smokers NVARCHAR(255) NULL,
	male_smokers NVARCHAR(255) NULL,
	handwashing_facilities FLOAT NULL,
	hospital_beds_per_thousand FLOAT NULL,
	life_expectancy FLOAT NULL,
	human_development_index FLOAT NULL
);

/*Download the CSV files and copy the filepath into the FROM clause or alternatively download the .xlsx
files and use the import wizard to populate the tables.*/

BULK INSERT PortfolioProject1.dbo.CovidDeaths
FROM "D:\PortfolioProjects\CovidProject\data\CovidDeaths.csv"
WITH
(
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);

BULK INSERT PortfolioProject1.dbo.CovidVaccinations
FROM "D:\PortfolioProjects\CovidProject\data\CovidVaccinations.csv"
WITH
(
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);

SELECT * FROM CovidDeaths;
SELECT * FROM CovidVaccinations;

SELECT * 
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

--Looking at the Total Cases vs Total Deaths
--shows likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100, 2) AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1, 2;

--Looking at Total Cases vs Population
--Shows what percentage of population got COVID
SELECT location, date, population, total_cases, ROUND((total_cases/population) * 100, 2) AS PopulationPercentageInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1, 2;

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population)) * 100, 2) AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--BREAKING THINGS DOWN BY CONTINENT

--Showing Countries with highest death count percentage per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

--Looking at Total Population vs. Vaccinations
--Shows percentage of population that has recieved at least one Covid Vaccine
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USE CTE to perform calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac;


--TEMP TABLE to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated;

--Creating View to store data for later visualizations
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;	
GO
