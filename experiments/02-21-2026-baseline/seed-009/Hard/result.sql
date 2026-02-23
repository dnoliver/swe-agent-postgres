WITH emily_medals AS (
    SELECT 
        f.name as event,
        f.format_id,
        m.type,
        m.year,
        m.location,
        m.medal_id
    FROM athlete a
    JOIN tournament t ON a.athlete_id = t.athlete_id
    JOIN format f ON t.tournament_id = f.tournament_id
    JOIN medal m ON f.format_id = m.format_id
    WHERE a.name = 'Emily Seebohm'
),
gold_medals AS (
    SELECT event, format_id, year, location, medal_id
    FROM emily_medals
    WHERE type = 'MedalGold'
),
other_medals AS (
    SELECT event, format_id, year, location, medal_id
    FROM emily_medals
    WHERE type != 'MedalGold'
)
SELECT COUNT(DISTINCT gm.medal_id) as count
FROM gold_medals gm
WHERE EXISTS (
    SELECT 1
    FROM other_medals om
    WHERE om.format_id = gm.format_id
    AND om.year > gm.year
);
