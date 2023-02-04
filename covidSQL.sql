
select count(*)
from PortFolioProject..CovidDeaths$

select location,date,total_cases,total_deaths,population
from PortFolioProject..CovidDeaths$
where continent is not null
order by 3,4

--total case vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases) *100 as deathpercentage,
round((total_deaths/total_cases)*100,3) as roundpercent
from PortFolioProject..CovidDeaths$
where location like 'I____'
order by 1,2

----total case vs population
select location,date,total_cases,total_deaths,(total_cases/population) *100 as percentpopulationInfected
from PortFolioProject..CovidDeaths$
order by 1,2


--countries with highest infection compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected,
round(Max((total_cases/population))*100,3) as roundpercent
From PortFolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc;

--countries with highest death count vs population
select location ,max(cast(total_deaths as int)) as TotalCountDeath
from PortFolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalCountDeath desc

--countdeath in continent
select continent ,max(cast(total_deaths as int)) as TotalCountDeath
from PortFolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalCountDeath desc


 --continent with totaldeathcount
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortFolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage,
round(SUM(cast(new_deaths as int))/SUM(New_Cases)*100,4) as RoundPercent
From PortFolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2
 
 select dea.continent,dea.date,dea.location,vac.new_vaccinations 
 from PortFolioProject..CovidDeaths$ dea
 join PortFolioProject..CovidVaccinations$ vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.location like 'I___A'
 order by 1,2


--total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from PortFolioProject..CovidDeaths$ dea  
join PortFolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3 

--using CTE 

With popvsvac (Continent, Location,  Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from PortFolioProject..CovidDeaths$ dea  
join PortFolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)

select *,(RollingPeopleVaccinated/Population)*100 as percentage
from popvsvac


---temp table
drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
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

Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


