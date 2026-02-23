SELECT 
  SUM(CASE WHEN m.type = 'MedalBronze' THEN 1 ELSE 0 END) > SUM(CASE WHEN m.type = 'MedalGold' THEN 1 ELSE 0 END) AS has_more_bronze_than_gold
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Trenton Julian' AND f.name = '4x100 m medley';
