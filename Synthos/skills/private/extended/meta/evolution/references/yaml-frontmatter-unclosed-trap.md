# YAML Frontmatter Unclosed Delimiter Trap (Cycle 209)

diagnose: YAML valid=4.7% → structural=0.6664
fix: 批量修复192个SKILL.md → structural_raw→1.0, overall 0.9032→0.9926

## 症状

diagnose.py 输出 `YAML valid: 9/192 (4.7%)` 但 `git tracked: 107/107`。
structural 被拉低到 0.6664（裸分=0.25贡献），即使 git 干净。

## 根因

SKILL.md 的 YAML frontmatter 缺少第二个 `---` 闭合符。 markdown 正文混入 YAML 段：

```yaml
---
name: some-skill
license: MIT
## Operational Steps       ← 这些导致 yaml.safe_load 失败
1. ...
category: core             ← 虽有效但位置错误
```

正确格式：
```yaml
---
name: some-skill
version: 1.0.0
category: core
---
## Operational Steps       ← 正文在 frontmatter 之后
```

## 检测

```python
import os, re
broken = []
for root, dirs, files in os.walk('skills'):
    for fn in files:
        if fn != 'SKILL.md': continue
        with open(os.path.join(root, fn)) as f:
            content = f.read()
        parts = content.split('---')
        if len(parts) < 3:
            broken.append(os.path.relpath(os.path.join(root, fn), 'skills'))
```

## 修复

提取 frontmatter 中 key:value 行 + 关闭 `---` + 剩余作 body。详见 YAML batch fix commit `b65a305`。

## 预防

1. 新建 SKILL.md 必须用标准模板：`---` → metadata → `---` → body
2. PROBE 步骤见 `YAML valid < 50%` 标记 🔴 优先级
3. redirect stub 不在此列（frontmatter 干净）
