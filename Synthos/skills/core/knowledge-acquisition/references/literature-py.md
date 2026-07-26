# literature.py search — 多源聚合备选

当需要跨源自动去重聚合时，用 `literature.py` 替代 jabkit 的单源搜索。

## 用法

```bash
literature search <topic> --sources crossref pubmed openalex --max 15
```

## 与 jabkit 对比

| | jabkit | literature.py search |
|---|---|---|
| 源数 | 26 | 6 |
| 多源聚合 | 手动 | 自动去重排序 |
| 输出 | BibTeX | JSON（需转 BibTeX） |
| 速度 | 慢（Java启动） | 快 |
| 场景 | 精准单源搜索 | 快速跨源摸底 |

## 典型场景

- 需要快速了解一个领域 → `literature search`
- 精确查找某篇论文 → `jabkit fetch --provider=Crossref --query="doi:..." --porcelain`
- 系统性文献综述 → jabkit 逐个搜多源，手动合并
