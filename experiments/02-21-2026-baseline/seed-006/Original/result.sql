SELECT COUNT(*) 
FROM medal m
JOIN format f ON m.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
JOIN athlete a ON t.athlete_id = a.athlete_id
WHERE a.name = 'Kemar Bailey-Cole'
  AND t.name = 'Commonwealth Games'
  AND m.year < 2012;
