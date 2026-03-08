#!/bin/bash

echo "=== Testing Solution for Zach Apple's International Silver Medals ==="
echo ""

echo "1. Finding Zach Apple in the database:"
psql -c "SELECT * FROM ATHLETE WHERE NAME = 'Zach Apple';"
echo ""

echo "2. All tournaments for Zach Apple:"
psql -c "SELECT * FROM TOURNAMENT WHERE ATHLETE_ID = (SELECT ATHLETE_ID FROM ATHLETE WHERE NAME = 'Zach Apple');"
echo ""

echo "3. All silver medals for Zach Apple with details:"
psql -c "
SELECT m.medal_id, m.type, m.year, m.location, t.name as tournament, f.name as format
FROM MEDAL m
JOIN FORMAT f ON m.FORMAT_ID = f.FORMAT_ID
JOIN TOURNAMENT t ON f.TOURNAMENT_ID = t.TOURNAMENT_ID
JOIN ATHLETE a ON t.ATHLETE_ID = a.ATHLETE_ID
WHERE a.NAME = 'Zach Apple' 
  AND m.TYPE = 'MedalSilver';"
echo ""

echo "4. Running the query from result.sql:"
psql -c "$(cat result.sql)"
echo ""

echo "5. Content of result.txt:"
cat result.txt
echo ""

echo "=== All tests completed ==="
