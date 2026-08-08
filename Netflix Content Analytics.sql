-- SQL Project: Netflix Content Analytics
create database netflix_db;
use netflix_db;

create table netflix_content (
	show_id int primary key,
    title varchar(255) ,
    content_type varchar(20),
    director varchar(255),
    country varchar(100),
    release_year int,
    date_added date,
    rating varchar(20),
    duration varchar(30),
    genre varchar(100)
);

insert into netflix_content
values	(1, 'Stranger Things', 'TV Show', 'The Duffer Brothers', 'USA', 2016, '2022-01-10', 'TV-14', '4 Seasons', 'Sci-Fi, Drama'),
		(2, 'Spider-Man: Homecoming', 'Movie', 'Jon Watts', 'USA', 2017, '2026-07-01', 'PG-13', '133 min', 'Sci-Fi, Action, Fantasy'),
        (3, 'When Life Gives You Tangerines', 'TV Show', 'Kim Won-seok', 'South Korea', 2025, '2025-03-07', 'TV-14', '1 Season', 'Romance, Drama'),
        (4, 'Extraction', 'Movie', 'Sam Hargrave', 'USA', 2020, '2022-03-01', 'R', '116 min', 'Action, Thriller'),
        (5, 'Shaitaan', 'Movie', 'Vikas Bahl', 'India', 2024, '2024-05-04', 'UA', '132 min', 'Horror, Thriller'),
        (6, 'Last Samurai Standing', 'TV Show', 'Michihito Fujii', 'Japan', 2025, '2025-11-13', 'TV-MA', '1 Season', 'Drama, Action, War'),
        (7, 'Interceptor', 'Movie', 'Matthew Reilly', 'Australia, USA', 2022, '2022-06-03', 'TV-MA', '98 min', 'Action, Thriller, Adventure');

-- Total titles
select count(show_id) as 'Total Titles' from netflix_content;

-- Movies vs TV Show
select content_type, count(*) as 'Count Total'
from netflix_content
group by content_type;

select * from netflix_content where content_type = "Movie";
select * from netflix_content where content_type = "TV Show";

-- Content added by year
select year(date_added) as 'Year', count(show_id) 'Count Content'
from netflix_content
group by year(date_added)
order by year(date_added);

-- Content added by month
select monthname(date_added) as 'Month Name', count(show_id) as 'Count Content'
from netflix_content
group by monthname(date_added)
order by monthname(date_added);

-- Content by country
select country, count(show_id) as 'Count Content'
from netflix_content
group by country
order by country;

-- Top producing countries
select count(show_id) as "Total Content", country
from netflix_content
group by country
order by count(show_id) desc
limit 1;

-- Genre distribution
with recursive genre_split as (
		select show_id,
			trim(substring_index(genre, ',', 1)) as `Genre Name`,
            substring(genre, length(substring_index(genre, ',', 1)) + 2) as remaining
		from netflix_content
        where genre is not null

		union all

		select show_id,
			trim(substring_index(remaining, ',', 1)),
            substring(remaining, length(substring_index(remaining, ',', 1)) + 2)
		from genre_split
        where remaining <> ''
)
select `Genre Name`, count(*) as `Total Content`
from genre_split
where `Genre Name` <> ''
group by `Genre Name`
order by count(*) desc;

-- Content by release year
select release_year as 'Release Year', title as 'Content Name'
from netflix_content
order by release_year desc;

-- Oldest and Newest Titles
select title, release_year, 'Newest' as type
from netflix_content
where release_year = (select max(release_year) from netflix_content)

union all

select title, release_year, 'Oldest' as type
from netflix_content
where release_year = (select min(release_year) from netflix_content);

-- Average movie duration
select avg(trim(substring_index(duration, ' ', 1))) as `Average Movie Duration in MINUTES` from netflix_content
where content_type = 'Movie';

-- Longest Movie
select title, duration from netflix_content
where content_type = 'Movie'
	and cast(trim(substring_index(duration, ' ', 1)) as unsigned)
    = (select max(cast(trim(substring_index(duration, ' ', 1)) as unsigned)) from netflix_content where content_type = 'Movie');

-- TV Shows by number of seasons
select title, duration from netflix_content
where content_type = 'TV Show'
order by cast(trim(substring_index(duration, ' ', 1)) as unsigned) desc;

-- Rating-wise distribution
select rating, count(show_id) as 'Count Content' 
from netflix_content
group by rating;

-- Percentage of Movies vs TV Shows
select content_type, ( (select count(show_id) from netflix_content where content_type = 'Movie') 
		/ (select count(show_id) from netflix_content) ) * 100 as `Percentage in Total Contents` from netflix_content where content_type = 'Movie' group by content_type
union all
select content_type, ( (select count(show_id) from netflix_content where content_type = 'TV Show') 
		/ (select count(show_id) from netflix_content) ) * 100 as `Percentage in Total Contents` from netflix_content where content_type = 'TV Show' group by content_type;
-- *** The same problem's solution in simple method
-- Percentage of Movies vs TV Shows
select content_type, count(show_id) as `Total Content`, count(show_id) / (select count(show_id) from netflix_content) * 100 as `Percentage in Total Contents`
from netflix_content
group by content_type;

-- Country-wise content contribution
with recursive country_split as (
		select show_id, trim(substring_index(country, ',', 1)) as `Country Name`,
        substring(country, length(substring_index(country, ',', 1)) + 2) as remaining
        from netflix_content where country is not null
        
        union all
        
        select show_id, trim(substring_index(remaining, ',', 1)),
        substring(remaining, length(substring_index(remaining, ',', 1)) +2)
        from country_split where remaining <> ''
)
select `Country Name`, count(*) as 'Total Content'
from country_split
where `Country Name` <> ''
group by `Country Name`;

-- Executive Content Dashboard
select count(show_id) as `Total Content`,
		sum(content_type = 'Movie') as `Total Movies`,
		sum(content_type = 'TV Show') as `Total TV Shows`,
		round(sum(content_type = 'Movie') / count(show_id) * 100, 2) as `Movie Percentage`,
		round(sum(content_type = 'TV Show') / count(show_id) * 100, 2) as `TV Show Percentage`,
		count(distinct country) as `Number of Production Countries`
from netflix_content;
