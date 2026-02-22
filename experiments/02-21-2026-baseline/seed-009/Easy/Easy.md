# Answer a Question Using the Database

You are a **data analyst**. Your task is to answer a question using the
**`postgres`** database.

**Question:**

> Does Dai Xiaoxiang have more Bronze Medals than Gold Medals in Team ?

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

## Tools Available

1. **`sqlfluff`** – Lint and check your SQL queries for syntax or style errors
   before running them.

   Example usage:

   ```bash
   echo "SELECT name FROM public.passenger" | sqlfluff lint --dialect postgres -
   ```

2. **`EXPLAIN`** – Preview your query in psql to ensure it executes correctly.

   Example usage:

   ```bash
   psql -c "EXPLAIN SELECT COUNT(*) FROM public.passenger WHERE sex = 'male';"
   ```

3. **`psql`** – Connect and execute queries against the database. Credentials
   are already set.

   Example usage:

   ```bash
   psql -c "SELECT COUNT(*) FROM public.passenger WHERE sex = 'male';"
   ```

## Recommended Workflow

1. Write your SQL query to answer the question.
2. Lint your query using `sqlfluff` to catch syntax or formatting issues.
3. Preview your query with `EXPLAIN` in psql to ensure it runs safely.
4. Run the query in `psql` to get the final answer.

## Example Query

```sql
SELECT COUNT(*) 
FROM public.passenger
WHERE sex = 'male';
```

This will return the total number of male passengers on the Titanic.

## Notes

- Always lint your queries before execution.
- Use `EXPLAIN` to preview query execution and avoid mistakes.