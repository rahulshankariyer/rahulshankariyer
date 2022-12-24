select * from ProjectPortfolio..[Covid Deaths] order by 3,4;
select * from ProjectPortfolio..[Covid Vaccinations] order by 3,4;

--Cleaning

update ProjectPortfolio..[Covid Deaths]
set total_cases = '0'
where total_cases is null;

update ProjectPortfolio..[Covid Deaths]
set new_cases = '0'
where new_cases is null;

update ProjectPortfolio..[Covid Deaths]
set total_deaths = '0'
where total_deaths is null;

update ProjectPortfolio..[Covid Deaths]
set new_deaths = '0'
where new_deaths is null;

update ProjectPortfolio..[Covid Vaccinations]
set total_tests = '0'
where total_tests is null;

update ProjectPortfolio..[Covid Vaccinations]
set new_tests = '0'
where new_tests is null;

update ProjectPortfolio..[Covid Vaccinations]
set total_tests_per_thousand = '0'
where total_tests_per_thousand is null;

update ProjectPortfolio..[Covid Vaccinations]
set new_tests_per_thousand = '0'
where new_tests_per_thousand is null;

update ProjectPortfolio..[Covid Vaccinations]
set positive_rate = '0'
where positive_rate is null;

update ProjectPortfolio..[Covid Vaccinations]
set tests_per_case = '0'
where tests_per_case is null;

--Global Covid Tests, Cases & Deaths

with Tests_Cases_Deaths (new_tests,new_cases,new_deaths)
as
(
select v.new_tests,d.new_cases,d.new_deaths
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.continent is not null and d.new_cases is not null and v.new_tests is not null
)
select sum(cast(new_tests as float)) as global_tests,
sum(cast(new_cases as float)) as global_cases,
sum(cast(new_deaths as float)) as global_deaths,
(sum(cast(new_tests as float))/sum(cast(new_cases as float)))*100 as tests_per_case,
(sum(cast(new_cases as float))/sum(cast(new_deaths as float)))*100 as cases_per_death
from Tests_Cases_Deaths;

--Global Population

with PopulationvsTests (country,population)
as
(
select location,avg(population) as population
from ProjectPortfolio..[Covid Deaths]
where continent is not null
group by location
)
select sum(population) as global_population
from PopulationvsTests;

--Tests per Case in Each Country

select d.location,
max(d.total_cases) as total_cases,
max(cast(v.total_tests as float)) as total_tests,
case 
when max(d.total_cases) = 0 then 0
else (max(cast(v.total_tests as float))/max(d.total_cases))
end
as tests_per_case
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.continent is not null
group by d.location
order by d.location;

--Tests per Case in USA

select d.location,
sum(d.new_cases) as new_cases,
sum(cast(v.new_tests as float)) as new_tests,
case 
when sum(d.new_cases) = 0 then 0
else (sum(cast(v.new_tests as float))/sum(d.new_cases))
end
as tests_per_case
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.location = 'United States'
group by d.location;

--Tests per Case in the Rest of the World

select sum(d.new_cases) as new_cases,
sum(cast(v.new_tests as float)) as new_tests,
case 
when sum(d.new_cases) = 0 then 0
else (sum(cast(v.new_tests as float))/sum(d.new_cases))
end
as tests_per_case
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.location != 'United States' and d.continent is not null;

--Tests per Case of the Rest of the World Each Day

select d.date,sum(d.total_cases) as total_cases,sum(cast(v.total_tests as float)) as total_tests,
case
when sum(d.total_cases) = 0 then 0
else (sum(cast(v.total_tests as float))/sum(d.total_cases))
end
as tests_per_case
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.location != 'United States' and d.continent is not null
group by d.date
order by d.date;

--Tests per Case of the USA Each Day

select d.location,d.date,d.total_cases,v.total_tests,
case
when d.total_cases = 0 then 0
else (cast(v.total_tests as float)/d.total_cases)
end
as tests_per_case
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.location = 'United States'
order by d.location,d.date;

--Tests % in USA

select d.location,d.population,
sum(cast(v.new_tests as float)) as new_tests,
case 
when d.population = 0 then 0
else (sum(cast(v.new_tests as float))/d.population)*100
end
as tests_percentage
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.location = 'United States'
group by d.location,d.population;

