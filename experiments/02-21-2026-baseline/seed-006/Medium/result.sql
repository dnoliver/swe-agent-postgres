SELECT 
    m.year, 
    COUNT(*) as medal_count
FROM medal m
JOIN format f ON m.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
JOIN athlete a ON t.athlete_id = a.athlete_id
WHERE a.name = 'Li Bingjie'
GROUP BY m.year
HAVING COUNT(*) = (
    SELECT MAX(medal_count)
    FROM (
        SELECT COUNT(*) as medal_count
        FROM medal m2
        JOIN format f2 ON m2.format_id = f2.format_id
        JOIN tournament t2 ON f2.tournament_id = t2.tournament_id
        JOIN athlete a2 ON t2.athlete_id = a2.athlete_id
        WHERE a2.name = 'Li Bingjie'
        GROUP BY m2.year
    ) subquery
)
ORDER BY m.year;
