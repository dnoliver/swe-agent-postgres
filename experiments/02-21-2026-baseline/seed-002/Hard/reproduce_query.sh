#!/bin/bash

# Query to find which medal type Mariel Zagunis has won the most medals in
psql -t -c "SELECT m.type
FROM athlete a
JOIN tournament t ON a.athlete_id = t.athlete_id
JOIN format f ON t.tournament_id = f.tournament_id
JOIN medal m ON f.format_id = m.format_id
WHERE a.name = 'Mariel Zagunis'
GROUP BY m.type
ORDER BY COUNT(*) DESC, m.type ASC
LIMIT 1;" | xargs

