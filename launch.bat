@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM Hermes Agent - Portable Launcher (Windows)
REM ============================================================================
REM Double-click this file to launch Hermes.
REM On first run, it downloads ~600MB of runtime files automatically.
REM All data stays in the "data\" folder - nothing touches the host computer.
REM ============================================================================

REM Resolve portable root (directory containing this script)
set "PORTABLE_ROOT=%~dp0"
set "PORTABLE_ROOT=%PORTABLE_ROOT:~0,-1%"

set "HERMES_HOME=%PORTABLE_ROOT%\data"
set "CACHE_DIR=%PORTABLE_ROOT%\.cache"
set "RUNTIME_DIR=%CACHE_DIR%\runtimes\windows-x64"
set "SRC_DIR=%PORTABLE_ROOT%\src"

REM ---------------------------------------------------------------------------
REM Runtime readiness — Hermes runtime (~600MB) is downloaded ON DEMAND,
REM not at launch. OpenCode entry works without it.
REM ---------------------------------------------------------------------------
set "HERMES_READY=0"
if exist "%RUNTIME_DIR%\ready.flag" set "HERMES_READY=1"

REM Jump over subroutine definitions to the main body
goto :main_body

:setup_hermes
echo.
echo ============================================
echo    Hermes Runtime - First Run Setup
echo ============================================
echo  This will download ~600MB of runtime files
echo  for Windows x64. Please be patient.
echo ============================================
echo.
powershell -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\setup-windows.ps1" -Root "%PORTABLE_ROOT%"
if errorlevel 1 (
    echo.
    echo [ERROR] Setup failed. Please check your internet connection and try again.
    pause
    exit /b 1
)
set "HERMES_READY=1"
goto :eof

REM ---------------------------------------------------------------------------
REM Synthos clone + config injection (on demand, small)
REM ---------------------------------------------------------------------------
:ensure_synthos
if not exist "%PORTABLE_ROOT%\Synthos\SKILL.md" (
    echo.
    echo ============================================
    echo    Synthos Cognitive Engine
    echo ============================================
    call "%PORTABLE_ROOT%\scripts\download-synthos.bat" "%PORTABLE_ROOT%\Synthos"
)
if exist "%HERMES_HOME%\config.yaml" (
    findstr /C:"%SYNTHOS_CONFIG_TAG%" "%HERMES_HOME%\config.yaml" >nul 2>&1
    if errorlevel 1 (
        echo.
        echo  [Synthos] Configuring Synthos skills ...
        echo.>> "%HERMES_HOME%\config.yaml"
        echo # %SYNTHOS_CONFIG_TAG% >> "%HERMES_HOME%\config.yaml"
        echo skills:>> "%HERMES_HOME%\config.yaml"
        echo   external_dirs:>> "%HERMES_HOME%\config.yaml"
        echo     - %SYNTHOS_SKILLS%>> "%HERMES_HOME%\config.yaml"
    )
)
goto :eof

:main_body
REM ---------------------------------------------------------------------------
REM Environment isolation - keep everything inside the portable folder
REM ---------------------------------------------------------------------------
set "VIRTUAL_ENV=%RUNTIME_DIR%\venv"
set "TOOLS_DIR=%PORTABLE_ROOT%\tools\windows-x64"
set "TOOLS_SETUP_FILE=%TOOLS_DIR%\download-tools.ps1"
set "OPENCODE_EXE=%TOOLS_DIR%\opencode-openai.exe"
set "OPENCODE_CLI=%TOOLS_DIR%\opencode-cli\opencode.exe"
set "SYNTHOS_SKILLS=%PORTABLE_ROOT%\Synthos\skills"
set "SYNTHOS_CONFIG_TAG=###SYNTHOS_SKILLS_CONFIG###"
set "PATH=%TOOLS_DIR%;%VIRTUAL_ENV%\Scripts;%RUNTIME_DIR%\python;%RUNTIME_DIR%\python\Scripts;%RUNTIME_DIR%\node;%RUNTIME_DIR%\uv;%RUNTIME_DIR%\bin;%PATH%"
set "PYTHONNOUSERSITE=1"
set "PYTHONHOME="
set "PYTHONPATH="
set "UV_NO_CONFIG=1"
set "UV_PYTHON=%RUNTIME_DIR%\python\python.exe"
set "PLAYWRIGHT_BROWSERS_PATH=%RUNTIME_DIR%\playwright"
set "NODE_PATH=%RUNTIME_DIR%\node\node_modules"
set "NPM_CONFIG_PREFIX=%RUNTIME_DIR%\node"

