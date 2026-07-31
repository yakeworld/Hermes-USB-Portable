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

download "opencode-openai" "https://github.com/yakeworld/opencode-openai/releases/latest/download/opencode-openai"
download "jabkit"          "https://github.com/yakeworld/jabkit-rs/releases/latest/download/jabkit-linux-x86_64"
download "doi-fetch"       "https://github.com/yakeworld/doi-fetch/releases/latest/download/doi-fetch-linux-x86_64"
download "rproxy"          "https://github.com/yakeworld/rproxy/releases/latest/download/rproxy-linux-x86_64"

# ---------------------------------------------------------------------------
# opencode CLI (opencode-ai/opencode, MIT) — 从 npm 平台包下载单二进制
# 版本动态获取，失败回退固定版本。解压后顶层为 $TOOLS_DIR/opencode-cli/opencode
# ---------------------------------------------------------------------------
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
        "https://registry.npmjs.org/opencode-linux-x64/-/opencode-linux-x64-$OC_VERSION.tgz" || {
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
    local size=$(stat -c%s "$dest/opencode" 2>/dev/null || stat -f%z "$dest/opencode" 2>/dev/null)
    echo "  OK ($((size/1024/1024)) MB)"
}
download_opencode

echo ""
echo "Done. Tools in: $TOOLS_DIR"
