#!/bin/bash
echo "Testing the solution..."
echo ""
echo "1. Verifying query executes successfully:"
RESULT=$(psql -t -c "$(cat result.sql)" | xargs)
echo "   Query result: $RESULT"
echo ""
echo "2. Verifying result matches result.txt:"
EXPECTED=$(cat result.txt | xargs)
echo "   Expected: $EXPECTED"
echo "   Actual:   $RESULT"
echo ""
if [ "$RESULT" = "$EXPECTED" ]; then
    echo "✓ SUCCESS: Query result matches expected answer!"
else
    echo "✗ FAILURE: Results don't match!"
    exit 1
fi
echo ""
echo "3. Showing medal breakdown for Mariel Zagunis:"
psql -c "SELECT m.type, COUNT(*) as medal_count
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Mariel Zagunis'
GROUP BY m.type
ORDER BY medal_count DESC, m.type ASC;"
