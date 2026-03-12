import os
import csv
from pathlib import Path
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


def load_test_data(dataset_path: str, difficulty: str) -> list[tuple[str, str]]:
    """Load questions and expected difficulties from TSV file."""
    questions = []
    file_path = Path(dataset_path) / f"{difficulty}.tsv"
    
    if not file_path.exists():
        print(f"Warning: {file_path} not found")
        return questions
    
    with open(file_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter="	")
        for row in reader:
            question = row.get("Questions", "")
            expected_difficulty = row.get("Difficulty", "").lower()
            if question and expected_difficulty:
                questions.append((question, expected_difficulty))
    
    return questions


def evaluate_accuracy(
    test_data: list[tuple[str, str]],
    provider: Literal["openai", "anthropic"] = "openai"
) -> tuple[float, int, int, list[dict]]:
    """Evaluate classifier accuracy on test data."""
    correct = 0
    total = len(test_data)
    results = []
    
    for question, expected_difficulty in test_data:
        try:
            predicted_difficulty = classify_question(question, provider=provider)
            is_correct = predicted_difficulty == expected_difficulty
            if is_correct:
                correct += 1
            
            results.append({
                "question": question[:100] + "..." if len(question) > 100 else question,
                "expected": expected_difficulty,
                "predicted": predicted_difficulty,
                "correct": is_correct
            })
            
            # Print progress
            print(f"  {correct}/{total} correct | Expected: {expected_difficulty}, Predicted: {predicted_difficulty}")
        except Exception as e:
            print(f"  Error processing question: {e}")
            results.append({
                "question": question[:100] + "..." if len(question) > 100 else question,
                "expected": expected_difficulty,
                "predicted": "ERROR",
                "correct": False
            })
    
    accuracy = correct / total if total > 0 else 0.0
    return accuracy, correct, total, results


if __name__ == "__main__":
    # Dataset path
    dataset_path = "../external/nsum/Dataset/Test_Dataset_with_Splits"
    
    # Difficulties to test
    difficulties = ["Easy", "Medium", "Hard"]
    
    # Check if OpenAI API key is set
    if os.getenv("OPENAI_API_KEY"):
        print("=" * 80)
        print("Testing with OpenAI")
        print("=" * 80)
        
        for difficulty in difficulties:
            print(f"--- {difficulty} Dataset ---")
            test_data = load_test_data(dataset_path, difficulty)
            
            if not test_data:
                print(f"No test data found for {difficulty}")
                continue
            
            print(f"Loaded {len(test_data)} questions from {difficulty}.tsv")
            
            accuracy, correct, total, results = evaluate_accuracy(test_data, provider="openai")
            
            print(f"{difficulty} Results:")
            print(f"  Accuracy: {accuracy:.2%} ({correct}/{total})")
            
            # Print incorrect predictions
            incorrect = [r for r in results if not r["correct"]]
            if incorrect:
                print(f"  Incorrect predictions ({len(incorrect)}):")
                for r in incorrect[:5]:  # Show first 5 incorrect
                    print(f"    - Expected: {r['expected']}, Predicted: {r['predicted']}")
                    print(f"      Question: {r['question']}")
                if len(incorrect) > 5:
                    print(f"    ... and {len(incorrect) - 5} more")
    else:
        print("Skipping OpenAI tests: OPENAI_API_KEY not set")
    
    # Check if Anthropic API key is set
    if os.getenv("ANTHROPIC_API_KEY"):
        print("" + "=" * 80)
        print("Testing with Anthropic")
        print("=" * 80)
        
        for difficulty in difficulties:
            print(f"--- {difficulty} Dataset ---")
            test_data = load_test_data(dataset_path, difficulty)
            
            if not test_data:
                print(f"No test data found for {difficulty}")
                continue
            
            print(f"Loaded {len(test_data)} questions from {difficulty}.tsv")
            
            accuracy, correct, total, results = evaluate_accuracy(test_data, provider="anthropic")
            
            print(f"{difficulty} Results:")
            print(f"  Accuracy: {accuracy:.2%} ({correct}/{total})")
            
            # Print incorrect predictions
            incorrect = [r for r in results if not r["correct"]]
            if incorrect:
                print(f"  Incorrect predictions ({len(incorrect)}):")
                for r in incorrect[:5]:  # Show first 5 incorrect
                    print(f"    - Expected: {r['expected']}, Predicted: {r['predicted']}")
                    print(f"      Question: {r['question']}")
                if len(incorrect) > 5:
                    print(f"    ... and {len(incorrect) - 5} more")
    else:
        print("Skipping Anthropic tests: ANTHROPIC_API_KEY not set")
