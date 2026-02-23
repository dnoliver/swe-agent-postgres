SELECT 
    a.name,
    SUM(CASE WHEN m.type = 'MedalBronze' THEN 1 ELSE 0 END) as bronze_medals,
    SUM(CASE WHEN m.type = 'MedalGold' THEN 1 ELSE 0 END) as gold_medals
FROM public.athlete a
JOIN public.tournament t ON a.athlete_id = t.athlete_id
JOIN public.format f ON t.tournament_id = f.tournament_id
JOIN public.medal m ON f.format_id = m.format_id
WHERE a.name = 'Josif Miladinov'
GROUP BY a.name;
