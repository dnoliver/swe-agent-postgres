WITH medals_ordered AS (
    SELECT 
        t.name AS tournament_name,
        f.name AS format_name,
        m.year,
        m.type AS medal_type,
        LAG(m.type) OVER (PARTITION BY t.name, f.name ORDER BY m.year) AS prev_medal_type
    FROM tournament t
    JOIN format f ON t.tournament_id = f.tournament_id
    JOIN medal m ON f.format_id = m.format_id 
    WHERE t.athlete_id = 1
)
SELECT COUNT(*) AS color_changes
FROM medals_ordered
WHERE prev_medal_type IS NOT NULL 
  AND medal_type != prev_medal_type;
