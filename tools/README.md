# Portable Tools for Hermes Agent

Standalone tools that extend Hermes with local AI, literature search, PDF download, and proxy rotation capabilities.

## Tools Included

| Tool | Description | Source | Size |
|:-----|:------------|:-------|:-----|
| `opencode-cli/opencode` | OpenCode AI agent (default entry, Go single binary, MIT) | [opencode-ai/opencode](https://github.com/opencode-ai/opencode) | ~170MB |
| `opencode-openai` | Local OpenAI-compatible API proxy → uses free OpenCode Zen models | [yakeworld/opencode-openai](https://github.com/yakeworld/opencode-openai) | ~10MB |
| `jabkit(-rs)` | Multi-source academic literature search (25 providers) | [yakeworld/jabkit-rs](https://github.com/yakeworld/jabkit-rs) | ~3.5MB |
| `doi-fetch` | PDF download with 4-tier cascade fallback | [yakeworld/doi-fetch](https://github.com/yakeworld/doi-fetch) | ~11MB |
| `rproxy` | HTTP/SOCKS5 proxy rotation for anti-crawler bypass | [yakeworld/rproxy](https://github.com/yakeworld/rproxy) | ~9MB |

## OpenCode CLI

`opencode-cli/opencode` is the default chat entry point (menu [1]). It is downloaded
from the npm platform package (`opencode-<platform>@<version>`) which always carries
the latest release with native skill support. The launcher:

1. Starts the Local AI proxy (free models) if not running
2. Links all 156 Synthos skills into opencode's skill discovery path (`~/.agents/skills/`)
3. Writes a portable `opencode.json` pointing at `http://127.0.0.1:8787/v1`

## First Download

Run the platform-specific download script:

- **Windows**: `tools/windows-x64/download-tools.ps1`
- **Linux**: `tools/linux-x64/download-tools.sh`

Or launch Hermes and use the menu option to auto-download.

## Local AI (opencode-openai)

`opencode-openai` converts [OpenCode Zen](https://opencode.ai) free API into a standard OpenAI-compatible endpoint:

```bash
opencode-openai --port 8787 --api-key public
curl http://127.0.0.1:8787/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4-flash-free","messages":[{"role":"user","content":"Hi"}]}'
```

No API key needed with `--api-key public` — uses free models automatically.

## macOS

macOS x64 and ARM64 download scripts are in `tools/macos-x64/` and `tools/macos-arm64/`.
Binaries for these platforms will be available once the CI release workflow runs (push a tag `v*` to any tool repo).
