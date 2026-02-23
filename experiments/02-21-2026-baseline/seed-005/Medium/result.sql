SELECT
    COUNT(DISTINCT m.year) AS appearances,
    COUNT(CASE WHEN m.type = 'MedalGold' THEN 1 END) AS wins
FROM medal AS m
INNER JOIN format AS f ON m.format_id = f.format_id
INNER JOIN tournament AS t ON f.tournament_id = t.tournament_id
INNER JOIN athlete AS a ON t.athlete_id = a.athlete_id
WHERE a.name = 'Timo Boll' AND t.name = 'European Games';
