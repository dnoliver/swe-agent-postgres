SELECT m.location
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Emma McKeon'
  AND t.name = 'Olympic Games'
  AND m.type = 'MedalBronze'
ORDER BY m.year, m.medal_id
LIMIT 1;
