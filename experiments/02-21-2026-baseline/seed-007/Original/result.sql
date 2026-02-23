WITH medals_ordered AS (
    SELECT 
        t.tournament_id,
        f.format_id,
        m.type as medal_type,
        m.year,
        LAG(m.type) OVER (PARTITION BY t.tournament_id, f.format_id ORDER BY m.year) as prev_medal_type
    FROM athlete a
    JOIN tournament t ON a.athlete_id = t.athlete_id
    JOIN format f ON t.tournament_id = f.tournament_id
    JOIN medal m ON f.format_id = m.format_id
    WHERE a.name = 'Nicol David'
)
SELECT COUNT(*) as count
FROM medals_ordered
WHERE prev_medal_type = 'MedalGold' 
    AND medal_type != 'MedalGold';
