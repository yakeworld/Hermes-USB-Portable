# Ubuntu 24.04 LTS → 26.04 LTS 升级实录

**日期：** 2026-07-13
**升级路径：** Ubuntu 24.04.4 LTS (kernel 6.8.0-134) → Ubuntu 26.04 LTS Resolute Raccoon (kernel 7.0.0-27)
**总耗时：** ~2小时（下载5.9GB + 安装3289个包）

## 前置条件

```bash
# 1. 更新当前系统到最新
sudo apt update && sudo apt upgrade -y --allow-downgrades

# 2. 确认升级工具版本
# Prompt=lts 配置只能看到 LTS 升级
# 需加 -d 参数强制检查
do-release-upgrade -c -d
# → "有新版本'26.04 LTS'可用"
```

## 升级命令

```bash
# 必须用 pty 模式（交互式，会多次询问）
sudo do-release-upgrade -d
```

## 交互式问答处理

| 提示内容 | 选择 | 理由 |
|---------|:----:|------|
| 继续升级 [yN] | `y` | 确认升级 |
| ESM 包继续 [yN] | `y` | 保持ESM包不变 |
| 继续 [yN]（5.9GB下载确认） | `y` | 确认下载 |
| 锁屏已禁用 [ENTER] | `回车` | 继续 |
| `/etc/apparmor.d/obsidian` 配置 (Y/I/N/O/D/Z) | `N` | 保留本地版本 |
| `/etc/privoxy/config` (1-7) | `2` | 保留本地版本 |
| `/etc/ssh/sshd_config` (1-7) | `2` | **必须保留本地**，否则SSH可能断连 |
| 后续所有配置询问 | 一律选保留本地 | 降低风险 |

## 关键观察

- **NVIDIA 驱动自动重建：** DKMS 编译 `nvidia/580.159.03` 针对 `7.0.0-27-generic`，无需手动干预
- **下载源：** mirrors.aliyun.com（阿里云镜像）可用，速度峰值 6.2 MB/s
- **需要重启：** 升级完成后需重启才能切换到新内核

## 注意事项

- 升级仅适用于 **24.04 LTS → 26.04 LTS**，其他路径（如 22.04 LTS）需先升级到 24.04 LTS
- 升级过程不可逆，做好备份
- NVIDIA 驱动 DKMS 编译需 kernel headers，确保已安装
- java 版本从 11/21 升级到 25（openjdk-25-jre-headless）
