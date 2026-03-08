#!/bin/bash

echo "Testing the solution..."
echo ""

echo "1. Checking if result.sql exists:"
if [ -f result.sql ]; then
    echo "✓ result.sql exists"
else
    echo "✗ result.sql does not exist"
    exit 1
fi

echo ""
echo "2. Checking if result.txt exists:"
if [ -f result.txt ]; then
    echo "✓ result.txt exists"
else
    echo "✗ result.txt does not exist"
    exit 1
fi

echo ""
echo "3. Content of result.sql:"
cat result.sql
echo ""

echo "4. Content of result.txt:"
cat result.txt
echo ""

echo "5. Running the SQL query:"
psql -c "$(cat result.sql)"
echo ""

echo "6. Verifying the answer matches:"
QUERY_RESULT=$(psql -t -c "$(cat result.sql)" | tr -d ' ')
FILE_RESULT=$(cat result.txt | tr -d ' ')

if [ "$QUERY_RESULT" == "$FILE_RESULT" ]; then
    echo "✓ Query result matches result.txt"
else
    echo "✗ Query result ($QUERY_RESULT) does not match result.txt ($FILE_RESULT)"
    exit 1
fi

echo ""
echo "All tests passed! ✓"
