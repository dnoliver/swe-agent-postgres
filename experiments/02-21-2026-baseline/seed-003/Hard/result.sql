SELECT m.location
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Pitha Haningtyas Mentari'
ORDER BY m.year ASC, m.medal_id ASC
LIMIT 1;
