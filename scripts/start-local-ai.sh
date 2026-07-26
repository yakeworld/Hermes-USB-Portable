#!/bin/bash
# ============================================================================
# Start Local AI (opencode-openai) - Portable Launcher (Unix)
# ============================================================================
set -e

PORTABLE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux*)  PLATFORM="linux" ;;
    Darwin*) PLATFORM="macos" ;;
    *)       echo "[ERROR] Unsupported: $OS"; exit 1 ;;
esac

case "$ARCH" in
    x86_64|amd64) ARCH_DIR="x64" ;;
    aarch64|arm64) ARCH_DIR="arm64" ;;
    *) echo "[ERROR] Unsupported arch: $ARCH"; exit 1 ;;
esac

TOOLS_DIR="$PORTABLE_ROOT/tools/${PLATFORM}-${ARCH_DIR}"
OPENCODE_EXE="$TOOLS_DIR/opencode-openai"

if [ ! -f "$OPENCODE_EXE" ]; then
    echo "  [TOOLS] opencode-openai not found."
    echo "  [TOOLS] Run tools/${PLATFORM}-${ARCH_DIR}/download-tools.sh first."
    exit 1
fi

# Check if already running
if pgrep -f "opencode-openai" >/dev/null 2>&1; then
    echo "  [AI]    opencode-openai already running"
    echo "  [AI]    http://127.0.0.1:8787/v1"
    exit 0
fi

echo "  [AI]    Starting opencode-openai ..."
echo "  [AI]    Port:     8787"
echo "  [AI]    API Key:  public (free models)"
echo "  [AI]    Endpoint: http://127.0.0.1:8787/v1"

"$OPENCODE_EXE" --port 8787 --api-key public &
OPENCODE_PID=$!

# Wait for server
echo "  [AI]    Waiting for server ..."
for i in $(seq 1 10); do
    if curl -s --connect-timeout 2 -m 3 "http://127.0.0.1:8787/health" >/dev/null 2>&1; then
        echo "  [OK]    opencode-openai is ready! (PID $OPENCODE_PID)"
        echo "  [AI]    http://127.0.0.1:8787/v1"
        exit 0
    fi
    sleep 1
done
echo "  [WARN]  Server start may be in progress."
