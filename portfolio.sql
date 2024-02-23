--looking at total cases vs total death
--shows likihood of dying if you contract covid in US 
select location, date, total_cases total_deaths,
(total_deaths/total_cases)*100 AS DeathPerCase from coviddeaths 
where location like '%states%'
AND total_cases IS NOT NULL
AND total_deaths IS NOT NULL 
order by 1,2

--looking at total cases vs population 
select total_cases, population, location, date,
(total_cases/population)*100 AS [Cases Per Population]
FROM coviddeaths
where location like '%states%' 
AND total_cases IS NOT NULL
order by 3, 5

--looking at countries with highest infection rate compared to population 
select location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/Population))*100 as PercentPopulationInfected
from coviddeaths 
group by location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population 
select location, population, MAX(total_deaths) as TotalDeathCount,
MAX(total_deaths/population)*100 as PercentDeathsInPopulation
from coviddeaths
group by location, population

--breaking it down by continent 
select continent, MAX(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

--showing continents with highest death count per population 
select continent, population,
max(total_deaths) as TotalDeathCount,
max(total_deaths/population) as PercentDeathCount 
from coviddeaths
where continent is not null
group by continent, population
order by 1,4

--global numbers 
select date, sum(new_cases) as total_cases, 
sum(new_deaths) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeaths 
where continent is not null
AND new_deaths is not null
and new_cases is not null 
group by date
order by 1,2

--temp table
drop table if exists #percentpopulationvaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(100), 
Location nvarchar(100),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


INSERT INTO #PercentPopulationVaccinated
SELECT
CD.continent,
CD.location,
CD.date,
CD.population,
CV.new_vaccinations,
SUM(CONVERT(BIGINT, CV.new_vaccinations)) OVER (ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM
coviddeaths CD
JOIN
covidvaccinations CV ON CD.location = CV.location AND CD.date = CV.date
WHERE
CD.continent IS NOT NULL;


select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations 
CREATE VIEW PercentPopulationVaccinated AS
SELECT
    CD.continent,
    CD.location,
    CD.date,
    CD.population,
    CV.new_vaccinations,
    SUM(CONVERT(BIGINT, CV.new_vaccinations)) OVER (ORDER BY CD.location, CD.date) AS RollingPeopleVaccinated
FROM
    coviddeaths CD
JOIN
    covidvaccinations CV ON CD.location = CV.location AND CD.date = CV.date
WHERE
    CD.continent IS NOT NULL;





--looking at total population vs vaccination 
With PopVsVac (continent, locaiton, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, sum(convert(bigint,CV.new_vaccinations)) over (partition by CD.location order by CD.location,
CD.date) as RollingPeopleVaccinated
from coviddeaths CD 
join covidvaccinations CV on CD.location = CV.location 
and CD.date = CV.date 
where CD.continent is not null)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

