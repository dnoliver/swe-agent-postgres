WITH medal_ranks AS (
  SELECT 
    m.medal_id,
    m.format_id,
    m.type,
    m.year,
    f.name as format_name,
    t.tournament_id,
    t.name as tournament_name,
    CASE 
      WHEN m.type = 'MedalGold' THEN 1
      WHEN m.type = 'MedalSilver' THEN 2
      WHEN m.type = 'MedalBronze' THEN 3
    END as medal_rank
  FROM medal m
  JOIN format f ON m.format_id = f.format_id
  JOIN tournament t ON f.tournament_id = t.tournament_id
  JOIN athlete a ON t.athlete_id = a.athlete_id
  WHERE a.name = 'Dimitrij Ovtcharov'
),
improvements AS (
  SELECT DISTINCT
    mr1.format_id,
    mr1.tournament_id,
    mr1.tournament_name,
    mr1.format_name
  FROM medal_ranks mr1
  JOIN medal_ranks mr2 ON mr1.format_id = mr2.format_id
  WHERE mr1.year < mr2.year
    AND mr1.medal_rank > mr2.medal_rank
)
SELECT COUNT(*) as improvement_count
FROM improvements;
