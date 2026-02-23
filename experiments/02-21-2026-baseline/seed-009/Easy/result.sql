SELECT 
    SUM(CASE WHEN m.type = 'MedalBronze' THEN 1 ELSE 0 END) > SUM(CASE WHEN m.type = 'MedalGold' THEN 1 ELSE 0 END) AS has_more_bronze_than_gold
FROM medal m
JOIN format f ON m.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
JOIN athlete a ON t.athlete_id = a.athlete_id
WHERE a.name = 'Dai Xiaoxiang' AND f.name = 'Team';
