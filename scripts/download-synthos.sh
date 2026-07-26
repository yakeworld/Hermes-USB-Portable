#!/bin/bash
set -e
SYNTHOS_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)/Synthos}"
if [ -f "$SYNTHOS_DIR/SKILL.md" ]; then
    echo "  [SKIP] Synthos already exists at $SYNTHOS_DIR"
    exit 0
fi
echo "  [DL]   Downloading Synthos cognitive engine ..."
if command -v git &>/dev/null; then
    git clone --depth 1 https://github.com/yakeworld/Synthos.git "$SYNTHOS_DIR"
elif command -v curl &>/dev/null; then
    curl -sL --connect-timeout 10 --max-time 120 -o /tmp/synthos.zip \
        "https://github.com/yakeworld/Synthos/archive/refs/heads/main.zip"
    unzip -q /tmp/synthos.zip -d /tmp/
    [ -d "$SYNTHOS_DIR" ] && rm -rf "$SYNTHOS_DIR"
    mv /tmp/Synthos-main "$SYNTHOS_DIR"
else
    echo "[ERR] Neither git nor curl available"
    exit 1
fi
if [ -f "$SYNTHOS_DIR/SKILL.md" ]; then
    echo "  [OK]   Synthos ready ($SYNTHOS_DIR)"
else
    echo "  [ERR]  Synthos download failed"
    exit 1
fi
