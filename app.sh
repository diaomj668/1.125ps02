#!/bin/bash
# Keep the entry point small: check dependencies and open the UI.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
for tool in gum python3; do
  command -v "$tool" >/dev/null || { echo "Missing $tool. Install with: brew install $tool" >&2; exit 1; }
done
exec "$ROOT/ui/main_menu.sh"
