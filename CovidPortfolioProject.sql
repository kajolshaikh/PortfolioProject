
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Global Numbers

Select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS TOTAL_DEATHS, SUM(CAST(new_deaths AS int))/sum(new_cases)*100
as deathgpercentage
-- total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
group by date
order by 1,2



select * from Portfolioproject..CovidVaccinations

-- Joining Tables :looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated

from Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3


---- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(Continent, Location, date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated

from Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 1,2,3
)

select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp  Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated

from Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 1,2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to visulaize data in tableau later on.

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations Vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated
