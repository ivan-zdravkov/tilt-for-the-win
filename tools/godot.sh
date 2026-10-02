#!/usr/bin/env bash
# Runs the pinned Godot version against this project, the same way locally and in CI.
# Uses $GODOT_BIN if set, otherwise `godot` from PATH, and refuses to run with a different version.
#
# Usage: tools/godot.sh [godot args...]      e.g. tools/godot.sh --headless --import
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=versions.env
source "$ROOT/tools/versions.env"

GODOT_BIN="${GODOT_BIN:-$(command -v godot || true)}"
if [[ -z "$GODOT_BIN" ]]; then
  echo "Godot not found. Run tools/setup-dev.sh or set GODOT_BIN." >&2
  exit 1
fi

# `godot --version` prints e.g. 4.7.2.stable.official.<hash>; x.y.0 releases print 4.7.stable...
expected="${GODOT_VERSION%.0}.stable"
actual="$("$GODOT_BIN" --version)"
if [[ "$actual" != "$expected"* ]]; then
  echo "Expected Godot $GODOT_VERSION but $GODOT_BIN is $actual. Run tools/setup-dev.sh." >&2
  exit 1
fi

exec "$GODOT_BIN" --path "$ROOT" "$@"
