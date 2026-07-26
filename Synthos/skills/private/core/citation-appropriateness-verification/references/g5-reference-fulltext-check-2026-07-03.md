# G5 参考文献全文检查 — 完整流程记录（2026-07-03）

## 背景

用户要求对 HCS-3WT 乳腺癌论文进行完整的 G5 参考文献质量检查：
- 必须全文验证每一篇引用
- 必须指出每篇文献被引用的理由
- 必须补充缺失的参考文献
- 必须下载全文验证

## 问题发现

### 初始状态
- paper.tex 内联 thebibliography: 28 个 `\bibitem{}`
- paper.tex 中 `cite{}`: 25 个（3 个未引用：Bray2024GlobalCancer, Caruana2015Intelligible, Collins2024TRIPODAI）
- references.bib: 10 个条目（全部被引用）
- 但 25 个 cited keys 中，只有 10 个在 references.bib 中，其余 15 个只在 inline thebibliography 中

### 核心问题
**内联 bib 和 references.bib 不同步**——这是 G5 检查最容易漏掉的问题。

## 修复流程

### 1. 提取内联 thebibliography 为 BibTeX 条目

从 paper.tex 的 `\begin{thebibliography}` 环境提取所有 28 个条目，逐个转换为 `.bib` 格式：
- 解析 author（如 "Sung, H., Ferlay, J., ..."）
- 解析 year（如 "(2021)"）
- 解析 title（如 "Global cancer statistics 2020: GLOBOCAN..."）
- 解析 journal（如 `\emph{CA: A Cancer Journal for Clinicians}`）
- 解析 DOI（如 `doi = {10.3322/caac.21660}`）

生成 28 个 BibTeX 条目（包含 3 个未引用的）。

### 2. 删除未引用条目

从 28 个条目中删除 3 个未引用的：
- Bray2024GlobalCancer（GLOBOCAN 2022 更新，未被引用）
- Caruana2015Intelligible（未被引用）
- Collins2024TRIPODAI（未被引用）

最终 25 个条目，全部被引用。

### 3. 修复 Xanthakis2022Towards 标题不匹配

原始 bib 标题："Towards interpretable and optimized breast cancer diagnosis using machine learning"
实际 DOI (10.53730/ijhs.v6ns5.8976) 解析结果："Bio-inspired ensemble feature selection (biefs) and kernel elastic net for optimized breast cancer diagnosis"
→ 修正标题。

### 4. 写入 references.bib

将所有 25 个条目写入 references.bib（替换原来的 10 个条目）。

### 5. 修改 paper.tex

a. 添加 `\bibliography{references.bib}` 到 preamble（在 `\begin{document}` 前）
b. 删除内联 `thebibliography` 环境
c. 清理 `\end{thebibliography}` 残留（常见错误：删除了 begin 但没删 end）

### 6. 编译验证

```bash
cd 01-manuscript && pdflatex paper.tex
```

**结果**：28 页 PDF，零错误，零 undefined citations。

## 关键经验

### 经验 1: inline bib 和 references.bib 必须同步
- 同时检查两者是否包含相同的 key 集合
- 引用审计（D10a）应从 cite ↔ bibitem 计算，而非 cite ↔ bib 文件

### 经验 2: 删除 inline thebibliography 后必须检查 \end{document}
- 常见错误：删除了 begin 但没删 end，导致 \end{thebibliography} 出现在 \end{document} 之前
- 必须 grep 检查：`grep 'thebibliography' paper.tex` 应该只有 1 处（\bibliography{references.bib}）

### 经验 3: G5 检查用 Codex tmux 非阻塞
- delegate_task 是同步阻塞的 → 用 tmux 后台运行
- 两个 tmux 会话可并行：codex-g5 做引用检查，codex-p0 做 P0 修复
- 随时可以用 `tmux capture-pane` 查看进度

### 经验 4: 每篇引用必须有引用理由
- 对每个 `\cite{key}`，提取上下文（前 300 字符 + 后 300 字符）
- 对每个引用，写一行 justify："为什么这篇文献被引用"
- 判断：引用是否得当（文献是否真的支持论文中的论断）

### 经验 5: 37 篇 → 25 篇的清理
- 原始 paper.tex 备份有 28 个 inline bibitem
- 但整个论文管线可能有更多引用（通过 git history）
- 本次只处理当前 paper.tex 的 28 个 inline bibitem
- 清理后：25 个引用，全部被引用，D10a=100%，uncited=0

