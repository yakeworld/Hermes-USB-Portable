# API Keys

| 源 | 环境变量 | 存储 |
|----|---------|------|
| Semantic Scholar | `SEMANTIC_SCHOLAR_API_KEY` | ~/.bashrc + ~/.secrets + hermes.env |
| PubMed | `NCBI_API_KEY` | ~/.bashrc + ~/.secrets |
| OpenAlex | `OPENALEX_API_KEY` | ~/.bashrc + ~/.secrets |
| Scopus | `SCOPUS_API_KEY` | ~/.secrets |

恢复: `source ~/.bashrc && source ~/.hermes/hermes.env`

S2单key: s2k-格式44字符，无fallback。JabRef S2 bug(不设x-api-key->429)，workaround用jbang SemanticSearch.java。
