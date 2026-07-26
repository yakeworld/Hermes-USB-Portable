---
name: workstation-onboarding
category: devops
description: "研究生工作站环境配置 + Windows 便携绿色软件分发 — 覆盖远程 Linux 工作站搭建和 Windows 零依赖便携包构建"
version: 2.0.0
author: Synthos
license: MIT
metadata:
  synthos:
    priority: P2
    atom_type: skill
    signature: "workstation-onboarding -> processed_result"
    related_skills:
---

- codex-install-guide
      - docker-vllm-troubleshoot
      - hermes-agent

# Workstation Onboarding — 工作站配置与便携分发

## 触发条件
## 契约层 · IO_CONTRACT

**输入**：请求描述、上下文信息。
**输出**：执行结果、状态反馈。

1. 需要在远程工作站（如 work1/work2/work3）上为新研究生建立独立的开发与科研环境
2. 需要为 Windows 用户制作"解压即用"的便携绿色软件包

## 前置条件

- 工作站已创建操作系统用户账号（`sudo useradd -m -s /bin/bash -c '姓名拼音' 用户名`）
- 本地有 `sshpass` 用于初次密钥部署（或已有 SSH key 免密登录）
- 学生已有 `python3`（目标系统至少 Python 3.11+）

## 标准配置流程（Linux 远程工作站）

### Phase 1: 基础环境

```bash
ssh 用户名@主机名

mkdir -p ~/workspace ~/projects ~/data ~/scripts
mkdir -p ~/workspace/eye-tracking ~/workspace/papers
mkdir -p ~/projects/研究项目名
mkdir -p ~/data/raw ~/data/results ~/data/datasets
```

### Phase 2: Python 科学计算栈

```bash
# 安装 uv（推荐，快于 pip/pipx）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 创建 venv + 安装核心库
cd ~/workspace/[项目名]
uv venv .venv
source .venv/bin/activate
uv pip install numpy scipy opencv-python matplotlib pandas jupyter scikit-learn
```

### Phase 3: Codex CLI (OpenAI Codex)

```bash
# 安装 nvm + Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts

# 安装 Codex
npm install -g @openai/codex
```

### Phase 4: Codex 配置

创建 `~/.codex/config.toml`：

```toml
model = "模型名"
model_provider = "vllm"

[model_providers.vllm]
name = "vLLM"
env_key = "VLLM_API_KEY"
base_url = "http://localhost:8000/v1"
wire_api = "responses"

[projects."/home/用户名"]
trust_level = "trusted"

[projects."/home/用户名/workspace"]
trust_level = "trusted"

[projects."/home/用户名/projects"]
trust_level = "trusted"

[ask_for_approval]
policy = "never"

[sandbox]
mode = "danger-full-access"

[shell_environment_policy]
inherit = "all"
```

环境变量（如 vLLM 在本地且无需认证，API key 随意填）：

```bash
echo 'export VLLM_API_KEY=***' >> ~/.bashrc
```

### Phase 5: Hermes Agent

```bash
pipx install hermes-agent
```

配置 `~/.hermes/config.yaml`：

```yaml
model:
  default: qwen3.6-35b-nvfp4
  provider: custom:local

custom_providers:
  - name: local
    base_url: http://localhost:8000/v1
    api_key: EMPTY
    model: qwen3.6-35b-nvfp4

agent:
  max_turns: 150
  gateway_timeout: 1800
  tool_use_enforcement: auto
```

### Phase 6: 培养方案与入门指南

```bash
cp 培养方案.md ~/workspace/

cat > ~/workspace/START_HERE.md << 'EOF'
# 用户名·研究方向入门

## 登录信息
- 服务器: ssh 用户名@主机名
- 密码: 首次登录后自行修改

## 目录结构
- ~/workspace/ — 工作区
- ~/projects/ — 代码仓库
- ~/data/ — 数据文件

## Python 环境
source ~/workspace/项目名/.venv/bin/activate

## 第一步任务
1. 阅读培养方案
2. 配置 GitHub SSH Key
3. 跑通第一个 demo
EOF
```

### Phase 7: 验证 + 交付报告

