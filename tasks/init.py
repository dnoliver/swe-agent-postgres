# SQL helpers (schema-based methods)


from pathlib import Path
import re
from jinja2 import Template


import pandas as pd


class SQLFileWriter:
    """Simple cursor replacement that writes SQL to a file instead of executing it."""

    def __init__(self, filepath):
        self.filepath = filepath
        self.file = open(filepath, "w")

    def execute(self, sql, params=None):
        """Write SQL to file, replacing parameters if provided."""
        if params:
            # Replace ? placeholders with actual values
            if isinstance(params, tuple):
                for param in params:
                    # Format the parameter appropriately
                    if param is None:
                        formatted = "NULL"
                    elif isinstance(param, str):
                        formatted = f"'{param.replace("'", "''")}'"
                    elif isinstance(param, int):
                        formatted = str(param)
                    else:
                        formatted = str(param)
                    sql = sql.replace("?", formatted, 1)
            elif isinstance(params, list):
                for param in params:
                    if param is None:
                        formatted = "NULL"
                    elif isinstance(param, str):
                        formatted = f"'{param.replace("'", "''")}'"
                    elif isinstance(param, int):
                        formatted = str(param)
                    else:
                        formatted = str(param)
                    sql = sql.replace("?", formatted, 1)

        # Write the SQL to file with a semicolon
        self.file.write(sql.strip())
        if not sql.strip().endswith(";"):
            self.file.write(";")
        self.file.write("\n")

    def close(self):
        """Close the file."""
        if hasattr(self, "file"):
            self.file.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()


def parse_birth_date(lines):
    for i, line in enumerate(lines):
        if line.strip().lower() == "birth date":
            for j in range(i + 1, len(lines)):
                candidate = lines[j].strip()
                if not candidate:
                    continue
                m = re.search(r"(\d{4})-(\d{1,2})-(\d{1,2})", candidate)
                if m:
                    y, mo, d = map(int, m.groups())
                    return y, mo, d
                m = re.search(r"(\d{4})", candidate)
                if m:
                    return int(m.group(1)), None, None
    return None, None, None


def parse_context_to_records(context):
    lines = [l.strip() for l in context.splitlines()]
    name = ""
    for line in lines:
        if line:
            name = line
            break

    birth_year, birth_month, birth_day = parse_birth_date(lines)

    in_tournament = False
    current_tournament = None
    medal_rows = []

    for line in lines:
        if not line:
            continue
        if line.lower().startswith("country representing"):
            in_tournament = True
            continue
        if not in_tournament:
            continue

        if "Medal" in line:
            if not current_tournament:
                continue
            parts = re.split(r"\t|\s{2,}", line, maxsplit=1)
            if len(parts) == 1:
                m = re.search(r"\bMedal", line)
                if not m:
                    continue
                format_name = line[: m.start()].strip()
                medals_text = line[m.start() :].strip()
            else:
                format_name = parts[0].strip()
                medals_text = parts[1].strip()

            for entry in medals_text.split(","):
                entry = entry.strip()
                m = re.match(r"(Medal\w+)\s*\|\s*(\d{4})\s*\|\s*(.+)", entry)
                if not m:
                    continue
                medal_type, year, location = m.groups()
                medal_rows.append(
                    {
                        "tournament": current_tournament,
                        "format": format_name,
                        "type": medal_type,
                        "year": int(year),
                        "location": location.strip(),
                    }
                )
        else:
            current_tournament = line

    return name, (birth_year, birth_month, birth_day), medal_rows


