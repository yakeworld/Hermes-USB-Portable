# <p align="center">🛸 Synthos Portable — 便携科研平台</p>

<p align="center">
  <img src="https://img.shields.io/badge/Synthos-Portable-8A2BE2?style=for-the-badge&logo=ai" alt="Synthos Portable">
  <img src="https://img.shields.io/github/license/NousResearch/hermes-agent?style=for-the-badge&color=2563EB" alt="License">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-059669?style=for-the-badge" alt="Platforms">
</p>

---

<p align="center">
  <strong>一个 U 盘 = 全套科研基础设施。</strong><br>
  AI 代理 · 本地大模型 · 文献检索 · PDF 下载 · 论文写作 · 质量闸门<br>
  零安装、零依赖、零云 API Key。
</p>

---

## ✨ 核心特性

*    **全套科研管线** — 文献检索（25 数据源）→ PDF 下载 → 知识提取 → 论文写作 → 质量闸门，全流程闭环。
*    **OpenCode 原生入口** — 内置 [OpenCode](https://github.com/opencode-ai/opencode)（MIT 开源，160K+ stars）作为默认启动入口，156 个 Synthos 技能自动链接，即开即用。
*    **本地 AI** — 内置开源 AI 代理，使用免费模型，**无需 API Key**，菜单一键启动 + 自动配置。
*    **Synthos 认知引擎** — 156 个科研技能，首次运行自动克隆。覆盖：知识获取、质量评估、研究空白分析、假说生成、论证表达。
*    **零依赖** — 目标电脑无需 Python、Node.js、包管理器。运行时自动下载便携版。
*    **100% 便携** — 复制到 U 盘或移动硬盘，插到任何 Windows/macOS/Linux 电脑即用。
*    **隐私隔离** — API Key、对话、记忆、技能全部在文件夹内，不触碰宿主机。

---

## 📦 内含

| 组件 | 说明 |
|:-----|:------|
| **OpenCode** | AI 编码 Agent 默认入口（MIT，Go 单二进制） |
| **Hermes Agent** | AI 代理核心（工具调用、记忆、技能系统） |
| **Synthos** | 156 个科研技能：文献检索/知识提取/质量闸门/假说生成等 |
| **opencode-openai** | 本地 AI 代理，免费模型，零 API Key |
| **jabkit-rs** | 多源学术文献检索（25 数据源） |
| **doi-fetch** | PDF 下载（4 级级联降级） |
| **rproxy** | 代理轮换，绕开出版商封锁 |

---

## ⚡ 快速开始

### Windows
双击 **`launch.bat`**。

### macOS / Linux
```bash
chmod +x launch.sh && ./launch.sh
```

首次运行**不强制下载**——按需安装，开箱即出菜单：

| 入口 | 首次下载 | 说明 |
|:-----|:---------|:-----|
| **[1] Start OpenCode Chat** | ~200MB | opencode CLI + 科研工具，自动下载，无需 Hermes 运行时 |
| **[2] Start Hermes Chat** | ~600MB | Hermes 完整运行时（Python/Node），按需触发 |

启动后菜单操作：
```
[1] Start OpenCode Chat → OpenCode 默认入口（回车直达），156 技能自动可用
[2] Start Hermes Chat   → Hermes 对话，Synthos 技能自动可用
[7] Start Local AI      → 启动本地 AI（自动配置）
[8] Download Tools      → 下载 opencode CLI / opencode-openai / jabkit / doi-fetch / rproxy
```

### OpenCode 入口

默认启动项（菜单 [1]，回车直达）。**只需 ~200MB**（无需 600MB Hermes 运行时），首次启动自动完成：
1. 自动下载 opencode CLI + 工具（opencode-openai / jabkit / doi-fetch / rproxy）
2. 拉起本地 AI 代理（免费模型 `deepseek-v4-flash-free`，无需 API Key）
3. 将 156 个 Synthos 技能链接到 opencode 技能目录（`~/.agents/skills/`，仅便携目录内，不碰宿主）
4. 生成 `opencode.json`（指向 `127.0.0.1:8787` 本地代理）

在 OpenCode 对话中直接使用技能：
```
请加载 quality-gate 技能，对 outputs/papers/xxx 运行质量检查
用 task-router 技能分析："检索 3D nystagmus 文献"
```

### Synthos 技能调用示例

在 Hermes 对话中：
```
skill_view(name='knowledge-acquisition')     # 文献检索
skill_view(name='quality-gate')               # 论文质量闸门
skill_view(name='gap-analysis')               # 研究空白分析
skill_view(name='hypothesis-generation')      # 假说生成
skill_view(name='paper-pipeline')             # 论文管线
```

---

## 🧠 本地 AI（无需 API Key）

菜单 [6] Start Local AI → 自动启动 + 配置。默认使用免费模型 `deepseek-v4-flash-free`，支持工具调用和编码任务。

---

## ⚙️ 首次运行流程

```
launch.bat
  ├─ Hermes 运行时不存在 → setup-windows.ps1（下载 Python/Node.js/Git）
  ├─ Synthos 不存在      → git clone + 自动注入 config.yaml
  ├─ 工具不存在          → download-tools.ps1
  └─ 菜单就绪
        ├─ [6] Start Local AI → 启动 AI + 自动写 config.yaml
        └─ [1] Start Chat     → Hermes + 156 Synthos 技能
```

---

## 📁 目录结构

```
synthos-portable/
├── launch.bat / launch.sh    # 启动器
├── scripts/                    # 安装与下载脚本
├── data/                       # ⚠️ 用户数据（需备份）
├── tools/                      # 工具二进制（首次运行下载）
├── Synthos/                    # [自动克隆] 156 个科研技能
├── src/hermes-agent/           # [自动下载] Hermes 源码
└── .cache/                     # 运行时缓存
```

---

## 🖥️ 支持平台

| 系统 | CPU | 状态 |
|:-----|:-----|:------|
| Windows 10/11 | x86_64 | ✅ |
| macOS 13+ | Apple Silicon / Intel | ✅ |
| Linux | x86_64 / ARM64 | ✅ |

---

## 🔒 安全提示

> [!WARNING]
> `data/.env` 含明文的 API Key。**建议加密 U 盘**（BitLocker / FileVault / VeraCrypt）。

---

## 📝 致谢

*   **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** — AI 代理核心 (Nous Research)
*   **[Synthos](https://github.com/yakeworld/Synthos)** — 自主进化学术科研平台（156 技能）
*   **[opencode-openai](https://github.com/yakeworld/opencode-openai)** — 本地 AI 代理
*   **[OpenCode](https://opencode.ai)** — 免费 AI 模型
*   **[jabkit-rs](https://github.com/yakeworld/jabkit-rs)** — 多源学术文献检索
*   **[doi-fetch](https://github.com/yakeworld/doi-fetch)** — PDF 下载
*   **[rproxy](https://github.com/yakeworld/rproxy)** — 代理轮换
*   **[python-build-standalone](https://github.com/indygreg/python-build-standalone)** — 便携 Python
*   **[uv](https://github.com/astral-sh/uv)** — 快速包管理
