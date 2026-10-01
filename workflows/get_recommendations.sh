#!/bin/bash
# stdout is data; stderr is progress. Each agent gets a separate output file.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
[ "$#" -eq 1 ] || { echo 'Usage: get_recommendations.sh TOPIC' >&2; exit 1; }
[ -n "$(printf '%s' "$1" | tr -d '[:space:]')" ] || { echo 'Topic cannot be empty.' >&2; exit 1; }
tmp=$(mktemp -d)
pids=()
cleanup() {
  for pid in "${pids[@]+"${pids[@]}"}"; do kill "$pid" 2>/dev/null || true; done
  rm -rf "$tmp"
}
trap cleanup EXIT
trap 'exit 130' INT TERM
names=(history interests discovery)
for name in "${names[@]}"; do
  case "$name" in
    history) script=recommend_from_history;;
    interests) script=recommend_from_interests;;
    discovery) script=recommend_for_discovery;;
  esac
  "$ROOT/recommendations/$script.sh" "$1" > "$tmp/$name" &
  pids+=("$!")
  printf '%s: running (PID %s)\n' "$name" "$!" >&2
done
for i in 0 1 2; do
  if wait "${pids[$i]}"; then
    printf '%s: done\n' "${names[$i]}" >&2
  else
    printf '%s: failed\n' "${names[$i]}" >&2
    exit 1
  fi
done
pids=()
cat "$tmp/history" "$tmp/interests" "$tmp/discovery" |
  "$ROOT/recommendations/refine_recommendations.sh"
