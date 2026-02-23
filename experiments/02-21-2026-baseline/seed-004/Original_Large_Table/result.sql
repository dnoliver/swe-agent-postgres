SELECT COUNT(*)
FROM medal m
JOIN format f ON m.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
JOIN athlete a ON t.athlete_id = a.athlete_id
JOIN personalinformation pi ON a.athlete_id = pi.athlete_id
WHERE a.name = 'Timo Boll'
AND m.year >= pi.birth_year + 30
AND m.year <= pi.birth_year + 39;
