WITH medal_values AS (
    SELECT 
        medal_id,
        format_id,
        type,
        year,
        location,
        CASE 
            WHEN type = 'MedalBronze' THEN 1
            WHEN type = 'MedalSilver' THEN 2
            WHEN type = 'MedalGold' THEN 3
        END as medal_rank
    FROM medal
)
SELECT COUNT(DISTINCT m1.format_id) as count_of_improved_events
FROM medal_values m1
JOIN medal_values m2 ON m1.format_id = m2.format_id 
    AND m1.year < m2.year
    AND m1.medal_rank < m2.medal_rank
JOIN format f ON m1.format_id = f.format_id
JOIN tournament t ON f.tournament_id = t.tournament_id
WHERE t.athlete_id = 1;
