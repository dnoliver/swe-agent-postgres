SELECT m.year
FROM tournament t 
JOIN format f ON t.tournament_id = f.tournament_id 
JOIN medal m ON f.format_id = m.format_id 
WHERE t.athlete_id = (SELECT athlete_id FROM athlete WHERE name = 'Letsile Tebogo')
GROUP BY m.year
HAVING COUNT(*) = (
    SELECT MAX(medal_count)
    FROM (
        SELECT COUNT(*) as medal_count
        FROM tournament t2
        JOIN format f2 ON t2.tournament_id = f2.tournament_id
        JOIN medal m2 ON f2.format_id = m2.format_id
        WHERE t2.athlete_id = (SELECT athlete_id FROM athlete WHERE name = 'Letsile Tebogo')
        GROUP BY m2.year
    ) AS year_counts
)
ORDER BY m.year;
