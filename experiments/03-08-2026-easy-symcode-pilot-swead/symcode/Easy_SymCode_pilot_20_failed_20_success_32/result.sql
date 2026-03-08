SELECT 
    SUM(CASE WHEN m.type = 'MedalSilver' THEN 1 ELSE 0 END) as silver_count,
    SUM(CASE WHEN m.type = 'MedalBronze' THEN 1 ELSE 0 END) as bronze_count
FROM ATHLETE a
JOIN TOURNAMENT t ON a.ATHLETE_ID = t.ATHLETE_ID
JOIN FORMAT f ON t.TOURNAMENT_ID = f.TOURNAMENT_ID
JOIN MEDAL m ON f.FORMAT_ID = m.FORMAT_ID
WHERE a.NAME = 'Juan Matute Guimon'
  AND t.NAME = 'European Junior Championships';
