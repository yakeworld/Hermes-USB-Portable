#!/bin/bash
# ============================================================================
# install-omo.sh — 安装 oh-my-openagent (omo) 多 Agent 编排插件（可选增强）
# 用法: install-omo.sh [opencode配置目录]
# 默认配置目录: ~/.config/opencode (跟随 HOME 重定向，便携安全)
# omo 提供多 agent 协作：主 agent 分派子 agent 并行工作
# 来源: https://github.com/code-yeongyu/oh-my-openagent
# ============================================================================
set -e
OC_CONFIG_DIR="${1:-$HOME/.config/opencode}"
TOOLS_DIR="$(cd "$(dirname "$0")/../tools" 2>/dev/null && pwd || echo "")"

# 1. 下载 omo（U 盘版 tar.gz 曾损坏，故从 GitHub 重新获取）
OMO_DIR=""
if [ -n "$TOOLS_DIR" ] && [ -d "$TOOLS_DIR" ]; then
    for d in "$TOOLS_DIR"/*/oh-my-openagent "$TOOLS_DIR"/oh-my-openagent; do
        [ -d "$d" ] && OMO_DIR="$d" && break
    done
fi
if [ -z "$OMO_DIR" ]; then
    echo "[DL] 下载 oh-my-openagent (dev 分支)..."
    TMP_TGZ="$(mktemp /tmp/omo.XXXXXX.tar.gz)"
    curl -sL --connect-timeout 15 --max-time 120 -o "$TMP_TGZ" \
        "https://github.com/code-yeongyu/oh-my-openagent/archive/refs/heads/dev.tar.gz"
    OMO_DIR="$TOOLS_DIR/oh-my-openagent"
    mkdir -p "$OMO_DIR"
    tar xzf "$TMP_TGZ" -C "$OMO_DIR" --strip-components=1
    rm -f "$TMP_TGZ"
    echo "[OK] 已安装到 $OMO_DIR"
fi

# 2. 注册 npm 插件（omo 通过 npm 加载）
if command -v npm >/dev/null 2>&1; then
    npm install -g oh-my-opencode 2>/dev/null && echo "[OK] npm 包 oh-my-opencode 已安装" || echo "[WARN] npm 不可用，omo 可能需手动注册"
fi

# 3. opencode.json 启用 plugin
if [ -f "$OC_CONFIG_DIR/opencode.json" ]; then
    python3 - "$OC_CONFIG_DIR/opencode.json" << 'PYEOF'
import json, sys
path = sys.argv[1]
cfg = json.load(open(path))
plugins = cfg.setdefault("plugin", [])
if "oh-my-openagent" not in plugins:
    plugins.append("oh-my-openagent")
    json.dump(cfg, open(path, "w"), indent=2, ensure_ascii=False)
    print("[OK] opencode.json 已启用 oh-my-openagent 插件")
else:
    print("[SKIP] 插件已在配置中")
PYEOF
else
    echo "[WARN] 未找到 $OC_CONFIG_DIR/opencode.json — 请先运行一次 opencode 生成配置"
fi

echo ""
echo "完成。重启 opencode 后生效（/agents 查看多 agent 编排）。"