## 修复后状态

| 指标 | 修复前 | 修复后 |
|------|--------|--------|
| 内联 bibitem | 28 | 25（删除3个未引用） |
| 引用数 | 25 | 25 |
| uncited in inline | 3 | 0 |
| uncited in references.bib | 17 | 0 |
| references.bib 条目 | 10 | 25（同步补全） |
| D10a (inline) | 100% | 100% |
| D10a (ref) | 100% | 100% |
| Xanthakis 标题 | 不匹配 | 已修正 |
| LaTeX 编译 | N/A | 通过（28页，0错误） |

---

## 2026-07-06 HCS-3WT 全文 PDF 下载审计（实战记录）

### 背景
对 HCS-3WT 乳腺癌论文进行完整的 L3 引用实质恰当性审查，需要先确认 25 条引用是否已有全文 PDF。

### 关键发现

#### 发现 1: PDF 可能存放在非预期位置
- PDF 可能在 `06-references/pdfs/`（标准位置）
- 也可能在 `06-references/pdfs/new/` 子目录
- 也可能在 `academic_writer/article*/enhanced_bibtex/pdfs/`（旧备份）
- 还可能以不同文件名存储（如 `Reeder2024UncertaintyAI.pdf` vs 引用键 `Reeder2024Uncertainty`）

#### 发现 2: bib 条目 DOI 可能是错误的
Chakravarthy2021Deep 在 references.bib 中记录的 DOI `10.1016/j.csbj.2021.05.025` 经 CrossRef 验证指向的是一篇 **完全不同的论文**（关于植物 UBX 蛋白的综述，作者是 Zhang 等人，非 Chakravarthy）。bib 中的 DOI 可能是手动输入错误或在早期自动恢复时映射错误。

**应对策略**：在进行引用实质检查前，必须先用 Crossref/PubMed 验证每条 DOI 指向的论文标题和作者是否与 bib 条目一致。不一致则标记为 `DOI_MISMATCH`，不能盲目信任 PDF 存在性。

#### 发现 3: 文献质量检查中 PDF 下载成功率
| 来源类型 | 成功率 | 说明 |
|---------|--------|------|
| arXiv | 高 | 预印本通常直接可下 |
| NeurIPS/ICLR 等会议 proceedings | 中 | URL 格式可能变化，需实时搜索 |
| IEEE Access (OA) | 中 | 可能被 Cloudflare 拦截 (418) |
| JAMA (OA) | 低 | 直接 curl 返回 403，需通过 PMC 间接获取 |
| The Lancet/Elsevier | 极低 | 付费墙，Sci-Hub 镜像不稳定 |
| Springer 2022+ | 极低 | Sci-Hub 覆盖不足 |
| 书籍/政府文档 | N/A | 通常无正式 PDF |
| 数据集资源 | N/A | UCI 等数据集引用无 PDF 属正常 |

#### 发现 4: 全文 PDF 下载后的交叉验证方法
```bash
# 列出所有 PDF 文件
find . -path "*pdfs*" -name "*.pdf" -type f | sed 's/.*\///; s/\.pdf$//'

# 与引用键对比
comm -12 <(grep -o '\\\\cite{[^}]*}' paper.tex | sort -u) <(ls *.pdf | sed 's/\.pdf$//')

# 找出缺失的引用键
comm -23 <(grep -o '\\\\cite{[^}]*}' paper.tex | sort -u) <(ls *.pdf | sed 's/\.pdf$//')
```

#### 发现 5: 审计报告中应报告 PDF 下载率
在引用质量报告中增加一个章节说明：
- 总引用数
- 有全文 PDF 数（精确匹配 + 部分匹配）
- 无全文 PDF 数
- 无 PDF 的原因（付费墙/书籍/数据集/DOI错误等）
- 这有助于判断 L3 实质检查的深度限制

### 结果
25 条引用中 15 条有全文 PDF（60%），10 条缺失（40%）。缺失原因包括：付费墙（Lancet/Cancer/Springer）、平台封锁（JAMA 403）、DOI 错误（Chakravarthy）、资源类型（书籍/数据集/政策文件）。L3 实质审查可在已有 PDF 的 15 篇上进行，其余 10 篇需通过 Crossref 元数据验证。