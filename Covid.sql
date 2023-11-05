select * 
from portfolioproject..CovidDeaths
where continent is not null
order by 3,4 

select * 
from portfolioproject..CovidVaccinations
where continent is not null
order by 3,4

--Select the Data that we are going to use.
select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
where continent is not null
order by 1,2


--Looking at total cases vs total deaths.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--if you want specific country use the next line.
--where location like '%egypt%'
where continent is not null
order by 1,2


-- Looking at total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
from portfolioproject..CovidDeaths
--if you want specific country use the next line.
--where location like '%states%'
where continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageOfPopulationInfected
from portfolioproject..CovidDeaths
--if you want specific country use the next line.
--where location like '%states%'
where continent is not null
group by location, population
order by PercentageOfPopulationInfected desc


--Showing Countries with Highest Death Count Per Population
select location, population, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as PercentageOfPopulationDeaths
from portfolioproject..CovidDeaths
--if you want specific country use the next line.
--where location like '%states%'
where continent is not null
group by location, population
order by PercentageOfPopulationDeaths desc


--Let's break things down by continent

--showing the conintents with highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from portfolioproject..CovidDeaths
where continent is not null and new_cases is not null
group by date
order by 1,2


--Looking at total population vs vaccinations
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(cast(CovidVaccinations.new_vaccinations as int))over(partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths
join portfolioproject..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null and CovidVaccinations.new_vaccinations is not null
order by 2,3


-- USE CTE (virtual table)

with popVSvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(cast(CovidVaccinations.new_vaccinations as int))over(partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths
join portfolioproject..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null and CovidVaccinations.new_vaccinations is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from popVSvac


-- USE Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccination numeric, RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(cast(CovidVaccinations.new_vaccinations as int))over(partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths
join portfolioproject..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null and CovidVaccinations.new_vaccinations is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations
USE portfolioproject
GO
Create view PercentPopulationVaccinated as 
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(cast(CovidVaccinations.new_vaccinations as int))over(partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
from portfolioproject..CovidDeaths
join portfolioproject..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null --and CovidVaccinations.new_vaccinations is not null
