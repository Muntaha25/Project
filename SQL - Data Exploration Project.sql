select *
from dbo.coviddeaths$
order by 3,4

select *
from dbo.covidvaccine$
order by 3,4

select location, date, total_cases, new_cases, total_deaths,population
from dbo.coviddeaths$
order by 1,2


-- total cases vs. total deaths

select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from dbo.coviddeaths$
where location like '%pakistan%' 
order by 1,2

-- countries with higher infection rate

select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as HighestInfectedPopulation
from dbo.coviddeaths$
group by location, population


order by HighestInfectedPopulation desc



--highest death count By exch Continent

select  continent, Max(cast(total_deaths as int)) as HighestDeathPercentage
from dbo.coviddeaths$
where continent is not null 
group by continent
order by HighestDeathPercentage desc


-- global Numbers

select Sum(total_cases) as sumoftotalcases, sum(cast(total_deaths as float)) as sumoftotaldeaths, sum(cast(total_deaths as float))/sum(total_cases)*100 as CasesPercentage
from dbo.coviddeaths$
----where location like '%pakistan%' 
where continent is not null
--group by location, date
order by 1,2


-- Join both the tables by means of specific coluumns to reduce the query execution time


select dea.location, dea.hosp_patients, vac.people_vaccinated
from dbo.coviddeaths$ dea
join dbo.covidvaccine$ vac   
on dea.location = vac.location 
order by 1,2	 

-- with CTE

with CTE_Vaccine ( location, continent, date, hosp_patients, people_vaccinated, rollingvaccinatedindex) 
as 
(select dea.location, dea.continent, dea.date, dea.hosp_patients,vac.people_vaccinated, sum(convert(float, vac.people_vaccinated)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinatedindex
from dbo.coviddeaths$ dea
join dbo.covidvaccine$ vac   
on dea.location = vac.location 
where dea.continent is not null
and vac.people_vaccinated is not null)
select * 
from  CTE_Vaccine
  