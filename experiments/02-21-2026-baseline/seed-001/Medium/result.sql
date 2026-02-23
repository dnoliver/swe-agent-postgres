SELECT m.location, COUNT(*) as medal_count
FROM medal m
JOIN format f ON m.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
JOIN athlete a ON t.athlete_id = a.athlete_id
WHERE a.name = 'Dechapol Puavaranukroh'
GROUP BY m.location
ORDER BY medal_count DESC
LIMIT 1;
