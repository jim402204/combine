#!/bin/sh
# 使用本機 Xcode 執行 xcodebuild（路徑見同目錄 xcode-path）
set -euo pipefail
CURSOR_DIR="$(cd "$(dirname "$0")" && pwd)"
export DEVELOPER_DIR="$(cat "$CURSOR_DIR/xcode-path")/Contents/Developer"
exec "$DEVELOPER_DIR/usr/bin/xcodebuild" "$@"
