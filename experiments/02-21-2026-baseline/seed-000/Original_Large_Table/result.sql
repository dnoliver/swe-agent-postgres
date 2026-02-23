WITH athlete_medals AS (
    SELECT 
        m.year,
        pi.birth_year,
        pi.birth_month,
        pi.birth_day
    FROM athlete a
    JOIN personalinformation pi ON a.athlete_id = pi.athlete_id
    JOIN tournament t ON a.athlete_id = t.athlete_id
    JOIN format f ON t.tournament_id = f.tournament_id
    JOIN medal m ON f.format_id = m.format_id
    WHERE a.name = 'Caeleb Dressel'
),
medal_counts AS (
    SELECT
        COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(make_date(year, 1, 1), make_date(birth_year, birth_month, birth_day))) >= 20 
                        AND EXTRACT(YEAR FROM AGE(make_date(year, 1, 1), make_date(birth_year, birth_month, birth_day))) < 30 
                   THEN 1 END) AS medals_in_twenties,
        COUNT(CASE WHEN EXTRACT(YEAR FROM AGE(make_date(year, 1, 1), make_date(birth_year, birth_month, birth_day))) >= 30 
                        AND EXTRACT(YEAR FROM AGE(make_date(year, 1, 1), make_date(birth_year, birth_month, birth_day))) < 40 
                   THEN 1 END) AS medals_in_thirties
    FROM athlete_medals
)
SELECT 
    CASE 
        WHEN medals_in_twenties > medals_in_thirties THEN 'Yes'
        ELSE 'No'
    END AS answer
FROM medal_counts;
