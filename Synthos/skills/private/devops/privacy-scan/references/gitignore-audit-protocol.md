# .gitignore 审计协议 — 确保规则与实际追踪一致

## 问题

.gitignore 注释和实际规则可能矛盾，导致大量文件被意外追踪。

**经典案例**（2026-07-06, Synthos 仓库）:
- `.gitignore` 注释写 "# skills/private/ — 私有技能纳入git"
- 但实际规则只有：`skills/private/**/__pycache__/`, `skills/private/**/*.pyc` 等缓存排除
- 结果：776 个 private skill 文件全部被 git 追踪并推送到 GitHub
- 同时 4 个 outputs/ 文件在 `.gitignore` 规则生效前被 git add，仍被追踪

## 审计步骤

### Step 1: 检查 outputs/ 是否完全被忽略
```bash
git ls-files | grep "^outputs/" | wc -l
# 应返回 0。非零说明有 outputs 文件被追踪。
```

### Step 2: 检查 private/ 是否完全被忽略
```bash
git ls-files | grep "^skills/private/" | wc -l
# 应返回 0。非零说明 private 技能被追踪。
```

### Step 3: 检查 .gitignore 中是否有任何规则遗漏
```bash
# 列出所有被追踪的文件
git ls-files > /tmp/all_tracked.txt

# 对于每个可能的排除目录，检查是否有文件在追踪中但不在 .gitignore 中
for dir in outputs/ skills/private/ .evolution/ research/ data/ literature/; do
  echo "=== $dir ==="
  git check-ignore -v $(git ls-files | grep "^$dir" | head -3) 2>&1
done
```

### Step 4: 修复
```bash
# 从索引中移除被追踪但不应该追踪的文件
git rm --cached <file>

# 批量移除
git ls-files | grep "^outputs/" | git rm --cached --stdin
git ls-files | grep "^skills/private/" | while read f; do git rm --cached "$f"; done
```

### Step 5: 验证修复
```bash
git check-ignore -v outputs/papers/hcs3wt-breast-cancer/01-manuscript/supplementary_baselines.json
# 应输出 .gitignore:6:/outputs/ ... 表示被正确忽略
```

## 预防

1. **注释必须与规则一致**：如果注释说"纳入git"，实际规则必须**不排除**该路径；如果注释说"不入库"，规则必须**排除**该路径。不能只写排除子路径而让父路径被追踪。
2. **定期运行审计**：每次修改 `.gitignore` 后，运行 `git ls-files | grep` 检查是否有遗漏。
3. **已追踪的文件不会被 .gitignore 自动过滤**：`.gitignore` 只影响未追踪的文件。已 `git add` 的文件需要用 `git rm --cached` 从索引中移除。

## 参考

- `references/gitrepo-cleanup.md` — 历史泄露清理完整流程
- `.gitignore` 文件本身 — 当前仓库的排除规则