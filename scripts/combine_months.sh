#!/bin/bash
# Combine all monthly A&E CSV files in data/raw into a single file.
# Usage (run from the project folder): bash scripts/combine_months.sh

set -e

mkdir -p data/processed
output="data/processed/ae_all_months.csv"

# 1. Check that every monthly file has the same column headers
header_count=$(for f in data/raw/ae_*.csv; do head -1 "$f"; done | tr -d '\r' | sort -u | wc -l | tr -d ' ')
if [ "$header_count" -ne 1 ]; then
  echo "WARNING: column headers are not the same in all files. Check before using the output."
fi

# 2. Keep the header from the first file only, then append the data rows from every file
awk 'FNR==1 && NR!=1 {next} {print}' data/raw/ae_*.csv > "$output"

# 3. Print a short summary
file_count=$(ls data/raw/ae_*.csv | wc -l | tr -d ' ')
row_count=$(( $(wc -l < "$output") - 1 ))
echo "Combined $file_count monthly files into $output"
echo "Data rows (excluding header): $row_count"
