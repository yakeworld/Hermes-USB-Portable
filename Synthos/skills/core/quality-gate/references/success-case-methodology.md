# Synthos 原子技能成功案例方法学分析

> **生成时间**: 2026-07-04
> **来源**: 45个成功案例文件，3个Codex工作流程，1个全面报告模板
> **核心原则**: 每次任务完成后必须记录方法→形成可复用经验→下次直接沿用

---

## 一、成功案例全貌

Synthos 技能体系中共有 **45个** 经过实战验证的成功案例，按功能领域分为5类：

| 类别 | 数量 | 核心技能 |
|:-----|:----:|:---------|
| **G5引用/参考文献** | 13 | PDF收集、引文验证、D10a调试、DOI检测、内联bib审计、撤回论文审计 |
| **数据/数值验证** | 14 | PIMA审计、HCS3WT数值不一致、多位置一致性、基线检测、统计检验、笔记本院线核查 |
| **Codex执行流程** | 3 | 全面质量报告流程、G1-G7工作流程、综合报告模板 |
| **修复模式** | 10 | 修复配方、重验证审计、单列布局陷阱、消融泄漏、CTP队列协议、PIMA笔记本重组 |
| **技能设计** | 3 | 技能审计方法、抽象层级设计、论文约束系统 |

---

## 二、核心方法论：任务完成→经验沉淀→下次沿用

### 原则

```
任务开始 → 查已有成功案例 → 复用方法 → 执行 → 记录新发现/教训 → 更新案例
```

### 成功案例分析（按领域）

---

## 三、G5 引用检查 成功案例（13个）

### 核心方法论

**四层下载协议**（reference-pdf-collection-workflow.md）：
1. Layer 0: DOI可解析性验证（`curl -sI doi.org/$DOI`）
2. Layer 1: Semantic Scholar Open Access
3. Layer 2: 按出版商分路线下载（Wiley/Elsevier/Nature/JAMA/ACM/Springer/BMJ/IEEE）
4. Layer 3: Sci-Hub
5. Layer 4: Playwright浏览器下载（最终手段）

**下载后验证**：
- `head -c 10 file.pdf | od -A n -t x1 | grep -q "25 50 44 46"` — 真伪PDF
- `strings file.pdf | grep -ci "first_author_lastname"` — 内容匹配
- `strings file.pdf | grep -i "OLED\|光纤\|辐射"` — 防错配

### 关键案例

| 案例 | 问题 | 教训 |
|:-----|:-----|:-----|
| HCS3WT DOI验证(2026-06-25) | 32篇中7篇(22%) bib有DOI但doi.org 404 | **禁止仅查bib字段即判定通过**，必须curl验证 |
| HCS3WT假DOI修复(2026-06-25) | DOI指向错误论文 | Crossref搜索后替换为正确DOI |
| 内联bib调试(2026-06-26) | D10a工具错误比较bib与thebibliography | 区分外部bib和内联bib，分别匹配 |
| 内联bib扫描盲点(2026-06-27) | 68+论文因无.bib文件被扫描工具跳过 | **假阳性通过** — 必须扫描所有.tex中的thebibliography |
| 引文验证全文级(2026-06-18) | 形式检查通过后仍需逐篇PDF内容验证 | API能找文献，无法读全文判断论断一致性 |
| PDF替代搜索协议 | 直接下载失败 | Semantic Scholar → arXiv → 出版商 → Sci-Hub 多路径 |
| HCS3WT假DOI替换 | 某DOI指向不同论文 | Crossref搜索后替换 |
| 撤回论文审计 | 论文被撤稿 | Crossref/PubPeer/PMC四源交叉验证 |
| MedData认证调试 | 中文文献下载失败 | 认证链路自动化 |

### 成功标准

- D10a ≥ 95%
- 孤儿引用 = 0
- 僵尸引用 = 0
- PDF覆盖率 ≥ 80%（或≤20%有书面说明）
- 引用得当性：逐篇PDF内容验证

---

## 四、数据/数值验证 成功案例（14个）

### 核心方法论

**数值一致性检查**（numeric-cross-location-consistency.md）：
```bash
# 搜索核心数字的所有出现
grep -n '关键数值' paper.tex
# 必须出现在：Abstract + Intro + Table + Text + Discussion + Conclusion + Figure
```

**数据一致性验证**：
```bash
# 找到所有结果JSON
find . -name '*result*.json' -type f | sort
# 对关键字段做跨目录交叉比对
python3 -c "
import json, glob
key_fields = ['auto_rate', 'auto_acc', 'fn_red', 'hcs_fn', 'dataset']
for f in sorted(glob.glob('**/*result*.json', recursive=True)):
    if os.path.getsize(f) < 100: continue
    d = json.load(open(f))
    vals = {k: d.get(k) for k in key_fields if k in d}
    if vals: print(f'{f}: {vals}')
"
```