--Tests % in the Rest of the World

with RestOfWorld (country,population,total_tests,tests_percentage)
as
(
select d.location,max(d.population) as population,
max(cast(v.total_tests as float)) as total_tests,
case 
when max(d.population) = 0 then 0
else (max(cast(v.total_tests as float))/max(d.population))*100
end
as tests_percentage
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.location != 'United States' and d.continent is not null
group by d.location
)
select sum(population) as population, sum(total_tests) as total_tests,
(sum(total_tests)/sum(population))*100 as tests_percentage
from RestOfWorld;

--Percentage of covid cases among the population in each country overall

select location as country,population,
max(cast(total_cases as int)) as total_cases,max((total_cases/population))*100 as covid_case_percentage 
from ProjectPortfolio..[Covid Deaths] 
where continent is not null 
group by location,population 
order by covid_case_percentage desc;

--Percentage of Covid Cases in USA

select location as country,population,
max(cast(total_cases as int)) as total_cases,max((total_cases/population))*100 as covid_case_percentage 
from ProjectPortfolio..[Covid Deaths] 
where location = 'United States'
group by location,population;

--Percentage of Covid Cases in Rest of the World

with RestofWorld (country,population,total_cases,covid_case_percentage)
as
(
select location as country,population,
max(cast(total_cases as float)) as total_cases,max((total_cases/population))*100 as covid_case_percentage 
from ProjectPortfolio..[Covid Deaths] 
where location != 'United States' and continent is not null
group by location,population
)
select sum(population) as population,sum(total_cases) as total_cases,
(sum(total_cases)/sum(population))*100 as covid_case_percentage
from RestofWorld;

--% of covid cases among the population of the world each day in descending order

with Covid (location,population,date,cases,case_percentage)
as
(
select location,population,date,max(cast(total_cases as int)) as highest_infection_count,max((total_cases/population))*100 as covid_case_percentage 
from ProjectPortfolio..[Covid Deaths] 
where continent is not null and location != 'United States'
group by location,population,date
--order by covid_case_percentage desc
)
select sum(population) as global_population,date,sum(cases) as global_cases,(sum(cases)/sum(population))*100 as global_percentage
from Covid
group by date
order by date;

--% of covid cases among the US population each day in descending order

select location,population,date,total_cases,(total_cases/population)*100 as covid_case_percentage 
from ProjectPortfolio..[Covid Deaths] 
where continent is not null and location = 'United States'
order by date;

--Total death % of each country

select location as country,
max(total_cases) as total_covid_cases,
max(total_deaths) as total_death_count,
(max(total_deaths)/max(total_cases))*100 as death_percentage
from ProjectPortfolio..[Covid Deaths] 
where continent is not null 
group by location
order by total_death_count desc;

--Total death % of USA

select location as country,
max(total_cases) as total_covid_cases,
max(total_deaths) as total_death_count,
(max(total_deaths)/max(total_cases))*100 as death_percentage
from ProjectPortfolio..[Covid Deaths] 
where location = 'United States'
group by location;

--Total death % of Rest of the World

with RestofWorld (country,total_covid_cases,total_death_count,death_percentage)
as
(
select location as country,
max(total_cases) as total_covid_cases,
max(cast(total_deaths as float)) as total_death_count,
case
when max(total_cases) = 0 then 0
else (max(cast(total_deaths as float))/max(total_cases))*100 
end
as death_percentage
from ProjectPortfolio..[Covid Deaths] 
where location != 'United States' and continent is not null
group by location
)
select sum(total_death_count),sum(total_covid_cases),
(sum(total_death_count)/sum(total_covid_cases))*100 as death_percentage
from RestofWorld;

--Total covid cases, deaths and death % across the world each day

select date,sum(new_cases) as total_new_cases,
sum(cast(new_deaths as int)) as total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from ProjectPortfolio..[Covid Deaths] 
where continent is not null and location != 'United States'
group by date
order by date;

--Death % among covid cases each day - USA

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage 
from ProjectPortfolio..[Covid Deaths] 
where location = 'United States'
order by date;