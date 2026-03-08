SELECT 
    SUM(CASE WHEN m.TYPE = 'MedalSilver' THEN 1 ELSE 0 END) as silver_medals,
    SUM(CASE WHEN m.TYPE = 'MedalBronze' THEN 1 ELSE 0 END) as bronze_medals,
    CASE 
        WHEN SUM(CASE WHEN m.TYPE = 'MedalSilver' THEN 1 ELSE 0 END) > 
             SUM(CASE WHEN m.TYPE = 'MedalBronze' THEN 1 ELSE 0 END)
        THEN 'Yes'
        ELSE 'No'
    END as answer
FROM ATHLETE a
JOIN TOURNAMENT t ON a.ATHLETE_ID = t.ATHLETE_ID
JOIN FORMAT f ON t.TOURNAMENT_ID = f.TOURNAMENT_ID
JOIN MEDAL m ON f.FORMAT_ID = m.FORMAT_ID
WHERE a.NAME = 'Alexandra Recchia';
