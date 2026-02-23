SELECT 
    COUNT(*) FILTER (WHERE m.type = 'MedalGold') > COUNT(*) FILTER (WHERE m.type = 'MedalSilver') as has_more_gold_than_silver
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Charlotte Fry' 
  AND f.name = 'Individual special dressage';