```bash
# 1. 创建 codex 一键启动脚本
cat > ~/codex-vllm.sh << 'SCRIPT'
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
export VLLM_API_KEY=***
EXTRA_ARGS="--skip-git-repo-check --disable hooks -c sandbox.mode=danger-full-access"
if [ $# -ge 1 ]; then exec codex exec $EXTRA_ARGS "$@"
else exec codex exec $EXTRA_ARGS; fi
SCRIPT
chmod +x ~/codex-vllm.sh

# 2. 验证 Hermes
hermes chat -q "Write a Python function to compute 3D pupil normal from ellipse (cx,cy,a,b,theta). Only output code." -Q

# 3. 验证 Codex
./codex-vllm.sh "Generate noisy ellipse data, fit with OpenCV, save plot to /tmp/verify.png"

# 4. 验证科学计算栈全部可用
source ~/workspace/eye-tracking/.venv/bin/activate
python -c "
import numpy as np, cv2, matplotlib, pandas as pd, sklearn, scipy, seaborn, PIL
np.array([1,2,3]); cv2.imwrite('/dev/null', np.zeros((10,10)))
matplotlib.pyplot.figure(); pd.DataFrame(); sklearn.preprocessing.StandardScaler()
print('ALL OK')
"
```

## 验证清单

| 项目 | 验证命令 | 预期结果 |
|:-----|:---------|:---------|
| Python | `python3 --version` | 3.11+ |
| uv | `uv --version` | 有输出 |
| 科学计算库 | `source ~/workspace/项目名/.venv/bin/activate && python -c "import numpy, cv2, matplotlib, pandas, sklearn, scipy"` | 无错误 |
| bashrc PATH | `grep '\.local/bin' ~/.bashrc` | 包含 `$HOME/.local/bin:$PATH` |
| nvm 加载 | `grep 'nvm.sh' ~/.bashrc` | 包含 `source "$NVM_DIR/nvm.sh"` |
| VLLM_API_KEY | `grep VLLM_API_KEY ~/.bashrc` | 已 export |
| Codex 版本 | `source ~/.nvm/nvm.sh && codex --version` | 有版本号 |
| Codex 功能 | `export VLLM_API_KEY=*** && cd /home/用户名 && codex exec --skip-git-repo-check --disable hooks -c sandbox.mode=danger-full-access 'print("ok")' < /dev/null` | 成功生成并执行代码 |
| vLLM 连通性 | `curl -s http://localhost:8000/v1/models` | 返回模型列表 |
| Hermes 版本 | `hermes --version` | 有版本号 |
| codex-vllm.sh 脚本 | `ls ~/codex-vllm.sh` | 存在且可执行 |
| Hermes 功能 | `hermes chat -q 'test' -Q` | 正常返回 AI 响应 |
| Codex 功能 | `cd /home/用户名 && ./codex-vllm.sh 'print(\"ok\")' < /dev/null` | 成功生成并执行代码 |
| 科学计算栈(全) | `source ~/workspace/项目名/.venv/bin/activate && python -c "import numpy, cv2, matplotlib, pandas, sklearn, scipy, seaborn, PIL"` | 无错误 |
| Synthos 技能 | `ls ~/Synthos/skills/` | 目录存在且有内容 |
| Git 配置 | `git config --global user.name` | 已设置学生姓名 |
| 家目录权限 | `stat -c '%a' ~` | 750 或更宽松 |

## Windows 便携绿色软件分发

> 面向 Windows 用户——"解压即用，零安装，零系统依赖"。两种方案：

### 方案 A：在线版 `launch.bat`
首次运行自动下载运行时 (~800MB)，之后缓存到 `.cache/runtimes/`。

### 方案 B：离线版 `launch-offline.bat`
所有运行时预打包在压缩包内，完全不需要联网。

### 核心设计（参考 Hermes-USB-Portable 项目）

