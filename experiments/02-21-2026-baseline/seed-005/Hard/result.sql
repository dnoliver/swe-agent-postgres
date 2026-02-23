SELECT COUNT(*) 
FROM medal m
JOIN format f ON m.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
JOIN athlete a ON t.athlete_id = a.athlete_id
JOIN personalinformation p ON a.athlete_id = p.athlete_id
WHERE a.name = 'Cate Campbell'
  AND m.year >= (p.birth_year + 20)
  AND m.year <= (p.birth_year + 24);