def build_sqlite_db_to_file(context, filepath):
    """
    Build SQL statements and write them to a file instead of executing them.
    This is a drop-in replacement for build_sqlite_db that writes SQL to a file.
    """

    # Use SQLFileWriter instead of actual database cursor
    cur = SQLFileWriter(filepath)

    cur.execute(
        "CREATE TABLE Athlete (athlete_id INTEGER PRIMARY KEY, name TEXT NOT NULL)"
    )
    cur.execute(
        "CREATE TABLE Tournament (tournament_id INTEGER PRIMARY KEY, athlete_id INTEGER, name TEXT NOT NULL)"
    )
    cur.execute(
        "CREATE TABLE Format (format_id INTEGER PRIMARY KEY, tournament_id INTEGER, name TEXT NOT NULL)"
    )
    cur.execute(
        "CREATE TABLE Medal (medal_id INTEGER PRIMARY KEY, format_id INTEGER, type TEXT NOT NULL, year INTEGER, location TEXT NOT NULL)"
    )
    cur.execute(
        "CREATE TABLE PersonalInformation (info_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, athlete_id INTEGER, birth_year INTEGER, birth_month INTEGER, birth_day INTEGER)"
    )

    athlete_id = 1
    tournament_ids = {}
    format_ids = {}
    next_tournament_id = 1
    next_format_id = 1
    next_medal_id = 1

    for c in context:
        name, birth, medal_rows = parse_context_to_records(c)
        cur.execute(
            "INSERT INTO Athlete (athlete_id, name) VALUES (?, ?)", (athlete_id, name)
        )
        birth_year, birth_month, birth_day = birth
        cur.execute(
            "INSERT INTO PersonalInformation (athlete_id, birth_year, birth_month, birth_day) VALUES (?, ?, ?, ?)",
            (athlete_id, birth_year, birth_month, birth_day),
        )

        for row in medal_rows:
            t_name = row["tournament"]
            if t_name not in tournament_ids:
                tournament_ids[t_name] = next_tournament_id
                cur.execute(
                    "INSERT INTO Tournament (tournament_id, athlete_id, name) VALUES (?, ?, ?)",
                    (next_tournament_id, athlete_id, t_name),
                )
                next_tournament_id += 1

            t_id = tournament_ids[t_name]
            f_key = (t_id, row["format"])
            if f_key not in format_ids:
                format_ids[f_key] = next_format_id
                cur.execute(
                    "INSERT INTO Format (format_id, tournament_id, name) VALUES (?, ?, ?)",
                    (next_format_id, t_id, row["format"]),
                )
                next_format_id += 1

            f_id = format_ids[f_key]
            cur.execute(
                "INSERT INTO Medal (medal_id, format_id, type, year, location) VALUES (?, ?, ?, ?, ?)",
                (next_medal_id, f_id, row["type"], row["year"], row["location"]),
            )
            next_medal_id += 1

        athlete_id += 1

    cur.close()
    return filepath


DATA_DIR = (
    Path(__file__).resolve().parent.parent
    / "external"
    / "nsum"
    / "Dataset"
    / "Test_Dataset_with_Splits"
)
MAX_ROWS_PER_SPLIT = 1
SEED = 0


if __name__ == "__main__":

    def load_split(name):
        df = pd.read_csv(DATA_DIR / f"{name}.tsv", sep="	")
        if MAX_ROWS_PER_SPLIT is not None:
            df = df.sample(
                n=min(MAX_ROWS_PER_SPLIT, len(df)), random_state=SEED
            ).reset_index(drop=True)
        return df

    splits = {
        "Original": load_split("Original"),
        "CounterFactual": load_split("CounterFactual"),
        "Original_Small_Table": load_split("Original_Small_Table"),
        "Original_Large_Table": load_split("Original_Large_Table"),
        "Easy": load_split("Easy"),
        "Medium": load_split("Medium"),
        "Hard": load_split("Hard"),
    }

    for key in splits:
        print(f"Processing split: {key}")
        build_sqlite_db_to_file(context=splits[key]["Context"], filepath=f"{key}.sql")
        splits[key][["Questions", "Answers"]].to_csv(f"{key}.txt", index=False)
        template_text = Path("TASK.md.j2").read_text()
        template = Template(template_text)
        first_question = splits[key]["Questions"].iloc[0]
        output = template.render(question=first_question)
        Path(f"{key}.md").write_text(output)
