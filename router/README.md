# Question Difficulty Classifier

A simple LangChain application that classifies SQL questions as easy, medium, or hard.

## Setup

### 1. Create Virtual Environment

```bash
python3.12 -m venv .venv
source .venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and add your API keys:

```
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
```

## Usage

### Run the Demo

```bash
python app.py
```

This will run test questions using both OpenAI and Anthropic providers.

### Use in Your Code

```python
from app import classify_question

# Use OpenAI (default)
result = classify_question("SELECT * FROM users WHERE id = 1")

# Use Anthropic
result = classify_question("SELECT * FROM users WHERE id = 1", provider="anthropic")

print(result)  # "easy", "medium", or "hard"
```

## Classification Rules

- **Easy**: Simple SELECT, basic WHERE, single table
- **Medium**: JOINs, GROUP BY, aggregations, date filtering
- **Hard**: Window functions, CTEs, subqueries, complex logic, statistical operations
