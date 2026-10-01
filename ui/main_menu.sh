#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
while true; do
  # A compact header that adapts to the available terminal width.
  columns=$(tput cols 2>/dev/null || printf '80')
  width=$((columns - 8))
  [ "$width" -le 58 ] || width=58
  [ "$width" -ge 20 ] || width=20
  printf '\n'
  label=$(gum style --foreground 30 --bold 'THE READING ROOM')
  title=$(gum style --bold 'Personal Book Manager')
  subtitle=$(gum style --foreground 245 'Your library. Your next great read.')
  gum style --border rounded --border-foreground 30 \
    --padding '1 2' --margin '0 1' --width "$width" \
    "$label" '' "$title" "$subtitle"
  gum style --foreground 245 --margin '0 3' 'COLLECT  /  EXPLORE  /  DISCOVER'
  printf '\n'
  choice=$(gum choose --header '  What would you like to do?' \
    --header.foreground 30 --cursor.foreground 30 \
    --selected.foreground 30 --cursor '  > ' --padding '0 2' \
    --height 6 \
    'Browse Library' 'Add Book' 'Search Library' \
    'Update Status / Rating' 'Get Recommendations' 'Quit') || exit 0
  case "$choice" in
    'Browse Library') "$ROOT/ui/library_screen.sh" list || echo 'Operation failed.';;
    'Add Book') "$ROOT/ui/library_screen.sh" add || echo 'Operation failed.';;
    'Search Library') "$ROOT/ui/library_screen.sh" search || echo 'Operation failed.';;
    'Update Status / Rating') "$ROOT/ui/library_screen.sh" update || echo 'Operation failed.';;
    'Get Recommendations') "$ROOT/ui/recommendations_screen.sh" || echo 'Recommendations failed.';;
    Quit) exit 0;;
  esac
  gum input --placeholder 'Press Enter to return to menu' >/dev/null || exit 0
done
