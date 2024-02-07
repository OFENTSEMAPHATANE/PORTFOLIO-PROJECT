Select *
from PortfolioProject..CovidDeaths$
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--This illustrates the chances of dying if you get infected by covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeaths
from PortfolioProject..CovidDeaths$
where location like 'South Africa'
order by 1,2


--Focusing on the Total Cases vs Population
--Indicates the percentage of the population that contracted covid

Select Location, Date, Population, Total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths$
where location like 'South Africa'
order by 1,2


--The Country with the highest infection rate 

Select Location, Population, MAX(Total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like 'South Africa'
GROUP BY Location, Population 
order by PercentageOfPopulationInfected desc

--Illustrating countries with the Highest Death Count 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like 'South Africa'
where continent is not null 
GROUP BY Location 
order by TotalDeathCount desc

--Breaking Stuff Down By Continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like 'South Africa'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like 'South Africa'
where continent is not null 
--Group By date
order by 1,2
 
--TOTAL POPULATION VS VACCINATIONS 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE 



DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated