# Git .gitignore 审计协议

## 问题

`.gitignore` 注释与规则可能矛盾，导致大量文件被意外追踪并推送。

**经典案例**（2026-07-06, Synthos 仓库）:
- `.gitignore` 注释写 "# skills/private/ — 私有技能纳入git"
- 但实际规则只排除 pycache/pyc/.DS_Store 等缓存文件
- 结果：776 个 private skill 文件全部被追踪并推送到 GitHub
- 4 个 outputs/ 文件在规则生效前被 git add，仍被追踪

## 审计步骤

### Step 1: 检查关键目录
```bash
# outputs/ 应完全被忽略
git ls-files | grep "^outputs/" | wc -l
# 应返回 0

# private/ 应完全被忽略
git ls-files | grep "^skills/private/" | wc -l
# 应返回 0

# 其他应忽略的目录
git ls-files | grep -E "^research/|^data/|^literature/" | wc -l
# 应返回 0
```

### Step 2: 验证 .gitignore 规则生效
```bash
# check-ignore -v 显示匹配的规则
git check-ignore -v outputs/papers/hcs3wt-breast-cancer/01-manuscript/supplementary_baselines.json
# 应输出: .gitignore:6:/outputs/ outputs/...

# 如果无输出，文件未被忽略
git check-ignore outputs/papers/hcs3wt-breast-cancer/03-code/coimbra_results.json
# 如果无输出，文件未被忽略
```

### Step 3: 修复
```bash
# 从索引中移除被追踪但不应该追踪的文件
git rm --cached <file>

# 批量移除
git ls-files | grep "^outputs/" | while read f; do git rm --cached "$f"; done
git ls-files | grep "^skills/private/" | while read f; do git rm --cached "$f"; done
```

### Step 4: 提交并验证
```bash
git commit -m "fix: remove tracked files that should be gitignored"
git status --short | grep "D "  # 应显示删除
git status --short | grep "M "  # 应只有 .gitignore 修改
```

## 预防规则

1. **注释必须与规则一致**：如果注释说"纳入git"，实际规则必须不排除该路径；如果注释说"不入库"，规则必须排除该路径。
2. **已追踪的文件不会被 .gitignore 自动过滤**：`.gitignore` 只影响未追踪的文件。已 `git add` 的文件需要用 `git rm --cached` 从索引中移除。
3. **每次修改 `.gitignore` 后**：运行 `git ls-files | grep` 检查是否有遗漏。