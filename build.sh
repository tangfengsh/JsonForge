#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${ROOT_DIR}/dist"
mkdir -p "$OUTPUT_DIR"

case "$(uname -s)" in
  Darwin)
    ARCH="$(uname -m)"
    case "$ARCH" in
      arm64) TARGET="arm64" ;;
      x86_64) TARGET="amd64" ;;
      *) echo "Unsupported macOS architecture: $ARCH" >&2; exit 1 ;;
    esac
    APP_DIR="$OUTPUT_DIR/JsonForge.app"
    mkdir -p "$APP_DIR/Contents/MacOS"
    CGO_ENABLED=1 GOOS=darwin GOARCH="$TARGET" go build -trimpath -ldflags='-s -w' \
      -o "$APP_DIR/Contents/MacOS/JsonForge" "$ROOT_DIR"
    cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>JsonForge</string>
  <key>CFBundleIdentifier</key>
  <string>cn.jsonforge.app</string>
  <key>CFBundleName</key>
  <string>JSON Forge</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleVersion</key>
  <string>1.0.0</string>
</dict>
</plist>
PLIST
    ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$OUTPUT_DIR/JsonForge-macos-${TARGET}.zip"
    ;;
  Linux)
    ARCH="$(uname -m)"
    case "$ARCH" in
      aarch64) TARGET="arm64" ;;
      x86_64) TARGET="amd64" ;;
      *) echo "Unsupported Linux architecture: $ARCH" >&2; exit 1 ;;
    esac
    CGO_ENABLED=1 GOOS=linux GOARCH="$TARGET" go build -trimpath -o "$OUTPUT_DIR/JsonForge-linux-${TARGET}" "$ROOT_DIR"
    ;;
  *)
    echo 'Run this script on macOS or Linux.' >&2
    exit 1
    ;;
esac

echo "Built ${TARGET} package in ${OUTPUT_DIR}"
