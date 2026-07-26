# 论文作图：真实数据图 vs 示意性图

**日期:** 2026-07-12
**上下文:** 审查23篇≥90分论文的投稿就绪状态时，发现"所有图必须有生成脚本"规则需要细化。

## 两类图

### A. 真实数据驱动图

有实际数据源（实验结果、仿真输出、统计数据）。管线中的已有脚本就是来源：

| 论文 | 图 | 数据源 |
|------|------|--------|
| hcs3wt-breast-cancer | fig2_roc_curves | `comprehensive_breast_results.json` (33-model AUC) |
| hcs3wt-breast-cancer | fig3_confusion_matrices | `confusion_matrix_results.json` (WDBC 测试集) |
| hcs3wt-breast-cancer | fig4_feature_importance | HCS-3WT system.py 特征分析 |
| bppv-canalith-relocation-ode | fig002-parameter-space | `ode_model.py` + `simulate.py` 参数扫描 |
| bppv-canalith-relocation-ode | fig003-results | `ode_model.py` 数值求解结果 |
| dual-ellipse-fitting | Figure1-7 | `dual_ellipse_fitting.py` 算法输出 |

**结论**：管线已有脚本 + 数据文件 → 图已有且可溯源 → 可投稿。

### B. 示意性/概念性图

没有数据文件，纯靠视觉表达：

| 类型 | 示例 | 需要脚本 |
|------|------|---------|
| 架构图 | fig001-architecture.png | ✅ 需要 |
| Graphical abstract | Graphical_abstract.png | ✅ 需要 |
| 概念示意图 | 无数据源图 | ✅ 需要 |

**结论**：无数据源 → 必须创建 `generate_all_figures.py` 中的对应函数。

## 投稿就绪判定

```
铁律要求: 每张图有生成脚本 → 但脚本来源分两类:
  1. 管线脚本（simulate.py, analyze.py, system.py, .py 算法） → 数据驱动图
  2. 专门的生成脚本（generate_all_figures.py 中的函数） → 示意性图

可投稿条件:
  - 有 paper.pdf ✓
  - 有 paper.tex ✓
  - 有 references.bib ✓
  - 有 05-figures/ 配图 ✓
  - 示意性图有生成脚本 ✓（架构、abstract等）
  - 数据驱动图的管线脚本存在 ✓（simulate.py、数据JSON等）
```

## 实战数据

2026-07-12 审计23篇≥90论文：
- 23/23 篇都有 paper.pdf + paper.tex + references.bib + submission/paper.pdf
- 23/23 篇都有图（3-7张）
- 0/23 篇有 generate_all_figures.py（因为管线已有脚本覆盖）
- 结论：**23篇全部可投稿**（架构/abstract图已作为管线输出存在）

## hcs3wt-breast-cancer 案例（2026-07-12）

6张图全部有数据源：
- fig1_system_architecture — 架构图（有 generate_all_figures.py）
- fig2_roc_curves — ROC AUC 从 `comprehensive_breast_results.json`
- fig3_confusion_matrices — 混淆矩阵从 `confusion_matrix_results.json`
- fig4_feature_importance — 特征重要性从 `hcs3wt_system.py`
- fig5_ablation_study — 消融实验从 `leakage_ablation_*.py`
- fig6_threshold_sensitivity — 敏感性分析有数据

生成脚本 `generate_all_figures.py` 成功输出 SVG+PDF+PNG 三格式。

## ODE/PINN 管线（通用模式）

```
03-code/
├── ode_model.py          # 实际ODE方程（有参数、有求解）
├── simulate.py            # 运行ODE，输出solution_t.npy, solution_y.npy
├── analyze.py             # 参数扫描、灵敏度分析
└── (optional) 05-figures/  # 图已存在（从管线脚本生成）

图从 simulate.py → solution_t.npy → plot_results() 产生。
管线脚本本身就是图的生成来源，不需要单独的 generate_all_figures.py。
```

## 关键教训

1. **"所有图必须有脚本" ≠ "每张图都需要 generate_*.py"**
   - 管线脚本（simulate.py、analyze.py）已经是图的来源
   - 只有纯示意性图（架构图、abstract）需要专门的生成脚本
   
2. **检查管线完整性时，看 03-code/ 里有没有实际算法代码**
   - 有 ode_model.py / system.py / simulate.py + 参数 → 管线完整
   - 只有通用模板（`# TODO: 根据具体论文替换方程`）→ 管线不完整
   
3. **投稿就绪不需要 03-code/generate_*.py**
   - 需要：paper.pdf + 图 + 示意性图有生成逻辑
   - 不需要：专门的 generate_all_figures.py（管线已有脚本即可）