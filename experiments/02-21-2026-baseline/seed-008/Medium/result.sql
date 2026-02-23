SELECT AVG(medals_per_year) as avg_medals_per_year
FROM (
    SELECT m.year, COUNT(*) as medals_per_year
    FROM medal m
    JOIN format f ON m.format_id = f.format_id
    JOIN tournament t ON f.tournament_id = t.tournament_id
    JOIN athlete a ON t.athlete_id = a.athlete_id
    WHERE a.name = 'Ovidiu Ionescu'
    GROUP BY m.year
) as yearly_medals;
