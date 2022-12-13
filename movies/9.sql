--Write a SQL query to list the names of all people who starred in a movie released in 2004, ordered by birth year.

SELECT DISTINCT people.name
FROM stars
JOIN movies ON stars.movie_id = movies.id
JOIN people on stars.person_id = people.id
WHERE movies.year = 2004
ORDER BY people.birth;