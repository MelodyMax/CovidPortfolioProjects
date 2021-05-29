
-- Analyzing the CovidDeaths and CovidVaccinations Data 

Select *
From PortfolioProject..CovidDeaths
Order by 3, 4

Select *
From PortfolioProject..CovidVaccinations
Order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population) * 100  as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'United States'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population) * 100) as 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'United States'
Group by location, population
Order by PercentPopulationInfected desc

--Showing countries with Highest Death count per Population
--Convert it to integer

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'United States
Where continent is not null
Group by location
Order by HighestDeathCount desc

--BREAK THINGS DOWN BY CONTINENT
--this is the right data for continent

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'United States
Where continent is null
Group by location
Order by HighestDeathCount desc

--But we're gonna use this instead

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'United States
Where continent is not null
Group by continent
Order by HighestDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
	as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
	as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--VACCINATION DATASET

--Looking at Total Population vs Vaccinations

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)


Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From PopvsVac

--TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


--Creating View for storing data for later visualizations

Create View	PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

---New Queries for Tableau Visualization

--1. Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
	as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--2. TotalDeathCount Per Continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
	and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

--3. Infection Count and Percentage by Country

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population) * 100) as 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

--4. Date, Infection Count and Pecentage by Country

Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population) * 100) as 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected desc

-- UNITED STATES DATA

--5. Total Cases and Death Percentage

Select date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
Order by 1

--Extras for vizualization same as above

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
	as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
Order by 1,2

--6. United States Positive Rate Vs Total Vaccinations 

Select date,positive_rate, new_vaccinations, total_vaccinations
From PortfolioProject..CovidVaccinations
Where location = 'United States'
Order by 1

--7. Unites States Vaccination vs Death Percentage

Select dea.date, dea.population, 
	vac.people_fully_vaccinated, 
	(dea.new_deaths/dea.new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'United States'
Order by 1

--8.  United States Vaccinations vs Number of Hospitalization and ICU

Select dea.date, dea.new_cases,
	dea.icu_patients, dea.hosp_patients,
	(vac.people_fully_vaccinated/dea.population)*100 as PercentageFullyVaccinated,
	vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'United States'
Order by 1


-- 10. United States Covid Summary (Vaccinations, Death Percentage, Hospitalization)

Select dea.location, dea.date, dea.new_cases,
	(dea.new_cases/dea.population)*100 as PercentageInfection,
	dea.icu_patients, dea.hosp_patients,
	(dea.new_deaths/dea.new_cases)* 100 as DeathPercentage,
	(vac.people_fully_vaccinated/dea.population)*100 as PercentageFullyVaccinated,
	vac.new_vaccinations,
	vac.people_fully_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'United States'
Order by 1, 2

