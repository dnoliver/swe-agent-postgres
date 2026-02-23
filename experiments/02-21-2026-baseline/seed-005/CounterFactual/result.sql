WITH gold_medal_counts AS (
  SELECT t.name, COUNT(*) AS gold_medal_count
  FROM athlete a
  JOIN tournament t ON a.athlete_id = t.athlete_id
  JOIN format f ON t.tournament_id = f.tournament_id
  JOIN medal m ON f.format_id = m.format_id
  WHERE a.name = 'Nicole Uphoff' 
    AND m.type = 'MedalGold'
  GROUP BY t.name
)
SELECT name
FROM gold_medal_counts
WHERE gold_medal_count = (SELECT MAX(gold_medal_count) FROM gold_medal_counts);
