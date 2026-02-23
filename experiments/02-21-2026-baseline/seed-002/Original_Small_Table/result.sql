SELECT 
  COUNT(DISTINCT f.format_id) as appearances,
  COUNT(DISTINCT m.medal_id) as wins
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
LEFT JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Ferdinand Omanyala'
  AND t.name = 'African Championships';
