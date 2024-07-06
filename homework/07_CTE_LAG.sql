-- написать запрос суммы очков с группировкой и сортировкой по годам

select year_game, sum(points) sum_points 
from statistic
group by year_game
order by year_game;

-- написать cte показывающее тоже самое

with years_points as (
	select year_game, sum(points) sum_points 
	from statistic
	group by year_game
)
select * from years_points order by year_game;

-- используя функцию LAG вывести кол-во очков по всем игрокам за текущий код и за предыдущий.

select lag(year_game) over (order by year_game) as lag_year,
lag(sum_points) over (order by year_game) as lag_sum_points,
year_game as current_year,
sum_points as current_sum_points
from (select year_game, sum(points) sum_points 
	from statistic
	group by year_game
	order by year_game);