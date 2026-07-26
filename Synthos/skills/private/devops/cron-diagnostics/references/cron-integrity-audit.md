# Cron Integrity Audit — 验证cron job输出真实性

## 触发条件

当用户质疑某个cron job的输出真实性，或发现输出与实际文件状态不符时触发。

## 核心问题

cron job子任务可能**编造脚本执行结果**。这不是工具限制，而是子任务在生成内容时产生了幻觉。

## 验证步骤

### Step 1: 检查脚本是否存在

```bash
ls -la /path/to/claimed/script.py
# 如果不存在 → 子任务编造了执行结果
```

### Step 2: 检查数据文件是否存在

```bash
ls -la /media/yakeworld/sda2/Synthos/outputs/papers/<paper_name>/state.json
# 如果不存在 → 子任务编造了文件内容
```

### Step 3: 对比输出与文件系统

```bash
# 如果输出说"成功执行了 check_and_fill_bib.py"
# 但 `find / -name "check_and_fill_bib.py"` 结果为空
# → 确认编造
```

### Step 4: 验证输出格式

- 子任务说"脚本输出XXX" → 实际 `ls` 文件是否真有
- 子任务说"state.json显示XXX" → 实际 `cat state.json` 是否真有
- 子任务说"审计完成" → 实际目录是否存在变化

## 预防机制

1. **cron job prompt中明确约束** — 必须写"直接读取文件，输出真实数据。不编造脚本执行结果。"
2. **no_agent脚本优先** — 纯脚本任务用 `no_agent=true`，不经过LLM生成
3. **关键输出必须手动验证** — 对重要cron job的输出，用 `ls`/`cat`/`find` 独立验证
4. **子任务不声称执行了不存在的脚本** — prompt中禁止"运行XXX脚本"这类描述，改为"读取XXX文件"

## 本次案例（2026-07-11）

cron job `paper-quality-iteration` (job_id: 32f5410e6ce9) 声称执行了：
- `python3 /media/yakeworld/sda2/Synthos/outputs/papers/check_and_fill_bib.py` — **脚本不存在**
- 论文目录 `2025-07-21-sleep-apnea-age-gender-bias-biometric-vitals-reduction` — **不存在**

处理：删除该job_id，重写prompt，确保后续任务只读取真实存在的文件。

## 输出格式

```
## 完整性审计结果

| 声明 | 实际状态 | 结论 |
|------|---------|------|
| 执行了XXX脚本 | 文件不存在 | 编造 |
| state.json显示XXX | cat后确认 | 真实 |
| 目录变化了 | ls后对比 | 真实/编造 |

## 建议

- 删除编造的cron job
- 重写prompt约束
- 对关键job添加独立验证步骤
```