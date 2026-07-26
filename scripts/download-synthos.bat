@echo off
setlocal
set "SYNTHOS_DIR=%~1"
if "%SYNTHOS_DIR%"=="" set "SYNTHOS_DIR=%~dp0..\Synthos"
if exist "%SYNTHOS_DIR%\SKILL.md" (
    echo  [SKIP] Synthos already exists at %SYNTHOS_DIR%
    exit /b 0
)
echo  [DL]   Downloading Synthos cognitive engine ...
git clone --depth 1 https://github.com/yakeworld/Synthos.git "%SYNTHOS_DIR%" 2>nul
if errorlevel 1 (
    echo  [DL]   git not available, trying curl ...
    if not exist "%TEMP%\synthos.zip" (
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yakeworld/Synthos/archive/refs/heads/main.zip' -OutFile '%TEMP%\synthos.zip' -TimeoutSec 120"
    )
    powershell -Command "Expand-Archive -Path '%TEMP%\synthos.zip' -DestinationPath '%TEMP%' -Force"
    if exist "%TEMP%\Synthos-main" (
        if exist "%SYNTHOS_DIR%" rmdir /s /q "%SYNTHOS_DIR%"
        move /y "%TEMP%\Synthos-main" "%SYNTHOS_DIR%" >nul
    )
)
if exist "%SYNTHOS_DIR%\SKILL.md" (
    echo  [OK]   Synthos ready (%SYNTHOS_DIR%)
) else (
    echo  [ERR]  Synthos download failed
    exit /b 1
)
