Select location, date, total_cases, new_cases, total_deaths, population
from CovidDataExploration..CovidDeaths
order by 1,2;

--Looking at Total Cases vs Total Deaths
-- Displays the probability of dying from covid in a particular country: 
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from CovidDataExploration..CovidDeaths
--where location= 'India'
--order by 1,2;

--Looking at Total Cases vs Population
--Shows what portion of the population of a country have contracted covid:
--Select location, date, total_cases, population, (total_cases/population)*100 as PercentageOfCasesPerCountry 
--from CovidDataExploration..CovidDeaths
--order by 1,2;

--Looking at Countries with Highest Infection Rates compared to their Populations

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageOfPopulationInfected
from CovidDataExploration..CovidDeaths
group by location,population
order by PercentageOfPopulationInfected desc;


--Showing Countries with Highest Death Count per population
Select location, population,max(cast(total_deaths as int)) as TotalDeathCount, (max(cast(total_deaths as int))/population)*100 as DeathPercentage
from CovidDataExploration..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc;

--According to Continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDataExploration..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


--Showing the continents with the highest death count
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDataExploration..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

--Global Numbers
Select sum(new_cases) as TotalGlobalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDataExploration..CovidDeaths
where continent is not null
--group by date
order by 1,2;



--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated,
from CovidDataExploration..CovidDeaths dea
join CovidDataExploration..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from CovidDataExploration..CovidDeaths dea
join CovidDataExploration..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
from PopvsVac
order by 2,3;


--Temp Table

Drop Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from CovidDataExploration..CovidDeaths dea
join CovidDataExploration..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select *
from #PercentPeopleVaccinated


--Creating view to store data for later visualizations

Create view PercentPeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from CovidDataExploration..CovidDeaths dea
join CovidDataExploration..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3;

Select * 
from PercentPeopleVaccinated;