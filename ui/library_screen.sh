#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
workflow="$ROOT/workflows/manage_library.sh"
action=${1:-list}
case "$action" in
  list|search)
    if [ "$action" = search ]; then
      term=$(gum input --placeholder 'Search title, author, genre or status') || exit 0
      rows=$("$workflow" search "$term")
    else rows=$("$workflow" list); fi
    if [ -z "$rows" ]; then echo 'No books found. Add your first book from the menu.'; exit 0; fi
    printf 'TITLE | AUTHOR | GENRE | STATUS | RATING (0 = unrated) | LINK\n'
    printf '%s\n' "$rows" | sed $'s/\t/ | /g';;
  add)
    title=$(gum input --placeholder 'Book title (required)') || exit 0
    author=$(gum input --placeholder 'Author (required)') || exit 0
    [ -n "$title" ] && [ -n "$author" ] || { echo 'Title and author are required.'; exit 1; }
    metadata=$("$workflow" metadata "$title" "$author")
    printf 'Codex metadata: %s\n' "$metadata"
    genre=$(gum input --value "$(printf '%s\n' "$metadata" | cut -f3)" --placeholder 'Genre') || exit 0
    status=$(gum choose want-to-read owned reading finished) || exit 0
    "$workflow" save "$title" "$author" "$genre" "$status" "$(printf '%s\n' "$metadata" | cut -f5)"
    echo 'Book saved.';;
  update)
    rows=$("$workflow" list)
    [ -n "$rows" ] || { echo 'Your library is empty.'; exit 0; }
    options=()
    while IFS= read -r row; do options+=("$row"); done <<< "$rows"
    selected=$(gum choose "${options[@]}") || exit 0
    title=$(printf '%s\n' "$selected" | cut -f1)
    author=$(printf '%s\n' "$selected" | cut -f2)
    field=$(gum choose status rating) || exit 0
    if [ "$field" = status ]; then value=$(gum choose want-to-read owned reading finished) || exit 0
    else value=$(gum choose 0 1 2 3 4 5) || exit 0; fi
    "$workflow" update "$title" "$author" "$field" "$value"
    echo 'Book updated.';;
esac
