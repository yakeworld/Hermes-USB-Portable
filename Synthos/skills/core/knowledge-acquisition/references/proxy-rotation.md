# 代理轮换下载

rproxy(Rust): 代理采集/验证/轮换三合一。

```
rproxy collect -o proxies.txt
rproxy scan -i proxies.txt -a -t 200 -o alive.txt
rproxy exec -i alive.txt -- literature download -i papers.json
```

每次exec自动换下一个代理，失败重试，状态持久化(~/.rproxy_state)。
一键管线: rproxy-pipeline <topic>
局限: 免费代理存活率~5%，需频繁重扫。部分HTTP代理不支持HTTPS CONNECT。
