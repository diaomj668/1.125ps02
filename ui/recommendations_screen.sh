#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
topic=$(gum input --placeholder 'Enter any book topic or reading goal (Esc cancels)') || exit 0
results=$("$ROOT/workflows/get_recommendations.sh" "$topic")
[ -n "$results" ] || { echo 'Codex returned no new books after filtering your library. Try a more specific topic.'; exit 0; }
echo 'Select a book to save (Esc cancels). Columns: title, author, genre, strategy votes, reason, link.'
options=()
    while IFS= read -r row; do options+=("$row"); done <<< "$results"
    selected=$(gum choose "${options[@]}") || exit 0
title=$(printf '%s\n' "$selected" | cut -f1)
author=$(printf '%s\n' "$selected" | cut -f2)
genre=$(printf '%s\n' "$selected" | cut -f3)
if gum confirm "Save $title to your reading list?"; then
  "$ROOT/workflows/manage_library.sh" save "$title" "$author" "$genre" want-to-read "$(printf '%s\n' "$selected" | cut -f6)"
  echo 'Recommendation saved.'
fi
