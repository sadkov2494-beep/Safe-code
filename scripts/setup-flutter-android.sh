#!/usr/bin/env bash
set -euo pipefail

FLUTTER_HOME="${FLUTTER_HOME:-$HOME/sdks/flutter}"
ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
ANDROID_CMDLINE_TOOLS_URL="${ANDROID_CMDLINE_TOOLS_URL:-https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip}"

export ANDROID_HOME
export ANDROID_SDK_ROOT
export PATH="$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

ensure_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

ensure_command curl
ensure_command tar
ensure_command unzip
ensure_command python3
ensure_command java

install_flutter() {
  if [[ -x "$FLUTTER_HOME/bin/flutter" ]]; then
    echo "Flutter already installed at $FLUTTER_HOME"
    "$FLUTTER_HOME/bin/flutter" --version
    return
  fi

  echo "Resolving current Flutter stable Linux archive..."
  local releases_json archive_url tmp_archive
  releases_json="$(mktemp)"
  tmp_archive="$(mktemp --suffix=.tar.xz)"
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json" -o "$releases_json"
  archive_url="$(
    python3 - "$releases_json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as file:
    data = json.load(file)

stable_hash = data["current_release"]["stable"]
release = next(item for item in data["releases"] if item["hash"] == stable_hash)
print(f'{data["base_url"]}/{release["archive"]}')
PY
  )"

  echo "Downloading Flutter from $archive_url"
  mkdir -p "$(dirname "$FLUTTER_HOME")"
  curl -fL "$archive_url" -o "$tmp_archive"
  tar -xf "$tmp_archive" -C "$(dirname "$FLUTTER_HOME")"
  "$FLUTTER_HOME/bin/flutter" --version
}

install_android_sdk() {
  local sdkmanager="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"

  if [[ ! -x "$sdkmanager" ]]; then
    echo "Installing Android command-line tools..."
    local tmp_zip tmp_dir
    tmp_zip="$(mktemp --suffix=.zip)"
    tmp_dir="$(mktemp -d)"
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    curl -fL "$ANDROID_CMDLINE_TOOLS_URL" -o "$tmp_zip"
    unzip -q "$tmp_zip" -d "$tmp_dir"
    rm -rf "$ANDROID_HOME/cmdline-tools/latest"
    mv "$tmp_dir/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
  else
    echo "Android command-line tools already installed at $ANDROID_HOME"
  fi

  echo "Accepting Android SDK licenses..."
  yes | "$sdkmanager" --sdk_root="$ANDROID_HOME" --licenses >/dev/null || true

  echo "Installing Android SDK packages required by Flutter APK builds..."
  "$sdkmanager" --sdk_root="$ANDROID_HOME" \
    "platform-tools" \
    "platforms;android-36" \
    "build-tools;36.0.0"
}

install_path_shims() {
  local shim_dir="$HOME/.local/bin"

  if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    shim_dir="/usr/local/bin"
    sudo ln -sf "$FLUTTER_HOME/bin/flutter" "$shim_dir/flutter"
    sudo ln -sf "$FLUTTER_HOME/bin/dart" "$shim_dir/dart"
  else
    mkdir -p "$shim_dir"
    ln -sf "$FLUTTER_HOME/bin/flutter" "$shim_dir/flutter"
    ln -sf "$FLUTTER_HOME/bin/dart" "$shim_dir/dart"
  fi

  export PATH="$shim_dir:$PATH"
}

write_profile_exports() {
  local profile="$HOME/.bashrc"
  local marker="# Safe Code Flutter Android SDK setup"

  if [[ -f "$profile" ]] && grep -Fq "$marker" "$profile"; then
    return
  fi

  {
    echo ""
    echo "$marker"
    echo "export FLUTTER_HOME=\"$FLUTTER_HOME\""
    echo "export ANDROID_HOME=\"$ANDROID_HOME\""
    echo "export ANDROID_SDK_ROOT=\"$ANDROID_SDK_ROOT\""
    echo "export PATH=\"\$FLUTTER_HOME/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH\""
  } >>"$profile"
}

install_flutter
install_android_sdk
install_path_shims
"$FLUTTER_HOME/bin/flutter" config --android-sdk "$ANDROID_HOME"
write_profile_exports

echo "Running flutter doctor..."
"$FLUTTER_HOME/bin/flutter" doctor -v

echo ""
echo "Environment ready. Build the APK with:"
echo "  cd Safe-code && flutter build apk --debug"
