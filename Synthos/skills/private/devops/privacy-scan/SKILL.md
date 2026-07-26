---
name: privacy-scan
category: devops
related_skills: ['safe-file-operations', 'anti-detect-browser']
description: Git 推送前隐私安全扫描 — 拦截 API Key、GitHub Token、密码、手机号等敏感信息泄露
version: 1.1.0
author: Synthos
license: MIT
signature: "privacy-scan -> processed_result"
---

# 隐私安全扫描（Pre-Push Privacy Scanner）

## 原理

每次 `git push` 时，pre-push hook 自动扫描即将推送的 commit，拦截敏感信息。

## 安装

### 已安装的仓库
- `Synthos`
- `academic_agent_prompt`（本地）
- `Synthos-competition`
- `crispdm-pima`

### 手动安装到新仓库
```bash
ln -sf ~/.hermes/scripts/privacy-scan.sh /path/to/repo/.git/hooks/pre-push
```

### 全局模板（新仓库自动安装）
已在 `~/.git-templates/hooks/pre-push` 配置了全局 git 模板：
```bash
git config --global init.templateDir ~/.git-templates
```

## 扫描内容

| 类别 | 模式 | 示例 |
|:-----|:-----|:-----|
| GitHub PAT（经典） | `ghp_` + 36位 | `ghp_xxxx...` |
| GitHub PAT（细粒度） | `github_pat_` + 82位 | `github_pat_xxx...` |
| GitHub OAuth | `gho_` + 36位 | `gho_xxxx...` |
| OpenAI / API Key | `sk-` + 20位以上 | `sk-xxxx...` |
| HuggingFace Token | `hf_` + 20位 | `hf_xxxx...` |
| JWT Token | `eyJ` + base64.base64 | `eyJxxx.xxx.` |
| SSH 私钥 | `-----BEGIN...PRIVATE KEY-----` | 私钥内容 |
| URL 内嵌凭证 | `https://user:pass@host` | 明文密码 |
| 中国大陆手机号 | `1[3-9]` + 9位数字 | `139xxxxxxx` |
| 已知真实凭证 | 精确字符串匹配 | 已泄露的 Key |

## 历史泄露清理

### 检测方法
1. **git grep** — 精确匹配完整密钥字符串（推荐首选）
2. **git log -S "KEY"** — 子串搜索，遍历所有历史提交（注意：可能匹配文档缩写引用，需交叉验证）
3. **git ls-tree -r HEAD** — 逐 blob 检查（最终确认）
4. **on-disk scan** — 检查非 git 文件（~/.secrets, ~/.bashrc, outputs/ 等）
5. **pre-push** — 运行 pre-push hook 作为最后一道防线

### 清理流程
1. 确认所有 commits 已通过 git-filter-repo --replace-text 重写
2. 交叉验证：git grep 零结果 + git ls-tree 无实际泄漏
3. 检查 on-disk 非跟踪文件（如 outputs/）是否仍含真实密钥
4. 清理磁盘文件
5. git push --force-with-lease origin main

## Pitfalls
- `git log -S` 是子串匹配，文档缩写引用（如 `iYTNXX...`）也命中；**必须**用 `git grep` 搜索完整字符串
- `git log -S` 显示 diff 中的 `+`/`-` 行，不等于 blob 中存在密钥；需用 `git ls-tree -r` 逐 commit 验证
- `git-filter-repo` 对含 `---` 边界的文件（如 SKILL.md）只处理 frontmatter，body 中密钥可能保留，需二次修补（用 `git-commit-tree` 手动替换 blob）
- on-disk 非 git 文件（如 `outputs/` 下日志/脚本）含真实密钥，即使 gitignored 也需清理
- `~/.secrets` 是本地凭证库（mode 600），含真实密钥是 EXPECTED 行为，不是 git 泄漏
- 2026-07-03: 完整审计流程升级 — git grep → git ls-tree → git log -S → on-disk scan → pre-push hook 五步法
- 2026-07-03: git-filter-repo 的 `---` 边界 bug 已记录 — SKILL.md 文件需要 `git ls-tree` 二次验证
- 2026-07-06: .gitignore 注释与规则可能矛盾 — 注释写"私有技能纳入git"但实际规则只排除 pycache/pyc/Dotstore 等缓存文件，导致 776 个 private skill 文件被追踪。修复：`git rm --cached` 逐个移除 + `.gitignore` 中用 `skills/private/` 直接排除整个目录。

## 维护

### 添加已知凭证到黑名单
编辑 `~/.hermes/scripts/privacy-scan.sh`：
```bash
KNOWN_SECRETS=(
    "新泄露的key"
    # ...
)
```

### 跳过扫描（紧急情况）
```bash
git push --no-verify
```
仅在确认没有敏感信息时使用。

## 已知泄漏记录（2026-07-03）

**泄露内容**: SS API Key (iYTNXX, 40位) + SS API Key (s2k-HT, 44位) + PubScholar SALT + 2个手机号
**影响范围**: 267 个历史提交（a2af230 → f08ba8a）
**已清理**: 全部 267 个 commits 已通过 git-filter-repo 重写清除
**本地凭证**: ~/.secrets (mode 600) 仍含原密钥，需轮换
**磁盘文件**: outputs/ 日志/脚本含密钥，已清理

## 文件位置
- 脚本: `~/.hermes/scripts/privacy-scan.sh`
- 全局模板: `~/.git-templates/hooks/pre-push`

## 参考文件
- `references/gitignore-audit-protocol.md` — .gitignore 规则审计完整步骤（注释/规则矛盾检测、批量 `git rm --cached`、验证）
- `references/gitrepo-cleanup.md` — 历史泄露清理完整流程（git-filter-repo 操作指南）

## 契约层 · BOUNDARY

**边界**：技能功能边界。

## 契约层 · IO_CONTRACT

**输入**：请求描述、上下文信息。
**输出**：执行结果、状态反馈。

## 验证清单 · VERIFICATION

1. 输入验证: 输入参数/文件/路径是否完整且有效
2. 过程验证: 中间步骤/转换/计算是否正确
3. 输出验证: 输出格式/内容是否符合预期
4. 边界验证: 空输入、极大值、异常场景是否处理
5. 错误处理: 失败时是否有明确的错误信息和恢复指引

## 核心原则 · PRINCIPLES

1. 准确为先: 所有输出必须经过事实核查，不编造数据
2. 证据驱动: 每个结论必须可追溯到具体证据或数据源
3. 可复现性: 每一步操作必须可重复，结果可验证

## 约束规则 · RULES

1. 输入约束: 参数类型、范围、格式必须校验
2. 输出约束: 返回值结构、编码、命名必须一致
3. 异常约束: 错误信息必须包含上下文和恢复建议
4. 安全约束: 不执行未验证的任意代码，不暴露内部状态

## Golden 集合 · GOLDEN SET

- Golden Input: 标准输入样本（覆盖正常路径）
- Golden Output: 预期输出（精确匹配或格式校验）
- Golden Error: 预期错误信息（覆盖失败路径）

> Golden 集合是测试的单一真理来源。所有改进必须通过 golden 测试。

> 违反规则的操作视为不安全，必须拒绝或隔离。

> 违反任何原则的输出视为失败。原则优先级：准确 > 证据 > 可复现。

> 每项验证必须可执行、可记录、可复现。验证失败时记录原因和修复。
