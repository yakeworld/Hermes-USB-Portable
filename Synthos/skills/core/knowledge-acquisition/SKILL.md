---
name: knowledge-acquisition
category: core
version: 7.0.0
entrypoint_type: cognitive-atom
entrypoint_desc: "检索 → 下载 → 入库"
signature: "query/DOI -> bibliography + PDF + import"
description: "检索(jabkit-rs) → 下载(doi-fetch) → 入库(lit-import)"
io_contract:
  input: "query: str (关键词), source: str (检索源)"
  output: "bibliography: BibEntry[], pdf: Path, import_status: str"
metadata:
  synthos:
    priority: P0
    atom_type: cognitive-atom
    related_skills: ["knowledge-extraction", "pdf-to-markdown", "lit-import"]
triggers:
  - 需要搜索学术文献
  - 有DOI需要下PDF
  - "找一下XX方面的文献"
---

# 知识获取

三步闭环：**检索** → **下载** → **入库**

## IO_CONTRACT

- **input**: `query: str` — 关键词或DOI；`source: str` — 检索源（默认 Crossref）
- **output**: `bibliography: BibEntry[]` — BibTeX 条目列表；`pdf: Path` — PDF 文件路径；`import_status: str` — 入库结果
- **constraints**: 检索超时 30s，下载超时 30s/篇

---

## 1. 检索 → `jabkit-rs fetch`

唯一入口。26 源统一 CLI，<1s 启动，~10MB 内存。

```bash
# 最常用源（无 key）
jabkit-rs fetch --provider=Crossref --query="topic" --porcelain
jabkit-rs fetch --provider=arXiv    --query="topic" --porcelain

# 有 key 源
jabkit-rs fetch --provider=PubMed          --query="topic" --porcelain
jabkit-rs fetch --provider=SemanticScholar --query="topic" --porcelain
jabkit-rs fetch --provider=OpenAlex        --query="topic" --porcelain

# 从已有参考文献补 DOI → BibTeX
jabkit-rs doi-to-bibtex --doi 10.xxx/xxxxx
jabkit-rs get-by-id --id PMID:12345678
```

**无 key 可用源（6）：** Crossref, arXiv, DBLP, DOAJ, EuropePMC, INSPIRE, CiteSeerX
**有 key 可用源：** PubMed, SemanticScholar, OpenAlex, Scopus, IEEE, Springer, ACM 等

---

## 2. 下载 → `doi-fetch`

唯一入口。自动 4 级级联降级（bban.top → Sci-Hub → LibGen → Anna's Archive）。

```bash
doi-fetch <DOI> -o path/to/output.pdf
doi-fetch <DOI> -o path/to/output.pdf --no-proxy    # 直连
```

`doi-fetch` 内建 rproxy 代理轮换（--proxy-pool），不暴露降级细节。

---

## 3. 入库 → `lit-import`

将检索 BibTeX 追加到本地文献库：

```bash
jabkit-rs fetch --provider=Crossref --query="topic" --porcelain | \
  lit-import --library ~/refs/topic.bib --download-pdf ./pdfs
```

详见 `lit-import` skill。

---

## 全流程示例

```bash
# 一条命令完成搜索→入库→下载
jabkit-rs fetch --provider=Crossref --query="posterior canal BPPV simulation" --porcelain | \
  lit-import --library ~/refs/bppv.bib --download-pdf ~/refs/pdfs/
```

---

## 来源与安装

```bash
# jabkit-rs — Rust 编译。源码 + 编译
git clone https://github.com/yakeworld/jabkit-rs.git
cd jabkit-rs && cargo build --release
cp target/release/jabkit-rs ~/.local/bin/

# doi-fetch — Rust 编译。源码 + 编译
git clone https://github.com/yakeworld/doi-fetch.git
cd doi-fetch && cargo build --release
cp target/release/doi-fetch ~/.local/bin/

# lit-import — Python pip 包
pip install git+https://github.com/yakeworld/lit-import.git
```

预编译二进制在 `~/.local/bin/`。

## 回退方案（jabkit-rs 不可用时）

仅当 `which jabkit-rs` 返回空时使用：

```bash
# PubMed E-utilities curl 直调（见 standalone-literature-search skill）
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=<query>&retmode=json&retmax=5"
```

---

## 常见 Pitfalls

| 问题 | 解决 |
|------|------|
| jabkit-rs 无输出 | 检查 `--porcelain` 是否加（不加则输出表格，管道会断） |
| doi-fetch 返回 NO_IFRAME | bban.top CDN 无此论文 → 新论文走 OA 直链或 MedData |
| bban.top 429 | `doi-fetch` 内建 rproxy 自动轮换，或加 `--no-proxy` 直连重试 |
| SemanticScholar 429 | 加间隔 2s 重试，或切 Crossref/PubMed |
| 2024+ 新论文不在 Sci-Hub | 用 OA 直链（Frontiers/PLOS/BMC 等自动可下）或 MedData |
| PDF 下载后非真实 PDF | `head -c 5 file.pdf` 检查是否为 `%PDF-` |

---

## 参考文件

- `references/download-pitfalls.md`

## 相关技能

- `knowledge-extraction` — 从 PDF 提取结构化知识
- `pdf-to-markdown` — PDF 转可读文本
- `standalone-literature-search` — 无 jabkit-rs 的回退方案
- `lit-import` — BibTeX 去重入库
