#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${ROOT_DIR}/dist"
ARCHITECTURE="${1:-all}"

if ! command -v docker >/dev/null 2>&1; then
  echo 'Docker is required.' >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo 'Docker daemon is not running.' >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
case "$ARCHITECTURE" in
  all) ARCHITECTURES=(amd64 arm64) ;;
  amd64|arm64) ARCHITECTURES=("$ARCHITECTURE") ;;
  *) echo 'Usage: ./build-linux-docker.sh [all|amd64|arm64]' >&2; exit 1 ;;
esac

for arch in "${ARCHITECTURES[@]}"; do
  destination="$OUTPUT_DIR/linux-$arch"
  mkdir -p "$destination"
  docker buildx build \
    --platform "linux/$arch" \
    --file "$ROOT_DIR/Dockerfile.linux" \
    --target artifact \
    --output "type=local,dest=$destination" \
    "$ROOT_DIR"
done

echo "Linux binaries exported to $OUTPUT_DIR"
echo 'The target machine still needs GTK3 and WebKitGTK runtime packages.'
