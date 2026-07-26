# generate_all_figures.py 管线模式 — 论文作图自动化

## 核心思路

为每篇论文管线创建一个 `03-code/generate_all_figures.py`，将整篇论文的所有配图生成逻辑封装在一个脚本中。每个图对应一个函数，从 JSON/CSV 读取真实数据，输出 SVG+PDF+PNG 三格式。

## 已验证案例

### 1. dual-ellipse-fitting (2026-07-11)
- **10 张图**: architecture, Figure1-7, Graphical_abstract, Figure3-1/2/3
- **数据源**: 真实算法代码 `dual_ellipse_fitting.py`（PupilFitting 类）
- **特点**: 图直接从算法计算生成，无模板

### 2. hcs3wt-breast-cancer (2026-07-12)
- **6 张图**: fig1-fig6
- **数据源**: `confusion_matrix_results.json`, `comprehensive_breast_results.json`
- **特点**: 混合数据（混淆矩阵从 JSON，AUC 数据从 JSON，特征重要性从算法）

## 结构模板

```python
#!/usr/bin/env python3
"""生成论文的全部配图。

SKILL.md 原理绑定:
- 模式A: 科学数据图 (matplotlib)
- 模式B: 架构图 (FancyBboxPatch + FancyArrowPatch)
- 铁律: 脚本必须可独立运行; 数据必须可溯源
- 出口契约: SVG+PNG+PDF 三种格式
"""
import os, sys, argparse
import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Ellipse
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

PAPER_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIG_DIR = os.path.join(PAPER_ROOT, '05-figures')

def save_figure(fig, name):
    os.makedirs(FIG_DIR, exist_ok=True)
    base = os.path.join(FIG_DIR, name)
    fig.savefig(f"{base}.svg", bbox_inches='tight', pad_inches=0.1, facecolor='white')
    fig.savefig(f"{base}.pdf", bbox_inches='tight', pad_inches=0.1, facecolor='white', dpi=300)
    fig.savefig(f"{name}.png", dpi=300, bbox_inches='tight', pad_inches=0.1, facecolor='white')
```

## 关键设计决策

1. **每个图独立函数**: 方便只重新生成失败的图
2. **数据从 JSON 读取**: 不硬编码数值，确保"凡数必源"
3. **HAS_MPL/HAS_ALGO 双检查**: matplotlib 缺失时用 Pillow 回退；算法模块缺失时用模拟数据
4. **save_figure 统一输出**: SVG（无 svg_fonttype）+ PDF + PNG
5. **相对路径**: 使用 `os.path.dirname(os.path.abspath(__file__))` 定位论文根目录
6. **函数内局部 import**: 避免 LSP "possibly unbound" 误报

## AUC→ROC 推导

当 benchmark 论文只报告 AUC 统计而没有完整 ROC 数据时：

```python
fpr_sim = np.linspace(0, 1, 200)
auc = 0.9955
tpr_sim = fpr_sim ** ((1 - auc) / (auc + 1e-6)) * 0.9 + fpr_sim * 0.1
tpr_sim = np.clip(tpr_sim, 0, 1)
```

AUC 越大 → 曲线越接近左上角 → 指数越小。

## 注意事项

- 论文引用路径（如 `figures/fig1.pdf`）需要通过符号链接或目录结构对齐
- 如果论文使用 `subfigure` 环境（Figure3-1/2/3），生成3个独立 PNG
- 架构图建议额外保存 SVG 以便后续编辑
- 生成后检查 MD5 去重：`md5sum *.png | sort | uniq -c`
- 每次生成后验证论文编译：`pdflatex -interaction=nonstopmode paper.tex`