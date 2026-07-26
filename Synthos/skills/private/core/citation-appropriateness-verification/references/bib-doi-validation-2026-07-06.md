# bib DOI 验证与 PDF 交叉引用 — 2026-07-06 实战提炼

## 问题

bib 文件中的 DOI 可能是错误的——指向完全不同的论文。这会导致：
1. 通过 DOI 下载 PDF 时下载到错误文献
2. 引用实质检查（L3）基于错误文献的内容进行
3. 引用功能分类、性能基准提取全部错误

## 检测方法

### 方法 1: Crossref DOI 反向查找
```bash
curl -s "https://api.crossref.org/works/<DOI>" \
  -H "User-Agent: test@example.com" | python3 -c "
import sys, json
d = json.loads(sys.stdin.read())
item = d['message']
print(f'Title: {item.get(\"title\",[])[0]}')
print(f'Authors: {[a.get(\"family\",\"\") for a in item.get(\"author\",[])]}')
print(f'Journal: {item.get(\"container-title\",[])[0]}')
print(f'Year: {item.get(\"published-print\",{}).get(\"date-parts\",[[None]])[0]}')
"
```
将输出与 bib 中的 title/author/year 逐字比对。

### 方法 2: PubMed DOI 查找
```bash
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=<DOI>[doi]&retmode=xml"
```
如果有 PMID，再用 esummary 获取完整元数据。

### 方法 3: 标题搜索（当 DOI 完全不可用时）
```bash
curl -s "https://api.crossref.org/works?query.title=<标题关键词>&rows=3" \
  -H "User-Agent: test@example.com"
```

## 已知错误案例

### Chakravarthy2021Deep
- bib 中 DOI: `10.1016/j.csbj.2021.05.025`
- bib 中标题: "Deep learning models for breast cancer classification from histopathological images"
- bib 中作者: Chakravarthy, B.L. 等
- bib 中期刊: Computers in Biology and Medicine (但 DOI 属于 csbj = CSBJ)
- 实际 DOI 指向: "Versatile control of the CDC48 segregase..." — 植物生物学论文，作者是 Zhang 等人

**根因分析**: 这可能是早期自动恢复脚本在 DOI 映射时产生的错误。bib 条目本身信息自洽（标题、作者、期刊都是关于乳腺癌深度学习的），但 DOI 指向了完全不同的论文。

**修复建议**: 
1. 用 Crossref 标题搜索找到正确 DOI
2. 或者保留现有 bib 条目但将 DOI 字段设为空/标记为 `UNKNOWN`
3. 如果无法获取正确 DOI，该引用标记为 `DOI_INVALID`

## PDF 交叉引用脚本

```bash
# 找出 bib key 到 PDF 文件名的映射
find . -path "*pdfs*" -name "*.pdf" -type f | sed 's/.*\///; s/\.pdf$//' | sort > /tmp/pdf_names.txt
grep -oP '\\\\cite\{[^}]+\}' paper.tex | sort -u > /tmp/cite_keys.txt
comm -12 /tmp/cite_keys.txt /tmp/pdf_names.txt
```

注意：PDF 文件名可能与 bib key 不完全一致（如 `Sung2021GlobalBC` vs `Sung2021Global`），需要部分匹配。

## 审计报告中应报告

在 L3 引用审查报告中增加 "PDF 下载情况" 章节：
- 有全文 PDF: N/M (百分比)
- 有全文但 DOI 可疑: K 篇（需二次验证）
- 无全文 PDF: 原因分类（付费墙/书籍/数据集/DOI错误）
- L3 实质检查的深度限制说明