REM Prevent Node from writing to host appdata
set "APPDATA=%PORTABLE_ROOT%\.cache\windows-appdata"
set "LOCALAPPDATA=%PORTABLE_ROOT%\.cache\windows-localappdata"

REM ---------------------------------------------------------------------------
REM Update pyvenv.cfg with the current absolute path to ensure portability
REM ---------------------------------------------------------------------------
if exist "%VIRTUAL_ENV%\pyvenv.cfg" (
    for /f "tokens=2" %%v in ('"%RUNTIME_DIR%\python\python.exe" --version 2^>nul') do set "PYTHON_VERSION=%%v"
    if not defined PYTHON_VERSION set "PYTHON_VERSION=3.11.15"
    (
    echo home = %RUNTIME_DIR%\python
    echo include-system-site-packages = false
    echo version = !PYTHON_VERSION!
    ) > "%VIRTUAL_ENV%\pyvenv.cfg"
)

REM ---------------------------------------------------------------------------
REM Direct-argument mode (e.g. launch.bat hermes setup): needs full runtime
REM ---------------------------------------------------------------------------
set "ARGS=%*"
if /I "%~1"=="hermes" (
    set "ARGS=%ARGS:~7%"
)
if not "%ARGS%"=="" (
    if "!HERMES_READY!"=="0" (
        echo %YELLOW%Hermes runtime not installed. Downloading ~600MB ...%RESET%
        call :setup_hermes
    )
    call :ensure_synthos
    if not exist "%SRC_DIR%\hermes-agent" (
        echo [ERROR] Hermes source not found. Please delete .cache and try again.
        exit /b 1
    )
    cd /d "%SRC_DIR%\hermes-agent"
    python -c "from hermes_cli.main import main; main()" %ARGS%
    exit /b
)

REM ---------------------------------------------------------------------------
REM ANSI Color Setup
REM ---------------------------------------------------------------------------
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m"
set "CYAN=%ESC%[36m"
set "BRIGHT_CYAN=%ESC%[96m"
set "GREEN=%ESC%[32m"
set "BRIGHT_GREEN=%ESC%[92m"
set "YELLOW=%ESC%[33m"
set "BRIGHT_YELLOW=%ESC%[93m"
set "RED=%ESC%[31m"
set "BRIGHT_RED=%ESC%[91m"
set "WHITE=%ESC%[37m"
set "BRIGHT_WHITE=%ESC%[97m"
set "GRAY=%ESC%[90m"
set "BG_CYAN=%ESC%[46m%ESC%[30m"
set "BG_DARK=%ESC%[40m%ESC%[37m"

REM ---------------------------------------------------------------------------
REM Status Detection
REM ---------------------------------------------------------------------------
:detect_status
set "SETUP_STATUS=Not configured"
set "SETUP_ICON=[x]"
set "SETUP_COLOR=%RED%"
set "PROVIDER_NAME="
set "MODEL_NAME="
if exist "%HERMES_HOME%\.env" (
    findstr /R /C:"^[A-Z].*=" "%HERMES_HOME%\.env" >nul 2>&1
    if not errorlevel 1 (
        set "SETUP_STATUS=Configured"
        set "SETUP_ICON=[OK]"
        set "SETUP_COLOR=%BRIGHT_GREEN%"
    )
)

if exist "%HERMES_HOME%\config.yaml" (
    for /f "usebackq tokens=2 delims=: " %%a in (`findstr /R /C:"^  provider:" "%HERMES_HOME%\config.yaml"`) do (
        if not defined PROVIDER_NAME set "PROVIDER_NAME=%%a"
    )
    for /f "usebackq tokens=2 delims=: " %%a in (`findstr /R /C:"^  default:" "%HERMES_HOME%\config.yaml"`) do (
        if not defined MODEL_NAME set "MODEL_NAME=%%a"
    )
)

