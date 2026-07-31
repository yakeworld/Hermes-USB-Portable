#!/bin/bash
set -e
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"

download() {
    local name="$1" url="$2"
    local path="$TOOLS_DIR/$name"
    if [ -f "$path" ]; then
        echo "  [SKIP] $name (exists)"
        return
    fi
    echo "  [DL]   $name ..."
    curl -sL --connect-timeout 10 --max-time 120 -o "$path" "$url" || {
        echo "  FAILED: $name"
        return
    }
    chmod +x "$path"
    local size=$(stat -c%s "$path" 2>/dev/null || stat -f%z "$path" 2>/dev/null)
    echo "  OK ($((size/1024/1024)) MB)"
}

download "opencode-openai" "https://github.com/yakeworld/opencode-openai/releases/download/v0.2.1/opencode-openai"
download "jabkit"          "https://github.com/yakeworld/jabkit-rs/releases/download/v0.1.0/jabkit-linux-x86_64"
download "doi-fetch"       "https://github.com/yakeworld/doi-fetch/releases/download/v0.1.0/doi-fetch-linux-x86_64"
download "rproxy"          "https://github.com/yakeworld/rproxy/releases/download/v0.3.0/rproxy-linux-x86_64"

echo ""
echo "Done. Tools in: $TOOLS_DIR"