### 关键案例

| 案例 | 问题 | 教训 |
|:-----|:-----|:-----|
| PIMA数据审计(2026-06-20) | Notebook多配置，F1=0.6857无法复现(实际0.6177) | **Notebook不是确定性管线** — 必须单配置 |
| HCS3WT数值不一致(2026-06-29) | k=15 vs k=6，15处数值错误 | **代码是真理源** — 论文数字必须匹配JSON |
| 多目录数据源陷阱(2026-06-25) | 03-code/为空，experiment/有数据，两份JSON不同 | 以03-code/为准，空则用experiment/最新修改的 |
| 乳腺癌审计(2026-06-21) | Auditor误判WDBC数据全null | **审计前验证数据源**，Codex可能误判 |
| 笔记本脚本核查(2026-06-24) | 多个code cell不同配置 | Notebook必须简化为单一确定管线 |
| PIMA笔记本重组(2026-06-24) | Notebook 8+ cells，4个不同结果 | 删除废弃cells，保留最终管线 |
| 基线不一致检测 | 同一个delta值用不同baseline | **基线必须一致** — 所有位置用同一基准 |
| 统计检验验证 | 声称t-test但用错方法 | scipy ttest_rel（相同CV folds） |
| 消融泄漏实现 | 数据泄露导致结果虚高 | 独立验证实验管线 |
| CTP队列协议 | 质量报告格式不统一 | 标准化报告格式 |

### 成功标准

- 论文数值 = JSON数值（浮点误差<1%）
- 同一数值在所有位置一致
- Notebook输出可复现
- 基线在所有位置一致
- 统计检验方法正确

---

## 五、Codex 执行成功案例（3个）

### 核心方法论（codex-comprehensive-quality-report-workflow.md）

**认知同步协议** — Hermes与Codex共享Synthos/skills/目录作为共同事实层：

```
/media/.../Synthos/skills/
    ├── Hermes: skill_view('quality-gate')  → 读SKILL.md
    └── Codex:  任务文件指明路径           → 自主加载SKILL.md
```

**5步闭环工作流**：

1. **数据收集**（Hermes侧预处理）
   - 检查目录结构
   - 列举所有JSON
   - 检查state.json
   - 检查编译日志
   - 检查PDF收集状态

2. **编写任务文件**（认知同步协议）
   - 指定工作目录
   - 指定技能路径（绝对路径）
   - 指定报告模板
   - **不嵌入技能内容** — 让Codex自己从Synthos加载

3. **通过tmux发送任务**
   - `tmux new-session -d -s codex-<name>`
   - `tmux send-keys` 发送指令
   - 等待30-120s后检查进度
   - 重复直到完成

4. **读取报告**
   - 提取P0/P1问题
   - 检查"修复建议"是否可执行

5. **自主修复闭环**
   ```
   读取报告 → 分析P0/P1 → 分类可自主/需人工
     → 并行执行所有可自主修复
     → 清理LaTeX辅助文件
     → 重新编译：pdflatex → bibtex → pdflatex × 2
     → 验证编译成功
     → 更新state.json
     → 写fix-log.md
   ```

### 关键教训

| 教训 | 说明 |
|:-----|:-----|
| **任务文件必须自包含** | Codex无Hermes会话memory |
| **等待时间1-3min** | vLLM负载高时Codex响应慢 |
| **不要用delegate_task** | 全量质量检查会超时600s |
| **勿报告"有N个问题"** | 用户看到的是已修复版本 |
| **LaTeX反斜杠陷阱** | patch工具双转义`\\cite`、`\\pm` |
| **bib用write_file** | patch工具会损坏BibTeX结构 |
| **Kapoor式PDF验证** | SS API查openAccessPdf比直接下载更可靠 |
| **已有报告重检** | 先读已有报告了解已知问题，再派Codex |

---

## 六、修复模式成功案例（10个）

### 核心方法论（re-verification-audit-pattern.md）

**重验证模式** — 对已审计论文执行新一轮审计时，必须验证修复是否仍然有效：

```
Step 1: 读取旧报告和fix-log
Step 2: 逐项检查旧修复是否有效
  - grep全文确认无残留
  - 重新运行D8/D10a扫描
  - 重新核对所有数值与JSON一致性
  - 确认编译状态
Step 3: 旧修复有效 → VERIFIED；有残留 → STALE_RESIDUE + 修复
Step 4: 更新fix-log.md
Step 5: 更新state.json
Step 6: 更新AUDIT_QUEUE.md
```

