# Answer a Question Using the Database

You are a **data analyst**. Your task is to answer a question using the **`titanic`** database.

**Question:**

> How many passengers were not from the United States or England?

______________________________________________________________________

## Tools Available

1. **`sqlfluff`** – Lint and check your SQL queries for syntax or style errors before running them.

   Example usage:

   ```bash
   echo "SELECT name FROM public.passenger" | sqlfluff lint --dialect postgres -
   ```

2. **`EXPLAIN`** – Preview your query in psql to ensure it executes correctly.

   Example usage:

   ```bash
   psql -c "EXPLAIN SELECT COUNT(*) FROM public.passenger WHERE sex = 'male';"
   ```

3. **`psql`** – Connect and execute queries against the database. Credentials are already set.

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

* Always lint your queries before execution.
* Use `EXPLAIN` to preview query execution and avoid mistakes.
