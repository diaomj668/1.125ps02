#!/bin/bash
# Input: title, author, genre, strategy, reason, link. Output column 4: votes.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/candidates"
"$ROOT/data/book_database.sh" list > "$tmp/library"
# Count each strategy once per book. Keep ties in original candidate order.
awk -F '\t' -v library="$tmp/library" 'BEGIN {OFS="\t"}
function clean(s) {gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return tolower(s)}
FILENAME==library {owned[clean($1) SUBSEP clean($2)]=1; next}
NF==6 && ($4=="history" || $4=="interests" || $4=="discovery") {
 key=clean($1) SUBSEP clean($2)
 if (key in owned) next
 if (!(key in title)) {title[key]=$1; author[key]=$2; genre[key]=$3; link[key]=$6; order[key]=++n}
 if (!seen[key SUBSEP $4]++) {votes[key]++; reasons[key]=reasons[key] (reasons[key]!="" ? "; " : "") $4 ": " $5}
}
END {for(key in title) print votes[key],order[key],title[key],author[key],genre[key],reasons[key],link[key]}
' "$tmp/library" "$tmp/candidates" |
  sort -t $'\t' -k1,1nr -k2,2n |
  awk -F '\t' 'BEGIN {OFS="\t"} NR<=6 {print $3,$4,$5,$1,$6,$7}'
