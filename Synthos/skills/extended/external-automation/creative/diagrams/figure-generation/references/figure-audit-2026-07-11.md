# 图管线审计记录 — 2026-07-11

## 审计背景

作图技能理论上是"已完成的技能体系"，但实际审计发现论文管线中的图与生成脚本严重脱节。

## 审计发现

### 全管线扫描

- **总论文数**: 66篇
- **有配图的论文**: 66篇（182张PNG）
- **有生成脚本的论文**: 2篇（dual-ellipse-fitting, hcs3wt-breast-cancer, pima-crispdm）

### 模板化配图问题

**dual-ellipse-fitting**: 65张architecture图只有3种不同MD5
- 36张 (17.8KB) = 模板A (PINN/ODE类)
- 20张 (24.5KB) = 模板B (corneal/ODE类)
- 9张 (24.5KB) = 模板C

56张parameter-space图：全部相同 (103.4KB, MD5: a8978e73)
56张results图：全部相同 (101.5KB, MD5: 8645d67c)

→ 176/182张"配图"是复制粘贴的模板图，不是数据驱动的真实图。

### QA自动检测覆盖率

figure-qa-check.py的regex只匹配 `*_box = FancyBboxPatch(...)`，对函数封装的图（如pima的draw_box()）无法检测，导致"虚假通过"。

### 出口契约违反

pima的generate_figures.py只生成PDF，不生成PNG。论文管线需要PNG(300DPI)。

## 修复行动

### 1. dual-ellipse-fitting 管线

**问题**: 10张高质量配图无生成脚本。
**修复**: 创建 `03-code/generate_all_figures.py` (34KB)

- 所有图使用真实算法数据（PupilFitting类）
- 出口契约: SVG+PDF+PNG (300DPI)
- 论文编译通过: 16页, 0 errors
- 状态: **已完成 ✅**

### 2. hcs3wt-breast-cancer 管线

**问题**: 6张配图部分有SVG但无统一生成脚本。
**修复**: 子任务创建 `03-code/generate_all_figures.py` (39KB)

- 所有数据来自 `comprehensive_breast_results.json`, `confusion_matrix_results.json` 等
- 出口契约: SVG+PDF+PNG (300DPI)
- 论文编译通过: 29页, 0 errors
- 状态: **已完成 ✅**

## 经验教训

1. **"有图不等于有脚本"** — 管线中66篇论文有配图，但只有2篇有生成脚本
2. **模板化配图是隐形问题** — 65张相同MD5的图说明整个管线被模板化了
3. **QA检测有盲区** — regex只匹配特定模式的代码，函数封装的图无法检测
4. **数据驱动是铁律** — 脚本必须读JSON/CSV数据，不能硬编码数值
5. **出口契约必须完整** — 至少保存PNG(300DPI)，有数据的保存SVG+PDF+PNG

## 后续建议

1. **ODE/PINN论文管线**: 这些论文（如bppv-canalith-relocation-ode）的03-code/只有通用模板（`TODO: 根据具体论文替换方程`），没有实际算法代码。需要从论文管线中统一抽取图生成逻辑，为ODE管线创建通用模板。
2. **QA自动化增强**: figure-qa-check.py应支持函数封装检测（如 `def draw_box()` 中的 ax.add_patch() 调用）。
3. **批量脚本化**: 对于182张模板图，至少为其中3种不同MD5创建对应的生成脚本，证明模板不是硬编码的。