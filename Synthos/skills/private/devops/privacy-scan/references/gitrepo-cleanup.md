# Git 历史泄露清理 — 完整操作手册

## 检测

### 1. 预推送扫描
```bash
bash ~/.hermes/scripts/privacy-scan.sh
```

### 2. 历史泄露检测（三重交叉验证）

#### 2a. git grep（精确匹配）
```bash
git grep -c "iYTNXXDH278PVXl2FJ2YU1TyZ5joLAZr3WA9IVzt"
```
零结果 = 当前树中无密钥。

#### 2b. git log -S（子串搜索）
```bash
git log --all -S "iYTNXX" --oneline
```
⚠️ 注意：可能匹配文档缩写引用（如 `iYTNXX...`），不等于实际泄漏。

#### 2c. git ls-tree（逐 blob 验证）
```bash
git ls-tree -r HEAD | grep "blob" | while read line; do
    hash=$(echo "$line" | awk '{print $3}')
    git cat-file -p "$hash" | grep -q "iYTNXXDH278PVXl2FJ2YU1TyZ5joLAZr3WA9IVzt" && echo "FOUND: $line"
done
```

#### 2d. on-disk 文件检查
```bash
grep -rn "iYTNXXDH278PVXl2FJ2YU1TyZ5joLAZr3WA9IVzt" outputs/ 2>/dev/null
```
gitignored 文件也需检查。

## 清理

### 1. 清理 git 历史
```bash
# 创建替换文件
cat > /tmp/git_replacements.txt << EOF
iYTNXXDH278PVXl2FJ2YU1TyZ5joLAZr3WA9IVzt=YOUR_API_KEY_HERE
s2k-HTuOQt7IYWcPOmxnJPvfLjISRjJg8tZK9aKGTmBD=YOUR_API_KEY_HERE
6m6pingbinwaktg227gngifoocrfbo95=YOUR_PUBSCHOLAR_SALT_HERE
15088554408=+1-XXX-XXX-4408
13758284807=+1-XXX-XXX-4807
EOF

# 删除已有 filter-repo 状态
rm -rf .git/filter-repo

# 执行替换
git-filter-repo --replace-text /tmp/git_replacements.txt --force
```

### 2. 处理 `---` 边界问题
git-filter-repo 对含 `---` 的文件（SKILL.md 等）只处理 frontmatter。
检查：
```bash
git grep -c "iYTNXX" --include=*.md
```
如有剩余，手动替换后 `git add` + `git commit-tree` 修补 commit。

### 3. 清理 on-disk 文件
```bash
# 找到含密钥的非 git 文件
grep -rn "iYTNXXDH278" . --include=*.log --include=*.py --include=*.json --exclude-dir=.git 2>/dev/null

# 替换
find . -name "*.log" -o -name "*.py" -o -name "*.json" | xargs grep -l "iYTNXXDH278" | while read f; do
    sed -i 's/iYTNXXDH278PVXl2FJ2YU1TyZ5joLAZr3WA9IVzt/YOUR_API_KEY_HERE/g' "$f"
done
```

### 4. 强制推送
```bash
# filter-repo 会移除 origin remote
git remote add origin https://github.com/yakeworld/Synthos.git
git push --force-with-lease origin main
```

## 验证清单
- [ ] `git grep -c KEY` = 0
- [ ] `git log -S KEY --oneline` = 空（或仅文档缩写）
- [ ] `git ls-tree -r HEAD` 逐 blob 检查通过
- [ ] `privacy-scan.sh` 预推送通过
- [ ] on-disk 文件无真实密钥
- [ ] `git push --force-with-lease` 成功

## 参考案例
- Synthos 项目 2026-07-03：267 个 commit 全部重写，清除 SS Key + SALT + 手机号
- 检测到的泄漏：iYTNXX (40位) 在 9 commits, s2k-HT (44位) 在 7 commits, SALT 在 1 commit
- 修复后：所有 git-tracked 文件零泄漏，文档中缩写引用 `iYTNXX...` 保留但无实际密钥