set "GATEWAY_STATUS=Stopped"
set "GATEWAY_ICON=[ ]"
set "GATEWAY_COLOR=%GRAY%"
set "GATEWAY_PID="
if exist "%HERMES_HOME%\gateway.pid" (
    for /f "usebackq tokens=2 delims=:," %%a in (`findstr /R /C:"\"pid\"" "%HERMES_HOME%\gateway.pid"`) do (
        set "raw=%%a"
        set "GATEWAY_PID=!raw: =!"
    )
)
if defined GATEWAY_PID (
    tasklist /FI "PID eq !GATEWAY_PID!" 2>nul | findstr /I "!GATEWAY_PID!" >nul
    if not errorlevel 1 (
        set "GATEWAY_STATUS=Running (PID !GATEWAY_PID!)"
        set "GATEWAY_ICON=[OK]"
        set "GATEWAY_COLOR=%BRIGHT_GREEN%"
    ) else (
        set "GATEWAY_STATUS=Stopped (stale lock)"
        set "GATEWAY_ICON=[!]"
        set "GATEWAY_COLOR=%YELLOW%"
    )
)

set "HERMES_VERSION=unknown"
if exist "%SRC_DIR%\hermes-agent\hermes_cli\__init__.py" (
    for /f "usebackq tokens=3" %%a in (`findstr /R /C:"__version__" "%SRC_DIR%\hermes-agent\hermes_cli\__init__.py"`) do (
        set "rawver=%%a"
        set "HERMES_VERSION=!rawver:"=!"
    )
)

REM ---------------------------------------------------------------------------
REM Local AI Status Detection
REM ---------------------------------------------------------------------------
set "LOCAL_AI_STATUS=Stopped"
set "LOCAL_AI_ICON=[ ]"
set "LOCAL_AI_COLOR=%GRAY%"
tasklist /FI "IMAGENAME eq opencode-openai.exe" 2>nul | findstr /I "opencode-openai" >nul
if not errorlevel 1 (
    set "LOCAL_AI_STATUS=Running"
    set "LOCAL_AI_ICON=[OK]"
    set "LOCAL_AI_COLOR=%BRIGHT_GREEN%"
) else if exist "%OPENCODE_EXE%" (
    set "LOCAL_AI_STATUS=Ready"
    set "LOCAL_AI_ICON=[x]"
    set "LOCAL_AI_COLOR=%YELLOW%"
)

set "TOOLS_STATUS=Not downloaded"
set "TOOLS_ICON=[x]"
set "TOOLS_COLOR=%YELLOW%"
if exist "%OPENCODE_EXE%" (
    set "TOOLS_STATUS=Ready"
    set "TOOLS_ICON=[OK]"
    set "TOOLS_COLOR=%BRIGHT_GREEN%"
)

REM ---------------------------------------------------------------------------
REM Main Menu
REM ---------------------------------------------------------------------------
:show_menu
echo.
echo.
echo %BRIGHT_CYAN%----------------------------------------------------------------%RESET%
echo %BOLD%%BRIGHT_WHITE%                    HERMES PORTABLE LAUNCHER%RESET%
echo %DIM%%GRAY%                         AI Agent for Everyone%RESET%
echo %BRIGHT_CYAN%----------------------------------------------------------------%RESET%
echo.
echo  %DIM%Setup%RESET%    !SETUP_COLOR!!SETUP_ICON!%RESET% %WHITE%!SETUP_STATUS!%RESET%
if defined PROVIDER_NAME echo  %DIM%Provider%RESET% %CYAN%!PROVIDER_NAME!%RESET%
if defined MODEL_NAME echo  %DIM%Model%RESET%    %WHITE%!MODEL_NAME!%RESET%
echo  %DIM%Gateway%RESET%  !GATEWAY_COLOR!!GATEWAY_ICON!%RESET% %WHITE%!GATEWAY_STATUS!%RESET%
echo  %DIM%Local AI%RESET% !LOCAL_AI_COLOR!!LOCAL_AI_ICON!%RESET% %WHITE%!LOCAL_AI_STATUS!%RESET%
echo  %DIM%Tools%RESET%    !TOOLS_COLOR!!TOOLS_ICON!%RESET% %WHITE%!TOOLS_STATUS!%RESET%
echo  %DIM%Version%RESET%  %GRAY%v!HERMES_VERSION!%RESET%
echo.
echo %BRIGHT_CYAN%----------------------------------------------------------------%RESET%
echo.
echo  %BRIGHT_YELLOW%[1]%RESET%  %WHITE%Start OpenCode Chat%RESET%  %GREEN%(default, Enter)%RESET%
echo  %BRIGHT_YELLOW%[2]%RESET%  %WHITE%Start Hermes Chat%RESET%
echo  %BRIGHT_YELLOW%[3]%RESET%  %WHITE%Setup / Reconfigure Hermes%RESET%
if "!GATEWAY_STATUS!"=="Running (PID !GATEWAY_PID!)" (
    echo  %BRIGHT_YELLOW%[4]%RESET%  %WHITE%Stop Gateway%RESET%  %RED%[live]%RESET%
) else (
    echo  %BRIGHT_YELLOW%[4]%RESET%  %WHITE%Start Gateway%RESET%
)
echo  %BRIGHT_YELLOW%[5]%RESET%  %WHITE%Advanced Options%RESET%  %GRAY%--^>%RESET%
echo  %BRIGHT_YELLOW%[6]%RESET%  %GRAY%Exit%RESET%
if "!LOCAL_AI_STATUS!"=="Running" (
    echo  %BRIGHT_YELLOW%[7]%RESET%  %WHITE%Stop Local AI%RESET%      %RED%[live]%RESET%
) else (
    echo  %BRIGHT_YELLOW%[7]%RESET%  %WHITE%Start Local AI%RESET%
)
echo  %BRIGHT_YELLOW%[8]%RESET%  %WHITE%Download Tools%RESET%
echo.
echo %BRIGHT_CYAN%----------------------------------------------------------------%RESET%
echo.
set /p "choice=%BRIGHT_CYAN%Select option (Enter=1): %RESET%"
if "!choice!"=="" set "choice=1"

