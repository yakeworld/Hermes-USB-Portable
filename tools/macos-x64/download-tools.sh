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

download "opencode-openai" "https://github.com/yakeworld/opencode-openai/releases/download/v0.2.0/opencode-openai-macos-x64"
download "jabkit"          "https://github.com/yakeworld/jabkit-rs/releases/download/v0.1.1/jabkit-macos-x64"
download "doi-fetch"       "https://github.com/yakeworld/doi-fetch/releases/download/v0.1.1/doi-fetch-macos-x64"
download "rproxy"          "https://github.com/yakeworld/rproxy/releases/download/v0.3.1/rproxy-macos-x64"

# opencode CLI (opencode-ai/opencode, MIT) — npm 平台包，darwin-x64
OC_VERSION=$(curl -sL --connect-timeout 10 --max-time 20 "https://registry.npmjs.org/opencode-ai/latest" 2>/dev/null \
    | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -z "$OC_VERSION" ] && OC_VERSION="1.18.10"

download_opencode() {
    local dest="$TOOLS_DIR/opencode-cli"
    if [ -x "$dest/opencode" ]; then
        echo "  [SKIP] opencode (exists)"
        return
    fi
    echo "  [DL]   opencode CLI v$OC_VERSION ..."
    mkdir -p "$dest"
    curl -sL --connect-timeout 10 --max-time 240 -o "$TOOLS_DIR/opencode.tgz" \
        "https://registry.npmjs.org/opencode-darwin-x64/-/opencode-darwin-x64-$OC_VERSION.tgz" || {
        echo "  FAILED: opencode (download)"
        rm -f "$TOOLS_DIR/opencode.tgz"
        return
    }
    tar xzf "$TOOLS_DIR/opencode.tgz" -C "$dest" --strip-components=1 || {
        echo "  FAILED: opencode (extract)"
        rm -f "$TOOLS_DIR/opencode.tgz"
        return
    }
    rm -f "$TOOLS_DIR/opencode.tgz"
    [ -f "$dest/bin/opencode" ] && mv "$dest/bin/opencode" "$dest/opencode"
    rm -rf "$dest/bin" "$dest/package.json" "$dest/README.md" "$dest/LICENSE" 2>/dev/null || true
    chmod +x "$dest/opencode" 2>/dev/null || true
    local size=$(stat -f%z "$dest/opencode" 2>/dev/null || stat -c%s "$dest/opencode" 2>/dev/null)
    echo "  OK ($((size/1024/1024)) MB)"
}
download_opencode

echo ""
echo "Done. Tools in: $TOOLS_DIR"
