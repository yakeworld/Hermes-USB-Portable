# delegate_task 方法论 — 2026-07-11 实测

## 核心原则
子任务派发时，只传用户原话，不加微操指令。

## 正确 vs 错误
✅ delegate_task(goal="用户的原话描述")
❌ delegate_task(goal="...", context="先加载skill A,再调脚本B...")

## 原因
子Agent有自己的SOUL.md和skills库。context写越多，子Agent越倾向于重新实现而非直接调成熟脚本。

## 验证标准
1. tool_trace中skill_view调用 → 加载了技能？
2. 执行了literature search等成熟脚本？还是自己写curl？
3. 任务完成？summary有产出？
4. 耗时 <300s？否则卡住了

## 批量限制
- 子Agent有600s超时
- 不要派 >10篇给一个子Agent
- 大任务拆为多个并行子任务(max 3并发)
