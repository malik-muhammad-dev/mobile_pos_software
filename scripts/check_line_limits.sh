#!/usr/bin/env bash
# Fails CI if any file under lib/ grows past the 200-line convention.
# A file over the limit gets split by responsibility, not trimmed by
# deleting comments.
set -euo pipefail

LIMIT=200
FAILED=0

while IFS= read -r -d '' file; do
  lines=$(wc -l < "$file")
  if [ "$lines" -gt "$LIMIT" ]; then
    echo "FAIL: $file has $lines lines (limit $LIMIT)"
    FAILED=1
  fi
done < <(find lib -name '*.dart' -print0)

if [ "$FAILED" -eq 1 ]; then
  echo ""
  echo "One or more files exceed the $LIMIT-line limit. Split by responsibility."
  exit 1
fi

echo "All lib/ files are within the $LIMIT-line limit."