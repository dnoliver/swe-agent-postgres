WITH medals_data AS (
    SELECT 
        f.name AS event_name,
        m.medal_id,
        m.year,
        m.type,
        m.location
    FROM athlete a
    JOIN tournament t ON a.athlete_id = t.athlete_id
    JOIN format f ON t.tournament_id = f.tournament_id
    JOIN medal m ON f.format_id = m.format_id
    WHERE a.name = 'Mary-Sophie Harvey'
),
gold_medals AS (
    SELECT 
        event_name,
        medal_id AS gold_medal_id,
        year AS gold_year,
        location AS gold_location
    FROM medals_data
    WHERE type = 'MedalGold'
)
SELECT COUNT(*)
FROM gold_medals g
WHERE EXISTS (
    SELECT 1
    FROM medals_data m
    WHERE m.event_name = g.event_name
    AND (m.year > g.gold_year OR (m.year = g.gold_year AND m.medal_id > g.gold_medal_id))
);
