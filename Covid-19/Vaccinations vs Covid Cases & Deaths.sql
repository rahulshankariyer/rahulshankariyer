select * from ProjectPortfolio..[Covid Vaccinations] order by 3,4;

--Vaccinations against Covid Cases and Deaths by date

select d.date,sum(cast(d.new_cases as float)) as total_cases,
sum(cast(d.new_deaths as float)) as total_deaths,
sum(cast(v.new_vaccinations as float)) as total_vaccinations
from ProjectPortfolio..[Covid Deaths] d join ProjectPortfolio..[Covid Vaccinations] v
on d.location = v.location and d.date = v.date
where d.continent is not null
group by d.date
order by d.date;