```
hermes-portable/
├── launch.bat              # 启动器（带交互式菜单）
├── launch-offline.bat      # 离线启动器
├── launch.sh               # Unix 启动器
├── launch-offline.sh       # Unix 离线启动器
├── scripts/
│   ├── setup-windows.ps1   # Windows 在线安装（下载运行时）
│   └── setup-unix.sh       # Unix 安装脚本
├── build-offline.sh        # 离线包构建脚本
├── data/                   # 用户数据（隔离）
├── .cache/
│   └── runtimes/windows-x64/
│       ├── python.tar.gz   # python-build-standalone
│       ├── python/         # 便携 Python
│       ├── node.zip        # 便携 Node.js
│       ├── node/           # 便携 Node
│       ├── uv              # 包管理器
│       ├── pip-packages/   # 预下载的 wheel 包
│       ├── ready.flag      # 标记安装完成
│       └── venv/           # 本地 venv
├── src/
│   └── hermes-agent/       # 源码（支持热更新）
└── README.md
```

### 关键环境隔离变量

```batch
set "PYTHONNOUSERSITE=1"
set "PYTHONHOME="
set "PYTHONPATH="
set "UV_NO_CONFIG=1"
set "UV_PYTHON=%RUNTIME_DIR%\python\python.exe"
set "APPDATA=%PORTABLE_ROOT%\.cache\windows-appdata"
set "LOCALAPPDATA=%PORTABLE_ROOT%\.cache\windows-localappdata"
set "HERMES_HOME=%DATA_DIR%"
```

### 使用 python-build-standalone

**不要用 python.org 安装**（污染系统）。用 astral-sh/python-build-standalone 预编译便携版：

```
# Windows x64 stripped (~25MB)
https://github.com/astral-sh/python-build-standalone/releases/download/20260623/cpython-3.11.15+202****0623-x86_64-pc-windows-msvc-install_only_stripped.tar.gz
```

### 参考项目

- **Hermes-USB-Portable**: https://github.com/techjarves/Hermes-USB-Portable
  - 完整的 Windows/macOS/Linux 便携方案
  - 用 python-build-standalone + 交互式终端菜单 + 状态检测
  - 我们在此基础上加入了 OpenCode CLI 支持和离线包构建

## Pitfalls

- [ ] **不要用 `pip install` 安装 Hermes** — 会污染宿主系统 Python。必须用 `python-build-standalone` + 本地 venv
- [ ] **`unregistervm --delete` 是永久删除** — 会同时删除 VDI 磁盘和注册信息，不可恢复。VM 管理只用 `VBoxManage registervm <path>` 注册即可
- [ ] **VirtualBox VRDE 需要先登录** — 即使 VRDE 端口开启了，Windows 未登录时也不接受 RDP 连接。需要通过 guestcontrol 或配置自动登录
- [ ] **NFS 很慢** — NFS 上的 `find` 可能超时。优先在本地磁盘（sda2）操作
- [ ] **Codex 沙箱报 `bwrap: Failed RTM_NEWADDR`** — v0.141+ 中 `--yolo` 已移除。通过 config 设置 `sandbox.mode="danger-full-access"`，exec 时加 `--skip-git-repo-check --disable hooks`
- [ ] **Codex 报 `Missing environment variable: VLLM_API_KEY`** — 必须在 `~/.bashrc` 中显式 export，非交互 SSH 不会自动 source bashrc，测试前需先 `source ~/.bashrc`
- [ ] **Hermes 非交互模式** — v0.15+ 用 `-q/--query`（输入）+ `-Q/--quiet`（安静模式）。`echo "x" | hermes chat` 在 piped stdin 下会进入 TUI 而非执行

## 常见问题

### Q: 工作站 vLLM 需要 API key 吗？
A: 同一台机器的本地 vLLM 通常不需要认证，API key 任意填。跨机器（如 work2→work1）需要确认。

## 交付物清单

| 文件 | 位置 | 说明 |
|:-----|:-----|:---------|
| codex 一键脚本 | `~/codex-vllm.sh` | 封装环境变量和默认参数 |
| 入门指南 | `~/workspace/START_HERE.md` | 学生首次登录引导 |
| 培养方案 | `~/workspace/*培养方案.md` | 研究方向与里程碑 |
| 工作检查报告 | `~/workspace/WORK_CHECK_REPORT.md` | 环境验收证明（generated） |
