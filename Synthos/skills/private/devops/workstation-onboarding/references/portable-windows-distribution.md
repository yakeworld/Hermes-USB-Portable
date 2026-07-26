# Windows 便携绿色软件分发方案

> 目标：Windows 用户"拷即用"——下载、解压、双击运行。零安装、零系统依赖、零残留。

## 核心思路

1. **下载便携版运行时**：`python-build-standalone`（非系统 Python）+ Node.js + uv + git
2. **本地 venv**：所有 pip install 只装到便携目录内
3. **环境变量隔离**：`HERMES_HOME=./data/`, `PYTHONNOUSERSITE=1`, `PYTHONHOME=`, `PYTHONPATH=`
4. **APPDATA 重定向**：Node/NPM 不写宿主系统

## 文件结构

```
hermes-portable/
├── launch.bat              # 在线启动器（首次运行下载运行时）
├── launch-offline.bat      # 离线启动器（所有依赖已内置）
├── launch.sh               # Unix 在线启动器
├── launch-offline.sh       # Unix 离线启动器
├── scripts/
│   ├── setup-windows.ps1   # Windows 首次安装（下载+解压）
│   └── setup-unix.sh       # Unix 首次安装
├── build-offline.sh        # 构建离线包的脚本
├── data/                   # 用户数据隔离目录
├── .cache/
│   └── runtimes/
│       └── windows-x64/    # 预下载的运行时
│           ├── python.tar.gz / node.zip / uv.zip / ready.flag
│           ├── python/ node/ venv/ pip-packages/
├── src/
│   └── hermes-agent/       # 源码（支持 /hermes update 热更新）
└── README.md
```

## 关键设计决策

### 为什么用 python-build-standalone

- 预编译的独立 Python 二进制，无需安装
- 约 25MB (stripped)，比 python.org 安装包更精简
- 不修改系统 PATH、不写注册表
- 支持 Windows x64 / macOS ARM64-x64 / Linux x64/ARM64

### 为什么不只用 pip install

| 方式 | 系统污染 | 便携性 | 更新 |
|------|----------|--------|------|
| pip install | 高（写系统 site-packages） | 差（需系统 Python） | pip upgrade |
| python-build-standalone | 零 | 好（自带运行时） | 替换目录 |

### 两种分发方案

**在线版** (`launch.bat`)：
- 初始包小（只有脚本）
- 首次运行下载 ~800MB
- 缓存到 `.cache/runtimes/`
- 后续使用完全离线
- 适合：好网络、USB 分发

**离线版** (`launch-offline.bat`)：
- 初始包 ~300MB（含所有依赖）
- 零网络依赖
- 适合：断网环境、内网、USB 分发

## 环境变量隔离清单

```batch
# Python 隔离
PYTHONNOUSERSITE=1        # 禁止 pip 读系统 site-packages
PYTHONHOME=               # 清除 Python Home
PYTHONPATH=               # 清除 Python Path
UV_NO_CONFIG=1            # uv 不读系统配置
UV_PYTHON=...             # 指定便携 Python

# AppData 重定向（Node/NPM）
APPDATA=...\cache\windows-appdata
LOCALAPPDATA=...\cache\windows-localappdata

# Hermes 数据隔离
HERMES_HOME=./data/       # 所有对话、记忆、技能在 data/

# PATH 前置便携目录
PATH=%VIRTUAL_ENV%\Scripts;%RUNTIME_DIR%\python;%PATH%
```

## 参考实现

- **Hermes-USB-Portable**: https://github.com/techjarves/Hermes-USB-Portable
  - 最完整的参考实现
  - 交互式终端菜单（ANSI color）
  - 状态检测（setup status, gateway status）
  - 多平台支持（win/mac/linux）
  - /hermes update 热更新
  
- **我们的改进**：加入了 OpenCode CLI 支持和离线包构建脚本

## 构建离线包命令

```bash
# 一次性下载所有依赖到目录
bash build-offline.sh /path/to/output

# 结果：hermes-portable-offline-windows-x64/
# 用户下载后解压，双击 launch-offline.bat 即可使用
```

## 已知限制

- Windows x64 专用（Linux/macOS 需要额外构建）
- 不包含 Chrome/Playwright（~400MB，太大）
- 更新需重新下载整个离线包
- 杀毒软件可能误报（尤其打包的 Python 运行时）