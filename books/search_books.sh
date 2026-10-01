#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
term=${1:-}
if [ "$#" -eq 0 ]; then IFS= read -r term || [ -n "$term" ]; fi
exec "$ROOT/data/book_database.sh" search "$term"
