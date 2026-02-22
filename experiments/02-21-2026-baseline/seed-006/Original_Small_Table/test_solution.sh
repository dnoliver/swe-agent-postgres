#!/bin/bash

echo "=== Testing Solution ==="
echo ""
echo "Question: How many International Bronze Medals did Yuta Watanabe win throughout his/her career?"
echo ""

echo "1. Finding Yuta Watanabe in the database:"
psql -c "SELECT * FROM public.athlete WHERE name = 'Yuta Watanabe';"
echo ""

echo "2. Finding tournaments participated by Yuta Watanabe:"
psql -c "SELECT a.name, t.name as tournament FROM public.athlete a JOIN public.tournament t ON a.athlete_id = t.athlete_id WHERE a.name = 'Yuta Watanabe';"
echo ""

echo "3. Finding medals won by Yuta Watanabe:"
psql -c "SELECT a.name as athlete_name, t.name as tournament_name, f.name as format_name, m.type as medal_type, m.year, m.location FROM public.athlete a JOIN public.tournament t ON a.athlete_id = t.athlete_id JOIN public.format f ON t.tournament_id = f.tournament_id JOIN public.medal m ON f.format_id = m.format_id WHERE a.name = 'Yuta Watanabe';"
echo ""

echo "4. Running the final query from result.sql:"
psql -c "$(cat /agent/result.sql)"
echo ""

echo "5. Answer from result.txt:"
cat /agent/result.txt
echo ""

echo "=== Conclusion ==="
echo "Yuta Watanabe won 1 International Bronze Medal at the East Asia Basketball Championship in 2013 (Incheon)."