**残留检测清单**：
| 残留类型 | 检查方法 | 典型残留 |
|---------|---------|---------|
| p-value残留 | `grep -i 'p<0\|p-value' paper.tex` | abstract已删但results中还在 |
| 旧数值残留 | `grep '+14.17' paper.tex` | 部分位置已修但遗漏 |
| 基线不一致 | 检查abstract+results+conclusion | abstract用ensemble, results用GBC |
| 统计检验残留 | `grep -i 'wilcoxon\|t.test' paper.tex` | 声称做了但代码没做 |
| 内联bib残留 | `grep -c 'thebibliography' paper.tex` | 应已转为.bib格式 |
| .bbl残留 | `ls -la *.bbl` | 应为空或0 bytes |

### 修复决策矩阵

| 问题类型 | 自主可修? | 操作 |
|:---------|:---------:|:-----|
| paper.tex数值错误 | ✅ | patch数值来自JSON |
| paper.tex文本声明错误 | ✅ | patch |
| bib清理(orphan/DOI/重复) | ✅ | write_file重写 |
| 错误PDF文件 | ✅ | 删除，从SS/Crossref重下载 |
| 实验代码/JSON残留 | ✅ | 删除或更新 |
| p-value/效应量未记录 | ❌ | 需重新实验 — 标记TODO |
| LaTeX编译反斜杠污染 | ✅ | Python正则修复 |
| 编译错误 | ✅ | 清理辅助文件，recompile |
| state.json更新 | ✅ | write_file重写 |

---

## 七、Synthos成功案例的共性方法（从45个案例中提取）

### 共性方法论

1. **凡数必源** — 每个数值必须有源文件支撑（JSON/CSV/Notebook）
2. **凡引必验** — 每条引用必须可验证（DOI+PDF+语义）
3. **代码是真理源** — 论文数字必须匹配experiment_results.json
4. **技能优先** — 任务优先加载对应skill，用skill内定义的工具/命令/API
5. **Hermes决策，Codex执行** — 任务文件只写"做什么"，不写"怎么做"
6. **自主修复闭环** — 不要报告"有N个问题"，自己修完再交付
7. **重验证模式** — 旧报告可能stale，每次必须重新验证修复是否有效
8. **反斜杠陷阱** — patch工具对LaTeX必然双转义，每次patch后必须检查修复
9. **bib用write_file** — patch会损坏BibTeX结构
10. **PDF内容验证** — 下载后用strings搜索主题关键词，防DOI错配
11. **多路径下载协议** — DOI → Semantic Scholar → 出版商 → Sci-Hub → Playwright
12. **数值多位置一致性** — 同一数字出现在6+个位置，必须逐位置更新
13. **Notebook必须确定化** — 单一管线，可复现

### 任务开始前必查清单

```
□ 1. 查已有成功案例: ls references/ | grep -i "task_type"
□ 2. 查技能是否有标准流程: skill_view('skill_name')
□ 3. 查fact_store: fact_store(action='probe', entity='task_category')
□ 4. 查是否有stale报告: grep -l 'stale\|outdated' 07-quality/
□ 5. 检查依赖环境: Python版本、关键包、API密钥
□ 6. 准备任务文件: 指定路径、技能、输出格式
□ 7. 确认执行工具: tmux + Codex 还是直接执行
```

---

## 八、下次任务直接沿用的方法

### 通用任务模板

```
1. 加载技能: skill_view('对应技能')
2. 读案例: cat skills/*/references/*案例*.md
3. 准备环境: 检查依赖、API、目录结构
4. 收集数据: 读取论文、代码、JSON、报告
5. 构建任务: 写任务文件（Hermes决策）
6. 执行: tmux + Codex 或 直接执行
7. 验证: 编译/运行/检查
8. 修复: 自主修复所有可修问题
9. 记录: 写fix-log.md，更新state.json
10. 更新案例: 把新发现/教训写入references/
```

### 本次HCS3WT G5检查的直接应用

基于以上成功案例分析，本次HCS3WT参考文献全文检查应按以下标准流程：

1. **加载技能**: citation-appropriateness-verification + reference-verification
2. **读取案例**: 参考上述45个案例，特别是：
   - reference-pdf-collection-workflow.md（四层下载协议）
   - codex-comprehensive-quality-report-workflow.md（5步闭环）
   - re-verification-audit-pattern.md（重验证模式）
3. **使用Codex**: 通过tmux发送任务，让Codex逐篇阅读PDF+语义比对
4. **自主修复**: 修复所有可修问题（删除未引用、补充缺失、更新状态）
5. **记录经验**: 把本次经验写入新的案例文件
6. **更新技能**: 如有新方法，更新skill SKILL.md

---

*这份方法论文档应保存在 ~/synthos-case-studies/methodology-analysis.md 并定期更新。*