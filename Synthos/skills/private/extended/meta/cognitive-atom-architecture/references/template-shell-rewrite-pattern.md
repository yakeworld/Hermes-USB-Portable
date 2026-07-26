# 认知原子模板壳检测与重写方法论

> 2026-07-10 实测：3个 core 原子（redirect 除外）中有 2 个是模板壳（EXT, ASC），1 个已有实质（HYP）。
> 重写后每原子从 102 行增至 301 行，含完整四支柱 + IO契约 + 陷阱 + 验证清单。

## 检测模板壳

扫描 `core/*/SKILL.md`，以下特征同时出现即为模板壳：

```bash
cd /media/yakeworld/sda2/Synthos
python3 -c "
import os
for root, dirs, files in os.walk('skills/core'):
    for fn in files:
        if fn != 'SKILL.md': continue
        with open(os.path.join(root, fn)) as f: c = f.read()
        is_shell = '\u786e\u8ba4\u8f93\u5165\u53c2\u6570\u5b8c\u6574' in c and ('1. \\n2. \\n3.' in c)
        if is_shell: print(os.path.relpath(os.path.join(root,fn), 'skills/core'))
"
```

检测要点：
- 包含"确认输入参数完整"（模板步骤）
- 包含空的编号列表（空验证清单）
- SKILL.md < 150 行
- YAML 前导元数据中 metadata 在正文里（frontmatter 只有 name + version）

## 三阶段重写流程

### 阶段一：读取上下文

1. 读 `references/BOUNDARY.md` — 边界声明
2. 读 `references/EVIDENCE_SCHEMA.md` — 证据链格式
3. 读 `references/IO_CONTRACT.md` — 契约详情
4. 读上下游原子的 SKILL.md — 接口兼容性
5. 检查 `metadata.synthos.related_skills` — DAG 依赖完整

### 阶段二：构建四支柱

**原理层·文言**：四字格言 2-3 句，用「」引用。不解释，只声明。

**方法层·白话**：
- ASCII 流程图
- 触发条件
- 逐步骤执行（每步有代码/命令/JSON schema）
- 每步的输入输出格式

**IO 契约**：输入字段表 + 输出 JSON schema + evidence_chain

**陷阱**：从实操提炼 ≥5 条，含现实案例

### 阶段三：整合验证

1. 合并为一个 SKILL.md
2. YAML 前导元数据整洁（所有 metadata 在 frontmatter 内）
3. 验证：`head -15` 检查 frontmatter 闭合
4. 末尾列出所有 references/ 文件
5. 验证清单 ≥8 项

## 输出质量检查

| 维度 | 标准 |
|------|------|
| 行数 | ≥250 行 |
| 陷阱数 | ≥5 条 |
| 验证项 | ≥8 项 |
| 原理层 | 文言格言 ≥2 句 |
| 方法层 | 流程图 + 触发条件 + 逐步骤 |
| IO 契约 | 输入表 + 输出 JSON schema |
| 前导元数据 | 全部在 YAML frontmatter 内 |

## 已知陷阱

- 跳到写内容前不看 BOUNDARY.md → 内容与边界矛盾
- 方法层只写"提取知识"不写具体字段 → 必须有 JSON schema
- 陷阱只写 2-3 条通用项 → 至少 5 条来自实操
- 写完不跑 diagnose.py → YAML 解析可能失败
- 忽略下游原子输入格式 → 输出不兼容
