# SymCode Error Analysis

The `symcode-errors.txt` file was produced using the following command:

```bash
jq -r '
  select(.symcode_exit_code != 0)
  | {key, raw_output, symcode_stderr}
  | "====================\nKEY: \(.key)\n\nRAW OUTPUT:\n\(.raw_output)\n\nSTDERR:\n\(.symcode_stderr)\n"
' \
external/nsum/results/gpt-5-nano-2025-08-07/Easy/SymCode.jsonl \
> symcode-errors.txt
```

The `symcode-analysis.txt` file has explanation of those errors.
