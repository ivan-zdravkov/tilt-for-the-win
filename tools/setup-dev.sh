#!/usr/bin/env bash
# Installs the local toolchain for Tilt for the Win: Godot (editor + export templates),
# JDK 17 and the Android SDK. Everything is installed under $HOME (no root, works on immutable distros
# like Bazzite). Safe to re-run: already-installed pieces are skipped.
#
# Usage: tools/setup-dev.sh
set -euo pipefail

# Keep these in sync with .github/workflows (the CI uses the same versions).
GODOT_VERSION="4.7.2"
ANDROID_PLATFORM="android-35"
ANDROID_BUILD_TOOLS="35.0.1"
ANDROID_NDK="28.1.13356709"
ANDROID_CMAKE="3.10.2.4988404"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-13114758_latest.zip"

OPT="$HOME/.local/opt"
BIN="$HOME/.local/bin"
GODOT_DIR="$OPT/godot/$GODOT_VERSION"
TEMPLATES_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
JDK_DIR="$OPT/jdk-17"
ANDROID_SDK="$OPT/android-sdk"
KEYSTORE_DIR="$HOME/.local/share/godot/keystores"
GODOT_RELEASE_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable"

mkdir -p "$OPT" "$BIN"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
log() { printf '\n==> %s\n' "$*"; }

# --- Godot editor ---------------------------------------------------------------------------------
if [[ ! -x "$GODOT_DIR/godot" ]]; then
  log "Installing Godot $GODOT_VERSION"
  curl -fL --progress-bar -o "$tmp/godot.zip" "$GODOT_RELEASE_URL/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
  mkdir -p "$GODOT_DIR"
  unzip -q "$tmp/godot.zip" -d "$tmp/godot"
  mv "$tmp/godot/Godot_v${GODOT_VERSION}-stable_linux.x86_64" "$GODOT_DIR/godot"
  chmod +x "$GODOT_DIR/godot"
else
  log "Godot $GODOT_VERSION already installed"
fi
ln -sf "$GODOT_DIR/godot" "$BIN/godot"

# Desktop entry so Godot shows up in the app menu.
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/godot.desktop" <<EOF
[Desktop Entry]
Name=Godot Engine $GODOT_VERSION
Exec=$GODOT_DIR/godot %f
Icon=applications-games
Type=Application
Categories=Development;IDE;
EOF

# --- Export templates (Android + iOS + Linux, ~1 GB) ---------------------------------------------
if [[ ! -f "$TEMPLATES_DIR/version.txt" ]]; then
  log "Installing Godot $GODOT_VERSION export templates"
  curl -fL --progress-bar -o "$tmp/templates.tpz" "$GODOT_RELEASE_URL/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
  unzip -q "$tmp/templates.tpz" -d "$tmp/tpl"
  mkdir -p "$TEMPLATES_DIR"
  mv "$tmp/tpl/templates/"* "$TEMPLATES_DIR/"
else
  log "Export templates already installed"
fi

# --- JDK 17 (Eclipse Temurin) ----------------------------------------------------------------------
if [[ ! -x "$JDK_DIR/bin/java" ]]; then
  log "Installing Temurin JDK 17"
  curl -fL --progress-bar -o "$tmp/jdk.tar.gz" \
    "https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jdk/hotspot/normal/eclipse"
  mkdir -p "$JDK_DIR"
  tar -xzf "$tmp/jdk.tar.gz" -C "$JDK_DIR" --strip-components=1
else
  log "JDK 17 already installed"
fi
export JAVA_HOME="$JDK_DIR"

# --- Android SDK -----------------------------------------------------------------------------------
SDKMANAGER="$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager"
if [[ ! -x "$SDKMANAGER" ]]; then
  log "Installing Android command-line tools"
  curl -fL --progress-bar -o "$tmp/cmdline.zip" "https://dl.google.com/android/repository/$CMDLINE_TOOLS_ZIP"
  unzip -q "$tmp/cmdline.zip" -d "$tmp/cmdline"
  mkdir -p "$ANDROID_SDK/cmdline-tools"
  rm -rf "$ANDROID_SDK/cmdline-tools/latest"
  mv "$tmp/cmdline/cmdline-tools" "$ANDROID_SDK/cmdline-tools/latest"
fi
log "Installing Android SDK packages (accepting licenses)"
yes | "$SDKMANAGER" --sdk_root="$ANDROID_SDK" --licenses >/dev/null || true
"$SDKMANAGER" --sdk_root="$ANDROID_SDK" \
  "platform-tools" "build-tools;$ANDROID_BUILD_TOOLS" "platforms;$ANDROID_PLATFORM" \
  "cmdline-tools;latest" "cmake;$ANDROID_CMAKE" "ndk;$ANDROID_NDK"
ln -sf "$ANDROID_SDK/platform-tools/adb" "$BIN/adb"

# --- Debug keystore (local debug builds only; the release keystore never lives on disk in the repo) -
mkdir -p "$KEYSTORE_DIR"
if [[ ! -f "$KEYSTORE_DIR/debug.keystore" ]]; then
  log "Creating Android debug keystore"
  "$JDK_DIR/bin/keytool" -genkeypair -v -keystore "$KEYSTORE_DIR/debug.keystore" \
    -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 \
    -validity 10000 -dname "CN=Android Debug,O=Android,C=US" >/dev/null 2>&1
fi

# --- Point the Godot editor at the SDKs --------------------------------------------------------------
GODOT_CONFIG="$HOME/.config/godot"
SETTINGS="$GODOT_CONFIG/editor_settings-${GODOT_VERSION%.*}.tres"
mkdir -p "$GODOT_CONFIG"
[[ -f "$SETTINGS" ]] || printf '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n' > "$SETTINGS"
set_setting() {
  local key="$1" value="$2"
  if grep -q "^$key = " "$SETTINGS"; then
    sed -i "s|^$key = .*|$key = $value|" "$SETTINGS"
  else
    echo "$key = $value" >> "$SETTINGS"
  fi
}
set_setting "export/android/java_sdk_path" "\"$JDK_DIR\""
set_setting "export/android/android_sdk_path" "\"$ANDROID_SDK\""
set_setting "export/android/debug_keystore" "\"$KEYSTORE_DIR/debug.keystore\""
set_setting "export/android/debug_keystore_user" "\"androiddebugkey\""
set_setting "export/android/debug_keystore_pass" "\"android\""

log "Done"
"$BIN/godot" --version
"$JDK_DIR/bin/java" -version 2>&1 | head -1
echo "Android SDK: $ANDROID_SDK"
echo "Run 'godot' or launch 'Godot Engine $GODOT_VERSION' from the app menu."
