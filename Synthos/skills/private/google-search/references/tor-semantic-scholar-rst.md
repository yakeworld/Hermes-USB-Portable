# Tor + Semantic Scholar 访问失败诊断实录

## 时间
2026-07-08

## 问题
通过 Docker Tor 容器访问 Semantic Scholar API 时，返回 `Connection reset by peer` (RST)，而非预期的 HTTP 429。

## 环境
- Docker 容器: `tor-with-pt` (torproject/tor:latest 定制镜像)
- 状态: healthy, 100% bootstrapped
- SOCKS5: 127.0.0.1:9050
- 宿主机出口 IP: 64.23.234.118（被封）

## 诊断过程

### 1. Tor 电路是否建立
```
docker logs --tail 20 tor
# 输出: Bootstrapped 100% (done): Done
# Tor 电路确实建立了
```

### 2. 容器出口 IP（直接访问，不走 Tor）
```
docker exec tor curl -s http://httpbin.org/ip
# 返回: {"origin": "64.23.234.118"}
# 容器走宿主机网络，不走 Tor
```

### 3. 通过 Tor SOCKS5 测试连通性
```python
import socks, socket
socks.set_default_proxy(socks.SOCKS5, '127.0.0.1', 9050)
s = socket.socket()
s.connect(('1.1.1.1', 53))
# 能连通 → Tor SOCKS5 端口正常
```

### 4. 通过 Tor SOCKS5 访问 S2
```python
socks.set_default_proxy(socks.SOCKS5, '127.0.0.1', 9050)
socket.socket = socks.socksocket
urllib.request.urlopen('https://api.semanticscholar.org/...')
# 返回: Connection reset by peer (RST)
```

### 5. 本机直连 S2（不用 Tor）
```
curl -H "X-API-Token: ..." https://api.semanticscholar.org/...
# 返回: HTTP 429 (Rate limit)
```

## 关键发现

| 路径 | 结果 | 含义 |
|------|------|------|
| 本机直连 S2 | 429 (HTTP) | IP 级别的速率限制，网络连通 |
| Tor → S2 | RST (TCP) | S2 检测 Tor exit IP 并网络层封锁 |
| 容器直连出口 | 64.23.234.118 | 容器流量未走 Tor，走宿主机网络 |
| 本机出口 | 64.23.234.118 | 被封 IP |
| NYC VPS 出口 | 122.228.47.138 | 可能未被封，但未走 exit node |

## 结论

1. S2 对 Tor exit IP 使用 **TCP 层封锁**（RST），不是 HTTP 429 限流
2. Tor 出口 IP 同时被 GFW 干扰（连接经常 RST）
3. 通过 Tor 访问 S2 的结论：**不可行**
4. S2 限流只能通过等待配额恢复或申请新 API key 解决

## 诊断技巧

### 判断 S2 限制类型的快速方法
```bash
# 直连
curl -s -o /dev/null -w "%{http_code}" -H "X-API-Token: $KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/search?query=test&limit=1"
# 429 = 速率限制（等配额）
# 200 = 正常
# 连接超时/失败 = 网络问题
```

### 判断 Tor 出口 IP 是否被封
```python
# 通过 Tor 访问 S2
socks.set_default_proxy(socks.SOCKS5, '127.0.0.1', 9050)
socket.socket = socks.socksocket
try:
    urllib.request.urlopen('https://api.semanticscholar.org/...')
except:
    pass

# 对比直连
import urllib.request as u
try:
    code = u.urlopen('https://api.semanticscholar.org/...').getcode()
except Exception as e:
    code = str(e)

# 直连 429 + Tor RST = S2 封 Tor exit IP
```

### Docker Tor 容器出口流量问题
Docker 容器默认使用宿主机网络命名空间，所有 HTTP 请求走宿主机路由，**不走 Tor 电路**。要真正通过 Tor：
- 使用 `proxychains` 包裹 curl
- 设置 `http_proxy`/`https_proxy` 环境变量指向 Tor 的 HTTP 代理
- 使用 `--network` 隔离容器，强制流量走 Tor 网关