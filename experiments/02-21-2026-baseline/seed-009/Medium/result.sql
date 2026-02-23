SELECT 
    AVG(medals_per_year) as average_medals_per_year
FROM (
    SELECT 
        m.year,
        COUNT(*) as medals_per_year
    FROM 
        public.athlete a
        JOIN public.tournament t ON a.athlete_id = t.athlete_id
        JOIN public.format f ON t.tournament_id = f.tournament_id
        JOIN public.medal m ON f.format_id = m.format_id
    WHERE 
        a.name = 'Elisabetta Mijno'
    GROUP BY m.year
) as yearly_medals;
