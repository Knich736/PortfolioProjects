--Looking at total cases vs total deaths

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--and continent is not null 
--order by 1,2

--Shows likelyhood of dying if you contract covid
Select location, date, total_cases, total_deaths, 
cast(total_deaths as bigint)/NULLIF(cast(total_cases as float),0)*100 AS deathPercentage
FROM PortfolioProject..CurCovidDeaths
WHERE location LIKE '%States%'
order by 1,2

----- Looking at Total case vs Population
----Shows what percentage of population of covid
--Select Location, date, total_cases,Population, (total_cases/Population)*100 as InfectionPercentage
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--and continent is not null 
--order by 1,2

----Lookning at countries with highest Infection rate compared to population
--Select Location, Population, Max(total_cases) AS HightestInfectionCount, MAX((total_cases/Population))*100 as InfectionPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
----and continent is not null 
--Group by Location, Population
--order by InfectionPercentage desc


-- Showing Countries with highets death cound per Population
Select Location, Population, MAX(CAST(total_deaths as int)) AS TotalDeathCount--, (total_deaths/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group by Location, Population
order by TotalDeathCount desc

--Lets break thigns down by continent
Select Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount--, (total_deaths/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null 
Group by Location
order by TotalDeathCount desc

Select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount--, (total_deaths/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null 
GROUP BY date
order by 1,2

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null 
--GROUP BY date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated,
 (RollingPeopleVaccinated/ population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null 
	order by 2,3

	-- USE CTE

	With PopvsVac (Continent, Location, Date, population, New_vaccinations, RollingPeopleVaccinated)
	AS 
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
		dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/ population) *100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null 
	--order by 2,3
	)
	Select *, (RollingPeopleVaccinated/ population) *100
	From PopvsVac

	-- Temp Table

	DROP TABLE if exists #PercentPopulationVaccinated
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
		SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
		dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/ population) *100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--WHERE dea.continent is not null 
	--order by 2,3

	Select *, (RollingPeopleVaccinated/ population) *100
	From #PercentPopulationVaccinated

	-- Creating view to store data for later visuzlizations 
	Create View PercentPopulationVaccinated as  
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
		dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/ population) *100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null 
	--order by 2,3
	

	Select *
	FROM PercentPopulationVaccinated
