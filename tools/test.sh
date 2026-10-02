#!/usr/bin/env bash
# Runs the gdUnit4 test suite headless. JUnit XML lands in build/test-results/report_1/results.xml.
#
# Usage: tools/test.sh [extra gdUnit4 args]   e.g. tools/test.sh -a res://tests/core
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# gdUnit4 resolves -rd relative to the project root.
REPORTS_REL="build/test-results"
REPORTS="$ROOT/$REPORTS_REL"
rm -rf "$REPORTS"
mkdir -p "$REPORTS"

# Import first so class_name scripts and resources are registered on a clean checkout.
"$ROOT/tools/godot.sh" --headless --import >/dev/null 2>&1 || true

args=("$@")
[[ ${#args[@]} -eq 0 ]] && args=(-a res://tests)

# --remote-debug to a closed port keeps Godot from dropping into its interactive debugger on script errors.
"$ROOT/tools/godot.sh" --headless -s -d --remote-debug tcp://127.0.0.1:0 \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  "${args[@]}" -rd "$REPORTS_REL" -rc 1 --ignoreHeadlessMode
