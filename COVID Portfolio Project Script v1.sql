
Select *
From PortfolioDatabase..CovidDeaths
order by 3,4

--Select *
--From PortfolioDatabase..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioDatabase..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioDatabase..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioDatabase..CovidDeaths
-- where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioDatabase..CovidDeaths
-- where location like '%states%'
group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioDatabase..CovidDeaths
-- where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc


--Let's break things down by continent

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioDatabase..CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioDatabase..CovidDeaths
-- where location like '%states%'
where continent is null and location NOT LIKE '%income%'
group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population 

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioDatabase..CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc 


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as bigint)) as total_deaths, 
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioDatabase..CovidDeaths
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location 
  Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioDatabase..CovidDeaths dea
Join PortfolioDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location 
  Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioDatabase..CovidDeaths dea
Join PortfolioDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location 
  Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioDatabase..CovidDeaths dea
Join PortfolioDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location 
  Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioDatabase..CovidDeaths dea
Join PortfolioDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
From PercentPopulationVaccinated