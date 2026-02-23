SELECT m.year 
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Kristian Karlsson'
  AND t.name = 'European Championships'
  AND f.name = 'Team'
  AND m.type = 'MedalBronze'
ORDER BY m.year
LIMIT 1;
