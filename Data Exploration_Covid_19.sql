Select*
From PortfolioProject..CovidVaccinations
Where continent is not null 
order by 3,4

--Select*
--From PortfolioProject..CovidDeaths
--Where continent is not null 
--order by 3,4

--Selecting data we are using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1, 2


--Total Cases vs Total Deaths
--Shows the likelihood of you dying if you contract covid in your country 

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location like '%New Zealand%' and continent is not null 
order by 1,2 

--Total cases vs Population
--Shows what percentage of Population has contracted Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as TotalCasesPerPopulation 
From PortfolioProject..CovidDeaths 
Where location like '%New Zealand%' and continent is not null 
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentofPopulationInfected 
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location, Population  
order by PercentofPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(Cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Based on Continent 

Select Location, MAX(Cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
Group by Location
order by TotalDeathCount desc

--Global Numbers 

Select date, SUM(new_cases) as Total_Cases, SUM(cast (new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by date
order by 1,2 

--Total Global Cases 

Select SUM(new_cases) as Total_Cases, SUM(cast (new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
--Group by date
order by 1,2 

--Looking at Covid Vaccation Table

Select*
From PortfolioProject..CovidVaccinations

--Jointing the two tables togeather 

Select*
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
     On Dea.location = Vac.location 
	 and Dea.date = Vac.date 


-- Looking at Total Population vs Vaccinations 

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) 
OVER (Partition by Dea.location Order by Dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
     On Dea.location = Vac.location 
	 and Dea.date = Vac.date 
Where dea.continent is not null 
Order by 2, 3 

--Choices CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, 
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
     On Dea.location = Vac.location 
	 and Dea.date = Vac.date 
Where dea.continent is not null )

Select * , (RollingPeopleVaccinated/ population)*100
From PopvsVac

--Temp Table 

DROP Table if exists #PercentPopulationVaccintated
Create Table #PercentPopulationVaccintated 
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccintated 
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, 
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
     On Dea.location = Vac.location 
	 and Dea.date = Vac.date 
--Where dea.continent is not null 

Select * , (RollingPeopleVaccinated/ population)*100
From #PercentPopulationVaccintated 

--Creating View to store data for later visualizations

Create View PercentPopulationVaccintate as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, 
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/ population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
     On Dea.location = Vac.location 
	 and Dea.date = Vac.date 
Where dea.continent is not null 

--Selecting information from new view  
Select*
From PercentPopulationVaccintate
