WITH medal_sequence AS (
  SELECT 
    t.name as tournament,
    f.name as event,
    m.year,
    m.type,
    CASE 
      WHEN m.type = 'MedalGold' THEN 1
      WHEN m.type = 'MedalSilver' THEN 2
      WHEN m.type = 'MedalBronze' THEN 3
    END as medal_rank,
    LAG(CASE 
      WHEN m.type = 'MedalGold' THEN 1
      WHEN m.type = 'MedalSilver' THEN 2
      WHEN m.type = 'MedalBronze' THEN 3
    END) OVER (PARTITION BY t.name, f.name ORDER BY m.year) as prev_medal_rank,
    LAG(CASE 
      WHEN m.type = 'MedalGold' THEN 1
      WHEN m.type = 'MedalSilver' THEN 2
      WHEN m.type = 'MedalBronze' THEN 3
    END, 2) OVER (PARTITION BY t.name, f.name ORDER BY m.year) as prev_prev_medal_rank
  FROM athlete a
  JOIN tournament t ON a.athlete_id = t.athlete_id
  JOIN format f ON t.tournament_id = f.tournament_id
  JOIN medal m ON f.format_id = m.format_id
  WHERE a.athlete_id = 1
)
SELECT COUNT(*)
FROM medal_sequence
WHERE medal_rank = 1
  AND prev_medal_rank > 1
  AND prev_prev_medal_rank = 1;
