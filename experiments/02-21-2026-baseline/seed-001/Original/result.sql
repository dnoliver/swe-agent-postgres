SELECT DISTINCT m.year
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Charlotte Fry'
AND t.name = 'World Championships for Young Dressage Horses'
ORDER BY m.year;
