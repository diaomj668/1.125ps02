#!/bin/bash
# Coordinate operations; UI handles prompts and the database owns storage.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
command=${1:-list}
[ "$#" -eq 0 ] || shift
case "$command" in
  list) "$ROOT/data/book_database.sh" list;;
  search) "$ROOT/books/search_books.sh" "$@";;
  metadata) "$ROOT/books/fetch_book_metadata.sh" "$@";;
  save)
    [ "$#" -eq 5 ] || { echo 'Usage: save TITLE AUTHOR GENRE STATUS LINK' >&2; exit 1; }
    "$ROOT/data/book_database.sh" add "$1" "$2" "$3" "$4" 0 "$5";;
  add)
    [ "$#" -eq 4 ] || { echo 'Usage: add TITLE AUTHOR GENRE STATUS' >&2; exit 1; }
    metadata=$("$ROOT/books/fetch_book_metadata.sh" "$1" "$2")
    genre=$(printf '%s\n' "$metadata" | cut -f3)
    link=$(printf '%s\n' "$metadata" | cut -f5)
    [ -z "$3" ] || genre=$3
    "$ROOT/data/book_database.sh" add "$1" "$2" "$genre" "$4" 0 "$link";;
  update) "$ROOT/data/book_database.sh" update "$@";;
  *) echo "Unknown library action: $command" >&2; exit 1;;
esac
