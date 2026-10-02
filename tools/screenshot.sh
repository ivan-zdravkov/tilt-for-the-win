#!/usr/bin/env bash
# Saves a screenshot of a scene (needs a desktop session; runs a real window for a moment).
#
# Usage: tools/screenshot.sh res://scenes/board/board.tscn /tmp/board.png [frames]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ $# -ge 2 ]] || { echo "Usage: $0 <res://scene.tscn> <out.png> [frames]" >&2; exit 2; }
out="$(realpath -m "$2")"
"$ROOT/tools/godot.sh" -s res://tools/screenshot.gd ++ "$1" "$out" "${3:-20}"
echo "$out"
