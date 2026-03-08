#!/bin/bash

echo "=== Testing Solution ==="
echo ""
echo "1. Testing SQL query from result.sql:"
psql -c "$(cat result.sql)"
echo ""
echo "2. Content of result.txt (final answer):"
cat result.txt
echo ""
echo "3. Verifying query matches expected results..."
QUERY_RESULT=$(psql -t -c "$(cat result.sql)" | sed 's/^ *//' | sed 's/ *$//' | grep -v '^$' | paste -sd, - | sed 's/,/, /g')
EXPECTED="200 m medley, 400 m freestyle, 4x100 m freestyle, 4x100 m medley, 4x200 m freestyle, 4x50 m medley"
ACTUAL=$(cat result.txt | tr -d '\n')

echo "Expected: $EXPECTED"
echo "Actual  : $ACTUAL"
echo ""
if [ "$EXPECTED" = "$ACTUAL" ]; then
    echo "✓ SUCCESS: Answer matches expected result!"
else
    echo "✗ FAILURE: Answer does not match!"
fi
