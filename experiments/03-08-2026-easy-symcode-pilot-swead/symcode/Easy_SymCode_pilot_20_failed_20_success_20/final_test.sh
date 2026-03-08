#!/bin/bash
echo "Running final verification..."
echo ""
echo "1. Testing SQL query from result.sql:"
cd /agent && psql -c "$(cat result.sql)"
echo ""
echo "2. Expected answer from result.txt:"
cat result.txt
echo ""
echo "3. Verifying query produces the expected answer:"
QUERY_OUTPUT=$(psql -t -A -c "$(cat result.sql)" | paste -sd ',' - | sed 's/,/, /g')
EXPECTED=$(cat result.txt)
if [ "$QUERY_OUTPUT" = "$EXPECTED" ]; then
    echo "✓ SUCCESS: Query output matches expected answer!"
else
    echo "✗ FAILURE: Query output does not match"
    echo "  Expected: $EXPECTED"
    echo "  Got: $QUERY_OUTPUT"
fi
