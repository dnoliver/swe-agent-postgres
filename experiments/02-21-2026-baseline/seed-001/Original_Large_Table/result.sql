WITH gold_count AS (
    SELECT 
        t.name AS tournament_name,
        COUNT(*) AS gold_medals
    FROM athlete a
    JOIN tournament t ON a.athlete_id = t.athlete_id
    JOIN format f ON t.tournament_id = f.tournament_id
    JOIN medal m ON f.format_id = m.format_id
    WHERE a.name = 'Rafael Aghayev'
        AND m.type = 'MedalGold'
    GROUP BY t.name
)
SELECT tournament_name
FROM gold_count
WHERE gold_medals = (SELECT MAX(gold_medals) FROM gold_count);
