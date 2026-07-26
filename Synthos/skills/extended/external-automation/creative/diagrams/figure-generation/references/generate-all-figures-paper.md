# generate_all_figures.py — 完整论文配图生成管线

> 2026-07-11, dual-ellipse-fitting 管线
> 这是 figure-generation 技能的完整工作示例：1张脚本 → 10+张配图（SVG+PDF+PNG）

## 文件结构

```
03-code/generate_all_figures.py  (主脚本, ~30KB)
├── generate_fig001()          # 架构图 (FancyBboxPatch + FancyArrowPatch)
├── generate_figure1()         # 双椭圆模型示意图
├── generate_figure2()         # 单椭圆 vs 双椭圆对比
├── generate_figure3()         # 3个子图 (0°/40°/70°)
├── generate_figure4()         # 光学轴偏差
├── generate_figure5()         # 空间偏差
├── generate_figure6()         # DICE系数对比
├── generate_figure7()         # 长轴长度变化
└── generate_graphical_abstract()  # 摘要图
```

## 关键实现要点

1. **出口契约**：SVG+PNG+PDF三种格式，`save_figure()` 统一处理
2. **算法集成**：`from dual_ellipse_fitting import PupilFitting` 导入真实算法
3. **Nature色板**：统一使用 `NATURE_COLORS` 字典
4. **fallback**：算法不可用时用模拟数据生成
5. **每个生成函数独立**：可单独调用

## 产出

- 10张PNG配图（28-203KB）
- fig001/Figure4-7 各附SVG+PDF
- 总输出~2.5MB
- 论文编译通过（pdflatex, 0 errors）

## 依赖

```
numpy, scipy, matplotlib, cv2, shapely
```

## Bug修复记录

1. **svg_fonttype不兼容**：matplotlib 3.11的 `FigureCanvasSVG.print_svg()` 不接受 `svg_fonttype` 参数。修复：删除 `save_figure()` 中SVG保存时的 `svg_fonttype='none'` 参数。
2. **Ellipse import缺失**：Figure2/3中 `from matplotlib.patches import Ellipse` 只在Figure1中导入，Figure2/3报 `NameError: name 'Ellipse' is not defined`。修复：在顶层imports中统一导入 `Ellipse`。
3. **算法返回结构不一致**：`generate_dual_ellipses()` 返回 `{'front': (a, b), 'back': (a, b), 'offset': float}` 而非字典嵌套。修复：直接使用元组解包。
4. **函数封装的QA检测**：`figure-qa-check.py` 的regex只匹配 `*_box = FancyBboxPatch(...)`，对 `draw_box(ax, x, y, ...)` 封装的检测为0。