if "!choice!"=="1" goto :menu_opencode
if "!choice!"=="2" goto :menu_chat
if "!choice!"=="3" goto :menu_setup
if "!choice!"=="4" goto :menu_gateway
if "!choice!"=="5" goto :show_advanced
if "!choice!"=="6" goto :menu_exit
if "!choice!"=="7" goto :menu_local_ai
if "!choice!"=="8" goto :menu_download_tools
goto :show_menu

REM ---------------------------------------------------------------------------
REM Menu Actions
REM ---------------------------------------------------------------------------
:menu_opencode
echo.
REM Portable HOME: redirect USERPROFILE + XDG dirs so opencode never touches the host
REM (XDG scheme absorbed from USB opencode-portable — opencode honors XDG_CONFIG_HOME
REM  / XDG_DATA_HOME natively; USERPROFILE covers ~/.agents/skills homedir lookup)
set "USERPROFILE=%PORTABLE_ROOT%\.cache\windows-opencode-home"
if not exist "%USERPROFILE%" mkdir "%USERPROFILE%"
set "XDG_CONFIG_HOME=%PORTABLE_ROOT%\data\opencode-config"
set "XDG_DATA_HOME=%PORTABLE_ROOT%\data\opencode"
set "XDG_STATE_HOME=%PORTABLE_ROOT%\.cache\opencode-state"
set "XDG_CACHE_HOME=%PORTABLE_ROOT%\.cache\opencode-cache"
if not exist "%XDG_STATE_HOME%" mkdir "%XDG_STATE_HOME%"
if not exist "%XDG_CACHE_HOME%" mkdir "%XDG_CACHE_HOME%"

REM Synthos skills (small, on demand)
call :ensure_synthos

REM opencode CLI (auto-download on first use, ~200MB)
if not exist "%OPENCODE_CLI%" (
    echo %YELLOW%opencode CLI not installed. Auto-downloading tools (~200MB) ...%RESET%
    if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"
    powershell -ExecutionPolicy Bypass -File "%TOOLS_SETUP_FILE%" -ToolsDir "%TOOLS_DIR%"
)
if not exist "%OPENCODE_CLI%" (
    echo %YELLOW%Download failed. Check network or use [8] Download Tools.%RESET%
    pause
    goto :show_menu
)

REM Ensure Local AI proxy (free models) is running
tasklist /FI "IMAGENAME eq opencode-openai.exe" 2>nul | findstr /I "opencode-openai" >nul
if errorlevel 1 (
    echo %CYAN%Starting Local AI (free model proxy) ...%RESET%
    start "" "%OPENCODE_EXE%" --port 8787 --api-key public
    timeout /t 3 /nobreak >nul
)

