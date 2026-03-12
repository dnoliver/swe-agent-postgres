import os
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from typing import Literal
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Few-shot examples for classification
EXAMPLES = """
Easy: List all customers from the customers table
Medium: Find the total sales per product category for the last quarter
Hard: Calculate the running average of order values per customer, partitioned by region, excluding outliers beyond 2 standard deviations
"""

# Create the prompt template
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            """You are a SQL query difficulty classifier. Classify questions as 'easy', 'medium', or 'hard'.

Examples:
{examples}

Rules:
- Easy: Simple SELECT, basic WHERE, single table
- Medium: JOINs, GROUP BY, aggregations, date filtering
- Hard: Window functions, CTEs, subqueries, complex logic, statistical operations

Respond with ONLY one word: easy, medium, or hard""",
        ),
        ("user", "{question}"),
    ]
)


def get_llm(provider: Literal["openai", "anthropic"] = "openai"):
    """Get LLM instance based on provider."""
    if provider == "anthropic":
        return ChatAnthropic(model="claude-sonnet-4-5-20250929", temperature=0)
    else:
        return ChatOpenAI(model="gpt-3.5-turbo", temperature=0)


def classify_question(
    question: str, provider: Literal["openai", "anthropic"] = "openai"
) -> str:
    """Classify a question as easy, medium, or hard."""
    llm = get_llm(provider)
    chain = prompt | llm | StrOutputParser()
    result = chain.invoke({"examples": EXAMPLES, "question": question})
    return result.strip().lower()


if __name__ == "__main__":
    # Test examples
    test_questions = [
        "SELECT * FROM users",
        "Find average sales by region with monthly trends",
        "Calculate percentile ranks with recursive CTEs",
    ]

    # Check if OpenAI API key is set
    if os.getenv("OPENAI_API_KEY"):
        print("Testing with OpenAI:")
        for q in test_questions:
            classification = classify_question(q, provider="openai")
            print(f"{classification.upper()}: {q}")
    else:
        print("Skipping OpenAI tests: OPENAI_API_KEY not set")

    # Check if Anthropic API key is set
    if os.getenv("ANTHROPIC_API_KEY"):
        print("\nTesting with Anthropic:")
        for q in test_questions:
            classification = classify_question(q, provider="anthropic")
            print(f"{classification.upper()}: {q}")
    else:
        print("Skipping Anthropic tests: ANTHROPIC_API_KEY not set")
