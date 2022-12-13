--Write a SQL query to list the titles of all movies in which both Johnny Depp and Helena Bonham Carter starred.

SELECT movies.title
FROM stars
JOIN movies ON stars.movie_id = movies.id
JOIN people ON stars.person_id = people.id
WHERE people.name IN ("Johnny Depp", "Helena Bonham Carter")
GROUP BY movies.title
HAVING COUNT(movies.title) = 2;