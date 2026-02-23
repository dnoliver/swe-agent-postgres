SELECT CASE WHEN EXISTS (
    SELECT 1
    FROM public.athlete a
    JOIN public.tournament t ON a.athlete_id = t.athlete_id
    JOIN public.format f ON t.tournament_id = f.tournament_id
    JOIN public.medal m ON f.format_id = m.format_id
    WHERE a.name = 'Timo Boll' AND m.year = 2003
) THEN 'Yes' ELSE 'No' END AS answer;
