---
name: paper-literature-supplement
category: pipeline
description: "论文文献补充管道 — ACQ→EXT→下载→质检。输入论文目录，输出补齐至30篇引用+PDF。"
version: 2.0.0
chain:
  - knowledge-acquisition
  - knowledge-extraction
  - download
  - quality-gate
---

# Paper Literature Supplement — 论文文献补充管道

> 凡文必配30引。不足则补，缺源则索。

## 检索（唯一入口）

```bash
jabkit-rs fetch --provider=Crossref --query="query" --porcelain
jabkit-rs fetch --provider=PubMed --query="query" --porcelain
```

多聚类搜索：每方向 1 次 `jabkit-rs fetch`，结果合并去重。

## 下载（唯一入口）

```bash
doi-fetch <DOI> -o 06-references/pdfs/<safe_name>.pdf
```

## 引用格式

inline thebibliography（71%）和 .bbl（29%）两种。优先读 .bbl，没有则解析 paper.tex 内的 `\\bibitem`。

## 哲学约束

- **一维一修** — 文献检索只有一条路：jabkit-rs fetch。不写第二个。
- **凡数必源** — 每个数据点可追溯到原始论文或代码输出。
- **去形留神** — 管道产出的是可用的 PDF + 可编译的 tex，不是中间文件。
- **运行即证** — 每步执行后验证，不通则停。

## 管道流程

```
输入: 论文目录 (含 paper.tex)
│
├─ Step 1: ACQ — 文献检索
│   jabkit-rs fetch --provider=Crossref --query="关键词" --porcelain
│   jabkit-rs fetch --provider=PubMed --query="关键词" --porcelain
│   → 候选论文（BibTeX）
│
├─ Step 2: EXT — 提取引用
│   从 paper.tex 解析 \\bibitem{key} + DOI
│   查 .bbl（有）或 paper.tex 内联（无 .bbl）
│   → 已有引用列表
│
├─ Step 3: 全文下载
│   doi-fetch <DOI> -o 06-references/pdfs/<safe>.pdf
│   → PDF 文件
│
├─ Step 4: 验证引用
│   jabkit-rs doi-to-bibtex --doi <DOI> 验证 DOI 有效性
│   → 修正错误匹配
│
├─ Step 5: quality-gate
│   D8: 引用完整性 ≥ 80%
│   D10a: bib-tex 匹配 ≥ 90%
│   无 undefined citation
│
└─ 输出: 补齐至 30+ 篇引用
```

## 调用方式

```bash
# 检索
jabkit-rs fetch --provider=Crossref --query="topic" --porcelain

# 下载
doi-fetch <DOI> -o paper.pdf
```

## MedData 搜索集成（2026-07-12 验证）

MedData 支持全文关键词搜索，返回真实 PMID → 可下载真实 PDF。已完整验证 5/5 成功。

### 完整流程（Python）

```python
# 1. SSO → token → 搜索 → 获取 PMID
body = {"exp":"bppv nystagmus","current":1,
        "filter":[{"searchWorld":50,"searchValueList":[]}],
        "filterRang":[],"token":token,"conn":0}
url = f"http://www.meddata.com.cn/api/result/search?current=1&size=10&token={token}"
# → 返回 records: [{pmid, doi, articleTitle, abstractText}]

# 2. full_look(pmid=真实PMID, doi=DOI) → status=2, fileName=xxx
# 3. wait 10s → viewtext(fileName=xxx) → 真实 PDF ✅
```

### 已验证
- 5/5 全部返回真实 PDF（187KB~5299KB）
- 无 DOI 仅 PMID 也能下载
- SPA 页面的 REST API，不需要浏览器

### 注意
- `~/.secrets` 密码可能被截断。验证：`echo ${#MEDDATA_PASSWORD}` 应 ≥ 6
- `pmid=1` 不工作（占位 PDF）。必须用真实 PMID
- 搜索接口返回的 DOI 可能带 HTML 高亮标签 `<span style='color:#F2A620'>`

## 陷阱

1. **不要写批量脚本** — 每篇论文单独处理。83 篇批量被证实不可行。
2. **S2 限流** — literature.py 含 S2 时 429 阻塞 60s+。去掉 S2 用 crossref+pubmed。
3. **CDN 命中率 ~10%** — 2020+ 新论文不在 CDN 上。接受低命中率。
4. **delegate_task 不加微操** — 只传 goal（用户原话），不加 context 指令。
5. **无 PDF 的引用一律删除** — 保留引用数不低于 20 篇即可。
6. **Crossref 自动匹配不可靠** — 一个查询可能返回完全不相关的论文。必须人工核对标题和年份。
7. **context-compression 阈值** — 当前配置 700K/1M（threshold=0.7），不要手动改 config.yaml，用 `hermes config set`。
