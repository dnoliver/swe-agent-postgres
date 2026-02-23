SELECT COUNT(DISTINCT (m1.medal_id, m2.medal_id))
FROM tournament t1
JOIN format f1 ON t1.tournament_id = f1.tournament_id
JOIN medal m1 ON f1.format_id = m1.format_id
JOIN tournament t2 ON t2.athlete_id = t1.athlete_id
JOIN format f2 ON t2.tournament_id = f2.tournament_id
JOIN medal m2 ON f2.format_id = m2.format_id
WHERE t1.athlete_id = 1 
  AND m1.type = 'MedalGold'
  AND m2.type != 'MedalGold'
  AND f1.name = f2.name
  AND m1.year < m2.year;
