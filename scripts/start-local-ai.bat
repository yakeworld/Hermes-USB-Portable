@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM Start Local AI (opencode-openai) - Portable Launcher
REM ============================================================================
REM Starts the opencode-openai proxy in the background as a local provider.
REM Configures Hermes to use it automatically.
REM ============================================================================

set "PORTABLE_ROOT=%~dp0.."
set "TOOLS_DIR=%PORTABLE_ROOT%\tools\windows-x64"
set "OPENCODE_EXE=%TOOLS_DIR%\opencode-openai.exe"

if not exist "%OPENCODE_EXE%" (
    echo.
    echo  [TOOLS] opencode-openai.exe not found.
    echo  [TOOLS] Run download-tools.ps1 first or use menu option [7] to download.
    echo.
    pause
    exit /b 1
)

REM Check if already running
for /f "tokens=2" %%p in ('tasklist /NH /FI "IMAGENAME eq opencode-openai.exe" 2^>nul') do (
    if not "%%p"=="" (
        echo  [AI]    opencode-openai already running (PID %%p)
        echo  [AI]    http://127.0.0.1:8787/v1
        echo.
        pause
        exit /b 0
    )
)

echo.
echo  [AI]    Starting opencode-openai ...
echo  [AI]    Port:     8787
echo  [AI]    API Key:  public (free models)
echo  [AI]    Endpoint: http://127.0.0.1:8787/v1
echo.

start "opencode-openai" "%OPENCODE_EXE%" --port 8787 --api-key public

REM Wait for server to be ready
echo  [AI]    Waiting for server ...
timeout /t 3 /nobreak >nul

REM Verify health
for /l %%i in (1,1,10) do (
    curl -s --connect-timeout 2 -m 3 "http://127.0.0.1:8787/health" >nul 2>&1
    if not errorlevel 1 (
        echo  [OK]    opencode-openai is ready!
        echo  [AI]    http://127.0.0.1:8787/v1
        echo  [AI]    Model: deepseek-v4-flash-free (free)
        echo.
        pause
        exit /b 0
    )
    timeout /t 1 /nobreak >nul
)

echo  [WARN]  Server start may still be in progress.
echo  [AI]    Check http://127.0.0.1:8787/health manually.
echo.
pause
