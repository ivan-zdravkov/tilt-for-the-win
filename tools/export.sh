#!/usr/bin/env bash
# Exports a build with the pinned Godot version.
#
# Usage: tools/export.sh android-debug     -> build/android/tilt-for-the-win-debug.apk
#        tools/export.sh android-release   -> build/android/tilt-for-the-win.aab  (needs GODOT_ANDROID_KEYSTORE_RELEASE_*)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:-}"

case "$target" in
  android-debug)
    out="build/android/tilt-for-the-win-debug.apk"
    mode="--export-debug"; preset="Android" ;;
  android-release)
    out="build/android/tilt-for-the-win.aab"
    mode="--export-release"; preset="Android" ;;
  *)
    echo "Usage: $0 android-debug|android-release" >&2
    exit 2 ;;
esac

mkdir -p "$ROOT/$(dirname "$out")"
"$ROOT/tools/godot.sh" --headless --import >/dev/null 2>&1 || true
"$ROOT/tools/godot.sh" --headless "$mode" "$preset" "$ROOT/$out"
ls -lh "$ROOT/$out"