REM Link Synthos skills (dual paths: homedir + XDG config, covers opencode's lookup)
if exist "%SYNTHOS_SKILLS%" (
    powershell -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\link-opencode-skills.ps1" -Src "%SYNTHOS_SKILLS%" -Dest "%USERPROFILE%\.agents\skills"
    powershell -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\link-opencode-skills.ps1" -Src "%SYNTHOS_SKILLS%" -Dest "%XDG_CONFIG_HOME%\opencode\skills"
)

REM Generate portable opencode.json (points to local free-model proxy)
set "OC_CONFIG_DIR=%XDG_CONFIG_HOME%\opencode"
if not exist "%OC_CONFIG_DIR%" mkdir "%OC_CONFIG_DIR%"
set "OPENCODE_CONFIG=%OC_CONFIG_DIR%\opencode.json"
if not exist "%OPENCODE_CONFIG%" (
    powershell -Command "$cfg = '{\"$schema\":\"https://opencode.ai/config.json\",\"model\":\"local-ai/deepseek-v4-flash-free\",\"small_model\":\"local-ai/deepseek-v4-flash-free\",\"provider\":{\"local-ai\":{\"npm\":\"@ai-sdk/openai-compatible\",\"name\":\"Local AI (Free)\",\"options\":{\"baseURL\":\"http://127.0.0.1:8787/v1\",\"apiKey\":\"public\"},\"models\":{\"deepseek-v4-flash-free\":{\"name\":\"DeepSeek V4 Flash (Free)\",\"tools\":true},\"big-pickle\":{\"name\":\"Big Pickle (Free)\",\"tools\":true}}}},\"permission\":{\"read\":\"allow\",\"edit\":\"ask\",\"bash\":\"ask\",\"skill\":\"allow\"}}'; Set-Content -Path '%OPENCODE_CONFIG%' -Value $cfg -Encoding UTF8"
    echo %BRIGHT_GREEN%  opencode config created (free model, no API key).%RESET%
)

REM Launch OpenCode TUI (foreground; /exit or Ctrl+C returns)
cd /d "%PORTABLE_ROOT%"
echo %CYAN%Starting OpenCode ... (/exit or Ctrl+C to return to menu)%RESET%
"%OPENCODE_CLI%"
pause
goto :detect_status

:menu_chat
echo.
if "!HERMES_READY!"=="0" (
    echo %YELLOW%Hermes runtime not installed. Downloading ~600MB ...%RESET%
    echo %CYAN%(Want fast AI chat? Choose [1] OpenCode - no download needed)%RESET%
    call :setup_hermes
)
call :ensure_synthos
if not exist "%SRC_DIR%\hermes-agent" (
    echo [ERROR] Hermes source not found. Please delete .cache and try again.
    pause
    goto :show_menu
)
cd /d "%SRC_DIR%\hermes-agent"
python -c "from hermes_cli.main import main; main()"
goto :show_menu

:menu_setup
echo.
if "!HERMES_READY!"=="0" (
    echo %YELLOW%Hermes runtime not installed. Downloading ~600MB ...%RESET%
    call :setup_hermes
)
python -c "from hermes_cli.main import main; main()" setup
goto :detect_status

:menu_gateway
if "!HERMES_READY!"=="0" (
    echo %YELLOW%Hermes runtime not installed. Choose [2] Start Hermes Chat first.%RESET%
    pause
    goto :show_menu
)
if "!GATEWAY_STATUS!"=="Running (PID !GATEWAY_PID!)" (
    python -c "from hermes_cli.main import main; main()" gateway stop
    echo.
    echo %BRIGHT_GREEN%Gateway stopped.%RESET%
) else (
    echo.
    echo %CYAN%Starting gateway in background ...%RESET%
    start "" python -c "from hermes_cli.main import main; main()" gateway
    timeout /t 2 /nobreak >nul
)
pause
goto :detect_status

:menu_exit
echo.
echo.
echo %GRAY%Goodbye!%RESET%
echo.
exit /b

:menu_local_ai
echo.
if "!LOCAL_AI_STATUS!"=="Running" (
    echo %CYAN%Stopping Local AI ...%RESET%
    echo [STOP] stopping opencode-openai > "%PORTABLE_ROOT%\local-ai-debug.log"
    powershell -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\local-ai-manager.ps1" -Action stop
    echo.
    echo %BRIGHT_GREEN%Local AI stopped.%RESET%
) else (
    echo %CYAN%Starting Local AI ...%RESET%
    echo [START] %DATE% %TIME% > "%PORTABLE_ROOT%\local-ai-debug.log"
    echo PORTABLE_ROOT=%PORTABLE_ROOT% >> "%PORTABLE_ROOT%\local-ai-debug.log"
    echo TOOLS_DIR=%TOOLS_DIR% >> "%PORTABLE_ROOT%\local-ai-debug.log"
    echo OPENCODE_EXE=%OPENCODE_EXE% >> "%PORTABLE_ROOT%\local-ai-debug.log"
    dir "%OPENCODE_EXE%" >> "%PORTABLE_ROOT%\local-ai-debug.log" 2>&1
    echo [POWERSHELL] calling local-ai-manager.ps1 >> "%PORTABLE_ROOT%\local-ai-debug.log"
    powershell -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\local-ai-manager.ps1" -Action start -ToolsDir "%TOOLS_DIR%" -ConfigPath "%HERMES_HOME%\config.yaml" >> "%PORTABLE_ROOT%\local-ai-debug.log" 2>&1
    echo [EXIT] PowerShell exit code: !ERRORLEVEL! >> "%PORTABLE_ROOT%\local-ai-debug.log"
)
echo [GOTO] detect_status >> "%PORTABLE_ROOT%\local-ai-debug.log"
goto :detect_status

:menu_download_tools
echo.
echo %CYAN%Downloading portable tools ...%RESET%
if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"
powershell -ExecutionPolicy Bypass -File "%TOOLS_SETUP_FILE%" -ToolsDir "%TOOLS_DIR%"
echo.
goto :detect_status

REM ---------------------------------------------------------------------------
REM Advanced Menu
REM ---------------------------------------------------------------------------
:show_advanced
echo.
echo.
echo %BRIGHT_CYAN%----------------------------------------------------------------%RESET%
echo %BOLD%%BRIGHT_WHITE%                       Advanced Options%RESET%
echo %BRIGHT_CYAN%----------------------------------------------------------------%RESET%
echo.
echo  %BRIGHT_YELLOW%[1]%RESET%  %WHITE%Run Doctor%RESET%            %GRAY%- check for issues%RESET%
echo  %BRIGHT_YELLOW%[2]%RESET%  %WHITE%View Logs%RESET%             %GRAY%- last 20 lines%RESET%
echo  %BRIGHT_YELLOW%[3]%RESET%  %WHITE%Edit Config%RESET%           %GRAY%- open in editor%RESET%
echo  %BRIGHT_YELLOW%[4]%RESET%  %WHITE%Restart Gateway%RESET%       %GRAY%- stop + start%RESET%
echo  %BRIGHT_YELLOW%[5]%RESET%  %WHITE%Update Hermes%RESET%         %GRAY%- fetch latest%RESET%
echo  %BRIGHT_YELLOW%[6]%RESET%  %GRAY%Back to Main Menu%RESET%
echo.
echo %BRIGHT_CYAN%----------------------------------------------------------------%RESET%
echo.

echo %BRIGHT_CYAN%Select option:%RESET% & choice /C 123456 /N
if errorlevel 6 goto :show_menu
if errorlevel 5 goto :adv_update
if errorlevel 4 goto :adv_restart
if errorlevel 3 goto :adv_config
if errorlevel 2 goto :adv_logs
if errorlevel 1 goto :adv_doctor
goto :show_advanced

:adv_doctor
echo.
if "!HERMES_READY!"=="0" (
    echo %YELLOW%Hermes runtime not installed. Choose [2] Start Hermes Chat first.%RESET%
    pause
    goto :show_advanced
)
python -c "from hermes_cli.main import main; main()" doctor
pause
goto :show_advanced

:adv_logs
echo.
if exist "%HERMES_HOME%\logs\gateway.log" (
    echo %CYAN%=== Gateway Log (last 20 lines) ===%RESET%
    powershell -Command "Get-Content '%HERMES_HOME%\logs\gateway.log' -Tail 20"
) else (
    echo %YELLOW%No logs found.%RESET%
)
echo.
pause
goto :show_advanced

:adv_config
echo.
if "!HERMES_READY!"=="0" (
    echo %YELLOW%Hermes runtime not installed. Choose [2] Start Hermes Chat first.%RESET%
    pause
    goto :show_advanced
)
python -c "from hermes_cli.main import main; main()" config edit
goto :show_advanced

:adv_restart
if "!HERMES_READY!"=="0" (
    echo %YELLOW%Hermes runtime not installed. Choose [2] Start Hermes Chat first.%RESET%
    pause
    goto :show_advanced
)
python -c "from hermes_cli.main import main; main()" gateway restart
echo.
echo %BRIGHT_GREEN%Gateway restarted.%RESET%
pause
goto :detect_status

:adv_update
echo.
if "!HERMES_READY!"=="0" (
    echo %YELLOW%Hermes runtime not installed. Choose [2] Start Hermes Chat first.%RESET%
    pause
    goto :show_advanced
)
python -c "from hermes_cli.main import main; main()" update
pause
goto :show_advanced
