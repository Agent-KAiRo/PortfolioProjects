
SELECT Location , date , total_cases , new_cases , total_deaths , population
FROM PortfolioProjects..coviddeaths
order by 1,2

-- Looking at the Total cases vs Total deaths
--Shows the likelihood of Dying if we contract Covid
SELECT Location , date , total_cases , total_deaths , population , (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..coviddeaths
where Location like '%India%'
order by 1,2

--Looking at the Total cases vs population
--Shows the percentage of people affected by Covid 
SELECT Location , date , total_cases ,  population , (total_cases/population)*100 as CovidAffected
FROM PortfolioProjects..coviddeaths
where Location like '%India%'
order by 1,2

--Looking at Countries with Highest Infection count compared to Population
SELECT Location ,  population ,max(total_cases) as HighestInfectioncount , (max(total_cases)/population)*100 as Percentpopinfected
FROM PortfolioProjects..coviddeaths
where continent is not NULL 
group by Location , population
order by Percentpopinfected desc

--Countries with the Highest Death count per population
SELECT Location ,  population ,max(cast(total_deaths as int)) as HighestDeathcount , (max(total_deaths)/population)*100 as Percentpopdied
FROM PortfolioProjects..coviddeaths
where continent is not NULL 
group by Location , population
order by HighestDeathcount desc

--BREAKING DOWN THE THINGS NOW ON THE BASIS OF CONTINENTS
-- Showing the continents with the highest death count
SELECT continent ,max(cast(total_deaths as int)) as HighestDeathcount
FROM PortfolioProjects..coviddeaths
where continent is NOT NULL 
group by continent
order by HighestDeathcount desc

-- Global Numbers
--By each date
Select date ,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..coviddeaths
where continent is not null 
Group By date
order by 1,2

--Total cases and deaths worldwide
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..coviddeaths
where continent is not null 
order by 1,2

--Total Population vs Vaccination
select dea.continent,  dea.location , dea.population ,dea.date, vac.new_vaccinations , Sum (Convert (int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..coviddeaths dea
Join PortfolioProjects..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent , Location , Date, Population , new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent,  dea.location , dea.population ,dea.date, vac.new_vaccinations , Sum (Convert (int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..coviddeaths dea
Join PortfolioProjects..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
Select * , (RollingPeopleVaccinated/Population)/100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255) , Location nvarchar(255) , Date datetime , Population numeric, RollingPeopleVaccinated numeric 
)
Insert into #PercentPopulationVaccinated
select dea.continent,  dea.location , dea.population ,dea.date, vac.new_vaccinations , Sum (Convert (int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..coviddeaths dea
Join PortfolioProjects..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Select * , (RollingPeopleVaccinated/Population)/100
From #PercentPopulationVaccinated

--Creating View to store data for visualization
Create View PercentPopulationVaccinated as
Select dea.continent,  dea.location , dea.population ,dea.date, vac.new_vaccinations , Sum (Convert (int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProjects..coviddeaths dea
Join PortfolioProjects..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
