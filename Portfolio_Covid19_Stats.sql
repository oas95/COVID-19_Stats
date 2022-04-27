Select *
From PortfolioProjects..CovidDeaths_v1$
Order By 3,4

Select *
From PortfolioProjects..CovidVaccinations_v1$
Order By 3,4

--Select Data used

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProjects..CovidDeaths_v1$
Where location like '%states%'
Order By 1,2

--Looking at Total Cases vs Total Deaths
-- Percentage rate of Death in US

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProjects..CovidDeaths_v1$
Where location like '%states%'
Order By 1,2

-- Total Cases vs Population
-- Population % w/ C19

Select Location, date, total_cases, Population, (total_cases/population)*100 as CovidCases_Percentage
From PortfolioProjects..CovidDeaths_v1$
Where location like '%states%'
Order By 1,2

--Infection Rates Amoung Countries

Select Location, population, MAX(total_cases) as Infection_Rate, MAX((total_cases/population))*100 as InfectionRate_Percentage
From PortfolioProjects..CovidDeaths_v1$
Group By location, population
Order By InfectionRate_Percentage desc


-- By Continent 
Select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProjects..CovidDeaths_v1$
Where continent is not null
Group By continent
Order By TotalDeathCount desc


-- Continents w/ Highest Death Count
Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProjects..CovidDeaths_v1$
Where continent is null
Group By location
Order By TotalDeathCount desc


--Country Death Count
Select Location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProjects..CovidDeaths_v1$
Where continent is not null
Group By location
Order By TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as Total_Cases, Sum(cast(new_deaths as bigint)) as Total_Deaths, Sum(cast(new_deaths as bigint))/Sum(new_cases)*100 as Death_Percentage
From PortfolioProjects..CovidDeaths_v1$
Where continent is not null
-- Group by Date
Order by 1,2



-- Covid Vaccinations
Select *
From PortfolioProjects..CovidVaccinations_v1$



--Joining Covid Deaths and Covid Vacs by date and location
Select *
From PortfolioProjects..CovidDeaths_v1$ dea
Join PortfolioProjects..CovidVaccinations_v1$ vac
	On dea.location = vac.location
	and dea.date = vac.date


--Total Population vs Vaccinations

With populationVSvaccination (Continent, Location, Date, Population, New_Vaccinations, Vaccination_Rollover)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert( bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Vaccination_Rollover
From PortfolioProjects..CovidDeaths_v1$ dea
Join PortfolioProjects..CovidVaccinations_v1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select*, (Vaccination_Rollover/Population)*100
From populationVSvaccination 


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacinations numeric,
Vaccination_Rollover numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Vaccination_Rollover
From PortfolioProjects..CovidDeaths_v1$ dea
Join PortfolioProjects..CovidVaccinations_v1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select*, (Vaccination_Rollover/Population)*100 as Percent_Vaccinated
From #PercentPopulationVaccinated 


-- View Creation for Visualizations

Create View PercentPopulationVaccinated_v2
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Vaccination_Rollover
From PortfolioProjects..CovidDeaths_v1$ dea
Join PortfolioProjects..CovidVaccinations_v1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null