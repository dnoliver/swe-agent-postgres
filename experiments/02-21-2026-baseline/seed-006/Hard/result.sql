WITH medal_values AS (
  SELECT 
    'MedalGold' as type, 
    3 as value
  UNION ALL
  SELECT 
    'MedalSilver' as type, 
    2 as value
  UNION ALL
  SELECT 
    'MedalBronze' as type, 
    1 as value
),
emily_medals AS (
  SELECT 
    f.format_id,
    f.name as event_name,
    f.tournament_id,
    t.name as tournament_name,
    m.type as medal_type,
    m.year,
    m.location,
    mv.value as medal_value
  FROM tournament t
  JOIN format f ON t.tournament_id = f.tournament_id
  JOIN medal m ON f.format_id = m.format_id
  JOIN medal_values mv ON m.type = mv.type
  WHERE t.athlete_id = 1
)
SELECT COUNT(DISTINCT e1.format_id) as count
FROM emily_medals e1
JOIN emily_medals e2 
  ON e1.format_id = e2.format_id 
  AND e1.year < e2.year
  AND e1.medal_value < e2.medal_value;
