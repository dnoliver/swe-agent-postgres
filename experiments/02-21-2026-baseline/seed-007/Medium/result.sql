SELECT f.name
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Juan Matute Guimon'
GROUP BY f.name
HAVING COUNT(m.medal_id) = (
    SELECT MAX(medal_count)
    FROM (
        SELECT COUNT(m2.medal_id) as medal_count
        FROM athlete a2
        JOIN tournament t2 ON a2.athlete_id = t2.athlete_id
        JOIN format f2 ON t2.tournament_id = f2.tournament_id
        JOIN medal m2 ON f2.format_id = m2.format_id
        WHERE a2.name = 'Juan Matute Guimon'
        GROUP BY f2.name
    ) AS counts
);
