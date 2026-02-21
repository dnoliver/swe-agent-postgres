# SWE Agent and Postgres

## Getting Started

This project sets up a PostgreSQL database with pgAdmin and an AI-powered agent
that can interact with the database to solve tasks using natural language
instructions.

### Prerequisites

Before running this project, ensure you have the following installed:

- **Docker** -
  [Download Docker Desktop](https://www.docker.com/products/docker-desktop/) for
  your operating system
- **Docker Compose** - Usually included with Docker Desktop (v2.0+)
- **Anthropic API Key** - Required for the AI agent to function. Get one from
  [Anthropic Console](https://console.anthropic.com/)
- **Python** - Required for task generation. Get one from
  [Python Downloads](https://www.python.org/downloads/)

### Installation

1. **Clone this repository** to your local machine.

   ```bash
   git clone https://github.com/dnoliver/swe-agent-postgres.git
   ```

2. **Prepare tasks**

   Update the submodules in this repo:

   ```bash
   git submodule update --init --recursive
   ```

   **NOTE:** if you don't have access to the external repos, task generation
   will not work

   Prepare the python virtual environment:

   ```bash
   cd tasks/
   python -m venv .venv
   pip install -r requirements.txt
   ```

   Generate tasks:

   ```bash
   cd tasks/
   source .venv/bin/activate
   python init.py
   ```

3. **Create a `.env` file** in the root directory by copying the example file:

   ```bash
   cp env.example .env
   ```

4. **Configure your environment variables** in the `.env` file:

   ```bash
   ANTHROPIC_API_KEY="sk-ant-your-actual-api-key-here"
   MSWEA_MODEL_NAME="anthropic/claude-3-5-sonnet-20241022"
   TASK="Easy"
   ```

   Replace `sk-ant-your-actual-api-key-here` with your actual Anthropic API key.
   You can use any available Claude model name for `MSWEA_MODEL_NAME`. Task
   should be one of the generated tasks in `tasks/` directory.

### Running the Project

Start all services using Docker Compose:

```bash
docker compose up -d
```

This will launch three services:

- **PostgreSQL** - Running on port `5432`
- **pgAdmin** - Accessible at `http://localhost:5050`
- **Agent** - An AI-powered container that will automatically execute the task

### Accessing Services

#### pgAdmin

1. Open your browser and navigate to `http://localhost:5050`
2. Log in with the following credentials:
   - **Email**: `pgadmin4@pgadmin.org`
   - **Password**: `pgadmin`

#### PostgreSQL

Connect directly to the database using psql or your preferred PostgreSQL client:

```bash
docker exec -it postgres psql -U postgres -d postgres
```

Or from your local machine:

```bash
psql -h localhost -p 5432 -U postgres -d postgres
```

Default credentials:

- **Username**: `postgres`
- **Password**: `postgres`
- **Database**: `postgres`

#### Viewing Agent Output

The agent container runs automatically after starting. To view the agent's
execution logs:

```bash
docker compose logs -f agent
```

You can inspect a trajectory file by attaching to the container:

```bash
docker compose exec agent bash
mini-extra inspect /agent/trajectory.json
```

The agent will process the task and save its trajectory to
`agent/trajectory.json`.

### Stopping the Project

To stop all running services:

```bash
docker compose down
```

To stop and remove all services, volumes, and data:

```bash
docker compose down -v
```

### Troubleshooting

**Agent container fails to start:**

- Ensure your `.env` file contains a valid `ANTHROPIC_API_KEY`
- Check that the API key has sufficient credits/permissions

**Cannot access pgAdmin:**

- Verify the containers are running: `docker compose ps`
- Ensure port 5050 is not in use by another application

**Database connection issues:**

- Wait a few seconds after starting for PostgreSQL to fully initialize
- Check the PostgreSQL logs: `docker logs postgres`

### Project Structure

```text
.
├── compose.yml           # Docker Compose configuration
├── env.example           # Environment variables template
├── servers.json          # pgAdmin server configuration
├── README.md             # This file
├── agent/
│   └── mini.yaml         # Agent configuration
├── external/
│   └── nsum              # External submodule
└── tasks/
    ├── init.py           # Task generation utilities
    ├── TASK.md.j2        # Task template
    └── requirements.txt  # Dependencies for task generation
```

## Some Links

- [pgAdmin - Container Deployment - Environment Variables](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html#environment-variables)
- [pgAdmin - Import/Export Servers - JSON Format](https://www.pgadmin.org/docs/pgadmin4/latest/import_export_servers.html#json-format)
- [neondatabase/postgres-sample-dbs](https://github.com/neondatabase/postgres-sample-dbs)
