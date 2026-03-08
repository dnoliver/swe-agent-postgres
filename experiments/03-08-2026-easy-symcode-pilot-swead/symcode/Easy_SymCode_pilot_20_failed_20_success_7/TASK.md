# Answer a Question Using the Database

You are a **data analyst**. Your task is to answer a question using the
**`postgres`** database.

**Question:**

> How many International Bronze Medals did Steffen Peters win in the  2011  ?

______________________________________________________________________

## Preprocessing

Interpreat and reformulate the question using the Database Information below.
Make the question more contextual to the database model. The questions might not
directly match the database items, for example a question might talk about a
"Silver" medal, but the database might use "MedalSilver" as a representation.

______________________________________________________________________

## Postprocessing

Once you have an answer to the question, use the following formatting guides:

1. The answer shall be in a single line
2. If the answer is a list of numbers, they shall be sorted in ascending order
3. The answer shall be in "human" format, not as database query output
4. Floating points answers shall be rounded to the nearest integer number

______________________________________________________________________

## Database Information

```sql
-- =================================================================
-- ATHLETICS DATABASE SCHEMA
-- =================================================================
-- This schema models an athletics competition tracking system that
-- stores information about athletes, tournaments, formats, and medals.
--
-- Entity Relationships:
-- - ATHLETE (1) ----< (N) TOURNAMENT
-- - TOURNAMENT (1) ----< (N) FORMAT
-- - FORMAT (1) ----< (N) MEDAL
-- - ATHLETE (1) ----< (N) PERSONALINFORMATION
-- =================================================================

-- ATHLETE Table
-- Stores basic information about athletes participating in competitions
CREATE TABLE ATHLETE (
	ATHLETE_ID INTEGER PRIMARY KEY,
	NAME TEXT NOT NULL
);

-- TOURNAMENT Table
-- Represents tournaments that athletes compete in
-- Foreign Key: ATHLETE_ID references ATHLETE(ATHLETE_ID)
CREATE TABLE TOURNAMENT (
	TOURNAMENT_ID INTEGER PRIMARY KEY,
	ATHLETE_ID INTEGER,
	NAME TEXT NOT NULL,
	FOREIGN KEY (ATHLETE_ID) REFERENCES ATHLETE(ATHLETE_ID)
);

-- FORMAT Table
-- Describes the format of tournaments (e.g., individual, team, relay)
-- Foreign Key: TOURNAMENT_ID references TOURNAMENT(TOURNAMENT_ID)
CREATE TABLE FORMAT(
	FORMAT_ID INTEGER PRIMARY KEY,
	TOURNAMENT_ID INTEGER,
	NAME TEXT NOT NULL,  -- e.g., "Singles", "Doubles", "Team"
	FOREIGN KEY (TOURNAMENT_ID) REFERENCES TOURNAMENT(TOURNAMENT_ID)
);

-- MEDAL Table
-- Records medal information for specific formats and events
-- Foreign Key: FORMAT_ID references FORMAT(FORMAT_ID)
CREATE TABLE MEDAL (
	MEDAL_ID INTEGER PRIMARY KEY,
	FORMAT_ID INTEGER,
	TYPE TEXT NOT NULL,  -- e.g., 'MedalGold', 'MedalSilver', 'MedalBronze'
	YEAR INTEGER,
	LOCATION TEXT NOT NULL,  -- Competition location
	FOREIGN KEY (FORMAT_ID) REFERENCES FORMAT(FORMAT_ID)
);

-- PERSONALINFORMATION Table
-- Stores detailed personal information about athletes
-- Foreign Key: ATHLETE_ID references ATHLETE(ATHLETE_ID)
CREATE TABLE PERSONALINFORMATION (
	INFO_ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	ATHLETE_ID INTEGER,
	BIRTH_YEAR INTEGER,
	BIRTH_MONTH INTEGER,
	BIRTH_DAY INTEGER,
	FOREIGN KEY (ATHLETE_ID) REFERENCES ATHLETE(ATHLETE_ID)
);

-- =================================================================
-- Sample Queries for Understanding the Schema:
-- =================================================================
-- 
-- Get all athletes and their personal information:
-- SELECT a.NAME, p.BIRTH_YEAR, p.BIRTH_MONTH, p.BIRTH_DAY 
-- FROM ATHLETE a 
-- LEFT JOIN PERSONALINFORMATION p ON a.ATHLETE_ID = p.ATHLETE_ID;
--
-- Get tournaments for a specific athlete:
-- SELECT t.NAME 
-- FROM TOURNAMENT t 
-- WHERE t.ATHLETE_ID = <athlete_id>;
--
-- Get medals won in a specific year:
-- SELECT m.TYPE, m.LOCATION, f.NAME as format_name 
-- FROM MEDAL m 
-- JOIN FORMAT f ON m.FORMAT_ID = f.FORMAT_ID 
-- WHERE m.YEAR = <year>;

-- =================================================================
-- Sample Data in Each Table:
-- =================================================================
--
-- ATHLETE Table Sample Data:
-- athlete_id |    name     
-- -----------+-------------
--          1 | Diego Elías
--
-- TOURNAMENT Table Sample Data:
-- tournament_id | athlete_id |     name     
-- --------------+------------+--------------
--             1 |          1 | British Open
--
-- FORMAT Table Sample Data:
-- format_id | tournament_id |  name   
-- ----------+---------------+---------
--         1 |             1 | Singles
--
-- MEDAL Table Sample Data:
-- medal_id | format_id |    type     | year |  location  
-- ---------+-----------+-------------+------+------------
--        1 |         1 | MedalSilver | 2023 | Birmingham
--
-- PERSONALINFORMATION Table Sample Data:
-- info_id | athlete_id | birth_year | birth_month | birth_day 
-- --------+------------+------------+-------------+-----------
--       1 |          1 |       1996 |          11 |        19
-- 
-- =================================================================
```

______________________________________________________________________

## Output Requirements (MANDATORY)

After you determine the correct query and final answer:

1. Save the exact SQL query used to compute the answer into a file named:

   ```text
   result.sql
   ```

2. Save only the final answer (no extra text, no explanation) into a file named:

   ```text
   result.txt
   ```

### File Writing Instructions

Use shell redirection to create the files.

Example:

```bash
echo "SELECT COUNT(*) FROM public.passenger WHERE sex = 'male';" > result.sql

echo "577" > result.txt
```

### Important Rules

- `result.sql` must contain ONLY the SQL query.
- `result.txt` must contain ONLY the final answer.
- Do NOT include explanations in either file.
- Ensure the files are created in same directory as the TASK.md file.
- The query in `result.sql` must exactly match the query used to generate the
  answer.

______________________________________________________________________

## Tools Available

1. **`sqlfluff`** - Lint and check your SQL queries for syntax or style errors
   before running them.

   Example usage:

   ```bash
   echo "SELECT name FROM public.passenger" | sqlfluff lint --dialect postgres -
   ```

2. **`EXPLAIN`** - Preview your query in psql to ensure it executes correctly.

   Example usage:

   ```bash
   psql -c "EXPLAIN SELECT COUNT(*) FROM public.passenger WHERE sex = 'male';"
   ```

3. **`psql`** - Connect and execute queries against the database. Credentials
   are already set.

   Example usage:

   ```bash
   psql -c "SELECT COUNT(*) FROM public.passenger WHERE sex = 'male';"
   ```

______________________________________________________________________