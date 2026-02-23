SELECT 
  SUM(CASE WHEN m.type = 'MedalBronze' THEN 1 ELSE 0 END) as bronze_count,
  SUM(CASE WHEN m.type = 'MedalGold' THEN 1 ELSE 0 END) as gold_count
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Ranomi Kromowidjojo';
