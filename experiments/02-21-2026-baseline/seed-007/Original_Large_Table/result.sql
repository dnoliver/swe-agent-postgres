SELECT m.type
FROM medal m
JOIN format f ON m.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
JOIN athlete a ON t.athlete_id = a.athlete_id
WHERE a.name = 'Cate Campbell'
GROUP BY m.type
ORDER BY COUNT(*) DESC
LIMIT 1;
