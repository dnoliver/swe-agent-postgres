SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Yes'
        ELSE 'No'
    END as has_silver_medal
FROM ATHLETE a
JOIN TOURNAMENT t ON a.ATHLETE_ID = t.ATHLETE_ID
JOIN FORMAT f ON t.TOURNAMENT_ID = f.TOURNAMENT_ID
JOIN MEDAL m ON f.FORMAT_ID = m.FORMAT_ID
WHERE a.NAME = 'Rikako Ikee'
  AND t.NAME = 'Pan Pacific Championships'
  AND m.TYPE = 'MedalSilver';
