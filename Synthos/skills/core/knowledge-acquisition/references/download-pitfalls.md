# 下载故障处理

- no valid link: 非OA论文，跳过
- Timeout/429: rproxy exec自动重试
- PDF损坏: 验证前5字节是否为%PDF-
- 无全文引用一律删除
- lit-import: 空key自动补，strip()前加str()防None
