@echo off
REM ============================================================================
REM install-omo.bat — 安装 oh-my-openagent (omo) 多 Agent 编排插件（可选增强）
REM omo 提供多 agent 协作：主 agent 分派子 agent 并行工作
REM 来源: https://github.com/code-yeongyu/oh-my-openagent
REM ============================================================================
setlocal enabledelayedexpansion

set "PORTABLE_ROOT=%~dp0.."
set "TOOLS_DIR=%PORTABLE_ROOT%\tools"
set "OC_CONFIG_DIR=%PORTABLE_ROOT%\data\opencode-config\opencode"

REM 1. 下载 omo（从 GitHub dev 分支）
set "OMO_DIR=%TOOLS_DIR%\oh-my-openagent"
if not exist "%OMO_DIR%" (
    echo [DL] Downloading oh-my-openagent (dev branch)...
    powershell -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; $tgz='%PORTABLE_ROOT%\.cache\omo.tar.gz'; Invoke-WebRequest -Uri 'https://github.com/code-yeongyu/oh-my-openagent/archive/refs/heads/dev.tar.gz' -OutFile $tgz -TimeoutSec 120; New-Item -ItemType Directory -Force -Path '%OMO_DIR%' | Out-Null; tar -xzf $tgz -C '%OMO_DIR%' --strip-components=1; Remove-Item $tgz -Force"
    if not exist "%OMO_DIR%\package.json" (
        echo [ERR] Download/extract failed.
        pause
        exit /b 1
    )
    echo [OK] Installed to %OMO_DIR%
)

REM 2. opencode.json 启用 plugin（简单文本追加，避免 JSON 解析复杂度）
set "OC_JSON=%OC_CONFIG_DIR%\opencode.json"
if exist "%OC_JSON%" (
    findstr /C:"oh-my-openagent" "%OC_JSON%" >nul 2>&1
    if errorlevel 1 (
        powershell -ExecutionPolicy Bypass -Command "$p='%OC_JSON%'; $c=Get-Content $p -Raw | ConvertFrom-Json; if($null -eq $c.plugin){$c.plugin=@()}; if($c.plugin -notcontains 'oh-my-openagent'){$c.plugin+='oh-my-openagent'}; $c | ConvertTo-Json -Depth 10 | Set-Content $p -Encoding UTF8"
        echo [OK] opencode.json enabled oh-my-openagent
    ) else (
        echo [SKIP] Plugin already in config
    )
) else (
    echo [WARN] %OC_JSON% not found. Run opencode once first.
)

echo.
echo Done. Restart opencode to activate. Use /agents to orchestrate sub-agents.
pause
