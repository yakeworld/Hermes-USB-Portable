# <p align="center">🛸 Hermes Agent — 便携跨平台 AI 代理</p>

<p align="center">
  <img src="https://img.shields.io/badge/Hermes_Agent-Portable-8A2BE2?style=for-the-badge&logo=ai" alt="Hermes Agent Portable">
  <img src="https://img.shields.io/github/license/NousResearch/hermes-agent?style=for-the-badge&color=2563EB" alt="License">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-059669?style=for-the-badge" alt="Platforms">
</p>

---

<p align="center">
  <strong>一个文件夹/U盘即可运行完整的 AI 代理。</strong><br>
  零安装、零污染。对话、配置、记忆、技能全部在文件夹内。
</p>

---

## ✨ 核心特性

*    **零依赖** — 目标电脑无需预装 Python、Node.js、包管理器。运行时自动下载。
*    **100% 便携** — 复制到 U 盘或移动硬盘，插到任何 Windows/macOS/Linux 电脑即用。
*    **隐私隔离** — API Key（`data/.env`）、聊天记录、记忆、技能全部在便携文件夹内。
*    **交互式启动器** — 带状态面板的终端 UI，显示运行时、AI 服务、Synthos 技能状态。
*    **集成工具** — 内置 `opencode-openai`（本地 AI，免费模型无需 API Key）、`jabkit`（文献检索）、`doi-fetch`（PDF 下载）、`rproxy`（代理轮换）。
*    **Synthos 认知引擎** — 首次运行自动克隆 [Synthos](https://github.com/yakeworld/Synthos)，156 个技能覆盖：文献检索、知识提取、质量闸门、研究空白分析、假说生成。
*    **本地 AI 一键启动** — 菜单 [6] 启动本地 AI 代理，自动配置 config.yaml 指向 `http://127.0.0.1:8787/v1`。

---

## ⚡ 快速开始

### Windows (10 / 11)
双击 **`launch.bat`** 即可。
> *首次运行将自动下载 (~600MB) 运行时 + 克隆 Synthos + 下载工具。*

### macOS & Linux
```bash
chmod +x launch.sh
./launch.sh
```

> 💡 macOS 上重命名为 `launch.command` 即可双击运行。

### 使用本地 AI（无需 API Key）

```bash
# 启动启动器 → [7] 下载工具 → [6] 启动本地 AI → [1] 开始对话
# 无需手动配置 config.yaml，启动器自动写入
```

---

## 🧠 本地 AI（无需 API Key）

`opencode-openai` 将 [OpenCode Zen](https://opencode.ai) 的免费 API 转换为标准 OpenAI 兼容接口。**无须 API Key。**

### 启动方式

启动器菜单中选 **[6] Start Local AI** 即可：
- 自动启动 opencode-openai（端口 8787）
- 自动写入 config.yaml 设置默认 provider
- 状态栏显示 `[OK] Running`

### 免费模型

| 模型 | 品质 | 说明 |
|:-----|:-----|:------|
| `deepseek-v4-flash-free` | ⭐ 最佳 | 默认推荐 |
| `big-pickle` | ✅ 稳定 | 通用 |
| `gpt-5.4-nano` | ⚠️ | 偶尔不稳定 |

---

## 🧬 Synthos 认知引擎

首次运行自动从 [github.com/yakeworld/Synthos](https://github.com/yakeworld/Synthos) 克隆，156 个技能作为 Hermes 外部技能加载。

### 核心技能

| 技能 | 用途 |
|:-----|:------|
| `knowledge-acquisition` | Jabkit 文献检索 → doi-fetch PDF 下载 |
| `knowledge-extraction` | 从论文提取结构化知识 |
| `quality-gate` | 论文质量评估（7 道闸门） |
| `task-router` | Synthos 入口 — 分析查询、派发原子任务 |
| `gap-analysis` | 研究空白识别 |
| `hypothesis-generation` | 从空白生成可验证假说 |
| `reference-enrichment-pipeline` | 参考文献全流程管理 |

在 Hermes 对话中用 `skill_view(name='技能名')` 加载任意技能。

---

## 📁 目录结构

```yaml
hermes-portable/
├── launch.bat                 # Windows 启动器
├── launch.sh                  # macOS/Linux 启动器
├── scripts/
│   ├── setup-windows.ps1      # 首次安装脚本
│   ├── setup-unix.sh
│   ├── download-tools.ps1     # 下载工具二进制
│   ├── download-synthos.bat   # 下载 Synthos
│   └── download-synthos.sh
├── data/                      # ⚠️ [需备份] 用户数据
│   ├── config.yaml            # LLM provider 配置
│   ├── .env                   # API Key
│   ├── sessions/              # 聊天历史
│   ├── memories/              # 持久记忆
│   └── skills/                # 自定义技能
├── tools/                     # 工具二进制（首次运行下载）
│   ├── windows-x64/
│   │   └── download-tools.ps1
│   └── README.md
├── Synthos/                   # [自动下载] 认知引擎
└── .cache/                    # 运行时缓存
```

---

## 🔑 配置 API Key（可选）

本地 AI 不需要 API Key。如需使用云模型，编辑 `data/.env`：

```env
OPENROUTER_API_KEY=sk-...
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-...
```

或在启动器中选择 [2] Setup → 交互式配置。

---

## 🖥️ 支持平台

| 系统 | CPU | 状态 |
|:-----|:----|:-----|
| Windows 10/11 | x86_64 | ✅ 支持 |
| macOS 13+ | Apple Silicon | ✅ 支持 |
| macOS 13+ | Intel | ✅ 支持 |
| Linux | x86_64 | ✅ 支持 |
| Linux | ARM64 | ✅ 支持 |

---

## 🔒 安全提示

> [!WARNING]
> `data/.env` 中存储明文 API Key，`data/sessions/` 包含对话记录。
> **建议加密 U 盘**：BitLocker（Windows）、FileVault（macOS）或 VeraCrypt。

---

## 📝 致谢

*   **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** — Nous Research 的 AI Agent 核心
*   **[Synthos](https://github.com/yakeworld/Synthos)** — 自主进化学术科研平台（156 技能）
*   **[opencode-openai](https://github.com/yakeworld/opencode-openai)** — 本地 AI 代理（OpenCode Zen → OpenAI API）
*   **[OpenCode](https://opencode.ai)** — AI 编程平台，提供免费模型
*   **[jabkit-rs](https://github.com/yakeworld/jabkit-rs)** — 多源学术文献检索（25 数据源）
*   **[doi-fetch](https://github.com/yakeworld/doi-fetch)** — PDF 下载（4 级级联降级）
*   **[rproxy](https://github.com/yakeworld/rproxy)** — 代理轮换工具
*   **[python-build-standalone](https://github.com/indygreg/python-build-standalone)** — 便携 Python 解释器
*   **[uv](https://github.com/astral-sh/uv)** — 快速 Python 包管理
