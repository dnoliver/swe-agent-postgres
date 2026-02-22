#!/usr/bin/env python3
"""
Check and compare results in the .output directory structure.

This script walks through .output/{seed}/{experiment}/ directories,
compares the expected answers from {experiment}.txt with the actual
answers from result.txt, and generates a detailed report with diffs.

Usage:
    python scripts/check_results.py [--output-dir .output] [--report report.txt] [--debug]
"""

import argparse
import csv
import difflib
import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import re


class ResultChecker:
    """Check and compare expected vs actual results."""

    def __init__(self, output_dir: str = ".output", debug: bool = False):
        self.output_dir = Path(output_dir)
        self.debug = debug
        self.results: List[Dict] = []
        self.total_checks = 0
        self.passed = 0
        self.failed = 0

    def normalize_answer(self, answer: str) -> str:
        """Normalize answer for comparison by removing extra whitespace."""
        return " ".join(answer.strip().split())

    def get_detailed_diff(self, expected: str, actual: str) -> str:
        """Generate a character-level diff between expected and actual."""
        diff = list(
            difflib.unified_diff(
                [expected], [actual], fromfile="expected", tofile="actual", lineterm=""
            )
        )
        return "\n".join(diff) if diff else "No differences"

    def get_character_diff(self, expected: str, actual: str) -> str:
        """Generate a more detailed character-by-character comparison."""
        matcher = difflib.SequenceMatcher(None, expected, actual)

        result = []
        for tag, i1, i2, j1, j2 in matcher.get_opcodes():
            if tag == "equal":
                continue
            elif tag == "replace":
                result.append(f"[-{repr(expected[i1:i2])}+{repr(actual[j1:j2])}]")
            elif tag == "delete":
                result.append(f"[-{repr(expected[i1:i2])}]")
            elif tag == "insert":
                result.append(f"[+{repr(actual[j1:j2])}]")

        return " ".join(result) if result else "No character differences"

    def read_expected_answer(self, filepath: Path) -> Optional[str]:
        """Read the expected answer from a CSV/TSV file."""
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                # Detect delimiter: tab first, then comma
                sample = f.read(1024)
                f.seek(0)

                if "\t" in sample:
                    delimiter = "\t"
                else:
                    delimiter = ","

                reader = csv.reader(f, delimiter=delimiter)
                rows = list(reader)

                if len(rows) < 2:
                    return None

                # First row is header, second row contains data
                # Second column (index 1) is the answer
                if len(rows[1]) >= 2:
                    return rows[1][1]
                return None
        except Exception as e:
            if self.debug:
                print(f"Error reading {filepath}: {e}", file=sys.stderr)
            return None

    def read_actual_answer(self, filepath: Path) -> Optional[str]:
        """Read the actual answer from result.txt."""
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                return f.read().strip()
        except Exception as e:
            if self.debug:
                print(f"Error reading {filepath}: {e}", file=sys.stderr)
            return None

    def read_question(self, filepath: Path) -> Optional[str]:
        """Read the question from a CSV/TSV file."""
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                # Detect delimiter: tab first, then comma
                sample = f.read(1024)
                f.seek(0)

                if "\t" in sample:
                    delimiter = "\t"
                else:
                    delimiter = ","

                reader = csv.reader(f, delimiter=delimiter)
                rows = list(reader)

                if len(rows) < 2:
                    return None

                # First row is header, second row contains data
                # First column (index 0) is the question
                if len(rows[1]) >= 1:
                    return rows[1][0]
                return None
        except Exception as e:
            if self.debug:
                print(f"Error reading {filepath}: {e}", file=sys.stderr)
            return None

    def check_experiment(
        self, seed_id: str, experiment: str, experiment_dir: Path
    ) -> Optional[Dict]:
        """Check a single experiment's results."""
        expected_file = experiment_dir / f"{experiment}.txt"
        result_file = experiment_dir / "result.txt"

        # Check if required files exist
        if not expected_file.exists():
            if self.debug:
                print(f"Missing expected file: {expected_file}", file=sys.stderr)
            return None

        if not result_file.exists():
            if self.debug:
                print(f"Missing result file: {result_file}", file=sys.stderr)
            return None

        # Read question, expected answer, and actual answer
        question = self.read_question(expected_file)
        expected_answer = self.read_expected_answer(expected_file)
        actual_answer = self.read_actual_answer(result_file)

        if question is None or expected_answer is None or actual_answer is None:
            if self.debug:
                print(f"Failed to read data from {experiment_dir}", file=sys.stderr)
            return None

        # Normalize and compare
        normalized_expected = self.normalize_answer(expected_answer)
        normalized_actual = self.normalize_answer(actual_answer)

        is_match = normalized_expected == normalized_actual

        result = {
            "seed_id": seed_id,
            "experiment": experiment,
            "question": question,
            "expected": expected_answer,
            "actual": actual_answer,
            "normalized_expected": normalized_expected,
            "normalized_actual": normalized_actual,
            "match": is_match,
            "diff": (
                self.get_detailed_diff(expected_answer, actual_answer)
                if not is_match
                else None
            ),
            "char_diff": (
                self.get_character_diff(expected_answer, actual_answer)
                if not is_match
                else None
            ),
        }

        return result

    def run_checks(self) -> None:
        """Run checks on all experiments in the output directory."""
        if not self.output_dir.exists():
            print(
                f"Error: Output directory {self.output_dir} does not exist",
                file=sys.stderr,
            )
            sys.exit(1)

        # Walk through seed directories
        for seed_dir in sorted(self.output_dir.iterdir()):
            if not seed_dir.is_dir() or not seed_dir.name.startswith("seed-"):
                continue

            seed_id = seed_dir.name

            # Walk through experiment directories
            for experiment_dir in sorted(seed_dir.iterdir()):
                if not experiment_dir.is_dir():
                    continue

                experiment = experiment_dir.name

                # Check this experiment
                result = self.check_experiment(seed_id, experiment, experiment_dir)
                if result:
                    self.results.append(result)
                    self.total_checks += 1
                    if result["match"]:
                        self.passed += 1
                    else:
                        self.failed += 1

    def generate_report(self, output_file: Optional[str] = None) -> str:
        """Generate a detailed report of the results."""
        lines = []

        # Header
        lines.append("=" * 80)
        lines.append("RESULTS COMPARISON REPORT")
        lines.append("=" * 80)
        lines.append("")
        lines.append(f"Total checks: {self.total_checks}")
        lines.append(f"Passed: {self.passed}")
        lines.append(f"Failed: {self.failed}")
        if self.total_checks > 0:
            lines.append(
                f"Success rate: {(self.passed / self.total_checks) * 100:.1f}%"
            )
        lines.append("")

        # Summary by seed
        lines.append("-" * 80)
        lines.append("SUMMARY BY SEED")
        lines.append("-" * 80)

        seeds = {}
        for result in self.results:
            seed_id = result["seed_id"]
            if seed_id not in seeds:
                seeds[seed_id] = {"total": 0, "passed": 0, "failed": 0}
            seeds[seed_id]["total"] += 1
            if result["match"]:
                seeds[seed_id]["passed"] += 1
            else:
                seeds[seed_id]["failed"] += 1

        for seed_id in sorted(seeds.keys()):
            stats = seeds[seed_id]
            lines.append(
                f"{seed_id}: {stats['passed']}/{stats['total']} passed "
                f"({(stats['passed'] / stats['total']) * 100:.1f}%)"
            )

        lines.append("")

        # Summary by experiment
        lines.append("-" * 80)
        lines.append("SUMMARY BY EXPERIMENT")
        lines.append("-" * 80)

        experiments = {}
        for result in self.results:
            exp = result["experiment"]
            if exp not in experiments:
                experiments[exp] = {"total": 0, "passed": 0, "failed": 0}
            experiments[exp]["total"] += 1
            if result["match"]:
                experiments[exp]["passed"] += 1
            else:
                experiments[exp]["failed"] += 1

        for exp in sorted(experiments.keys()):
            stats = experiments[exp]
            lines.append(
                f"{exp}: {stats['passed']}/{stats['total']} passed "
                f"({(stats['passed'] / stats['total']) * 100:.1f}%)"
            )

        lines.append("")

        # Detailed failures
        if self.failed > 0:
            lines.append("=" * 80)
            lines.append("DETAILED FAILURES")
            lines.append("=" * 80)
            lines.append("")

            for result in self.results:
                if not result["match"]:
                    lines.append("-" * 80)
                    lines.append(
                        f"Seed: {result['seed_id']} | Experiment: {result['experiment']}"
                    )
                    lines.append("-" * 80)
                    lines.append(f"Question: {result['question']}")
                    lines.append("")
                    lines.append(f"Expected: {result['expected']}")
                    lines.append(f"Actual:   {result['actual']}")
                    lines.append("")
                    lines.append("Normalized comparison:")
                    lines.append(f"  Expected: {result['normalized_expected']}")
                    lines.append(f"  Actual:   {result['normalized_actual']}")
                    lines.append("")
                    lines.append("Character-level diff:")
                    lines.append(f"  {result['char_diff']}")
                    lines.append("")
                    if result["diff"]:
                        lines.append("Full diff:")
                        for line in result["diff"].split("\n"):
                            lines.append(f"  {line}")
                    lines.append("")

        # Successful checks
        if self.debug and self.passed > 0:
            lines.append("=" * 80)
            lines.append("SUCCESSFUL CHECKS")
            lines.append("=" * 80)
            lines.append("")

            for result in self.results:
                if result["match"]:
                    lines.append(
                        f"✓ Seed: {result['seed_id']} | Experiment: {result['experiment']}"
                    )
                    lines.append(f"  Question: {result['question'][:80]}...")
                    lines.append(f"  Answer: {result['expected'][:80]}...")
                    lines.append("")

        report = "\n".join(lines)

        # Write to file if specified
        if output_file:
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(report)
            print(f"Report written to {output_file}")

        return report

    def interactive_mode(self) -> None:
        """Run in interactive mode to explore failures."""
        print("\n" + "=" * 80)
        print("INTERACTIVE FAILURE EXPLORER")
        print("=" * 80)

        failures = [r for r in self.results if not r["match"]]

        if not failures:
            print("No failures to explore!")
            return

        print(
            f"\nFound {len(failures)} failures. Enter a number to view details, 'q' to quit."
        )
        print()

        for i, failure in enumerate(failures, 1):
            print(
                f"{i}. [{failure['seed_id']}/{failure['experiment']}] "
                f"{failure['question'][:60]}..."
            )

        while True:
            choice = input(
                "\nEnter choice (1-{}) or 'q': ".format(len(failures))
            ).strip()

            if choice.lower() == "q":
                break

            try:
                idx = int(choice) - 1
                if 0 <= idx < len(failures):
                    self.show_failure_details(failures[idx])
                else:
                    print("Invalid choice. Please try again.")
            except ValueError:
                print("Invalid input. Please enter a number or 'q'.")

    def show_failure_details(self, failure: Dict) -> None:
        """Show detailed information about a failure."""
        print("\n" + "=" * 80)
        print(f"FAILURE DETAILS: {failure['seed_id']}/{failure['experiment']}")
        print("=" * 80)
        print()
        print(f"Question:")
        print(f"  {failure['question']}")
        print()
        print(f"Expected Answer:")
        print(f"  {failure['expected']}")
        print()
        print(f"Actual Answer:")
        print(f"  {failure['actual']}")
        print()
        print("-" * 80)
        print("Character-level differences:")
        print("-" * 80)
        print(f"  {failure['char_diff']}")
        print()
        if failure["diff"]:
            print("-" * 80)
            print("Full diff:")
            print("-" * 80)
            for line in failure["diff"].split("\n"):
                print(f"  {line}")
        print()


def main():
    parser = argparse.ArgumentParser(
        description="Check and compare results in the .output directory structure"
    )
    parser.add_argument(
        "--output-dir",
        default=".output",
        help="Path to the output directory (default: .output)",
    )
    parser.add_argument(
        "--report",
        default=None,
        help="Path to write the report file (default: stdout only)",
    )
    parser.add_argument(
        "--debug", action="store_true", help="Enable debug mode with verbose output"
    )
    parser.add_argument(
        "--interactive",
        action="store_true",
        help="Run in interactive mode to explore failures",
    )

    args = parser.parse_args()

    # Create checker and run
    checker = ResultChecker(output_dir=args.output_dir, debug=args.debug)
    checker.run_checks()

    # Generate and display report
    report = checker.generate_report(output_file=args.report)
    print(report)

    # Interactive mode
    if args.interactive:
        checker.interactive_mode()

    # Exit with error code if there are failures
    sys.exit(0 if checker.failed == 0 else 1)


if __name__ == "__main__":
    main()
