#!/bin/bash
# ============================================================================
# link-opencode-skills.sh — 将 Synthos 技能链接到 opencode 可发现路径
# 用法: link-opencode-skills.sh <Synthos-skills目录> [目标目录]
# 默认目标: $HOME/.agents/skills  (opencode 原生 Agent Skills 路径)
# 原理: opencode 原生支持 ~/.agents/skills/<name>/SKILL.md，
#       Hermes/Synthos 的 SKILL.md 格式与其兼容（未知 frontmatter 字段忽略）
# ============================================================================
SRC="${1:?用法: link-opencode-skills.sh <Synthos-skills目录> [目标目录]}"
DEST="${2:-$HOME/.agents/skills}"

mkdir -p "$DEST"

count=0
skipped=0
while IFS= read -r skill_dir; do
    case "$skill_dir" in
        *.archive*) skipped=$((skipped+1)); continue ;;
    esac
    name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" "$DEST/$name"
    count=$((count+1))
done < <(find -L "$SRC" -name SKILL.md -exec dirname {} \; 2>/dev/null)

echo "  [OK] Linked $count Synthos skills -> $DEST (skipped $skipped archived)"
