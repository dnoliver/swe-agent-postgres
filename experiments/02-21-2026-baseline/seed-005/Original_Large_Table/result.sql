SELECT COUNT(DISTINCT m1.format_id)
FROM medal m1
JOIN medal m2 ON m1.format_id = m2.format_id
JOIN format f ON m1.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
WHERE t.athlete_id = 1
  AND m1.type = 'MedalGold'
  AND m2.type != 'MedalGold'
  AND m1.year < m2.year;
