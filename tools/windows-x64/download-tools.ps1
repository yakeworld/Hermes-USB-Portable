param([string]$ToolsDir = "$PSScriptRoot")

$tools = @(
    # opencode-openai pinned to v0.1.1: v0.2.1 release has no Windows asset yet
    @{Name="opencode-openai.exe"; Url="https://github.com/yakeworld/opencode-openai/releases/download/v0.1.1/opencode-openai.exe"},
    @{Name="jabkit.exe";         Url="https://github.com/yakeworld/jabkit-rs/releases/latest/download/jabkit.exe"},
    @{Name="doi-fetch.exe";      Url="https://github.com/yakeworld/doi-fetch/releases/latest/download/doi-fetch.exe"},
    @{Name="rproxy.exe";         Url="https://github.com/yakeworld/rproxy/releases/latest/download/rproxy.exe"}
)

foreach ($t in $tools) {
    $path = Join-Path $ToolsDir $t.Name
    if (Test-Path $path) {
        Write-Host "  [SKIP] $($t.Name) (exists)"
        continue
    }
    Write-Host "  [DL]   $($t.Name) ..." -NoNewline
    try {
        Invoke-WebRequest -Uri $t.Url -OutFile $path -TimeoutSec 120 -ErrorAction Stop
        Write-Host " OK ($((Get-Item $path).Length/1MB -as [int]) MB)" -ForegroundColor Green
    } catch {
        Write-Host " FAILED: $_" -ForegroundColor Red
    }
}

# ---------------------------------------------------------------------------
# opencode CLI (opencode-ai/opencode, MIT) — npm 平台包 opencode-windows-x64
# Windows 10 1803+ 自带 tar.exe 可解压 .tgz。解压后顶层为 opencode-cli\opencode.exe
# ---------------------------------------------------------------------------
$ocDest = Join-Path $ToolsDir "opencode-cli"
if (-not (Test-Path (Join-Path $ocDest "opencode.exe"))) {
    try {
        $ocVersion = (Invoke-RestMethod "https://registry.npmjs.org/opencode-ai/latest" -TimeoutSec 20).version
    } catch {
        $ocVersion = "1.18.10"
    }
    Write-Host "  [DL]   opencode CLI v$ocVersion ..." -NoNewline
    $ocTgz = Join-Path $ToolsDir "opencode.tgz"
    try {
        Invoke-WebRequest -Uri "https://registry.npmjs.org/opencode-windows-x64/-/opencode-windows-x64-$ocVersion.tgz" -OutFile $ocTgz -TimeoutSec 240 -ErrorAction Stop
        New-Item -ItemType Directory -Force -Path $ocDest | Out-Null
        tar -xzf $ocTgz -C $ocDest --strip-components=1
        Remove-Item $ocTgz -Force
        $ocBin = Join-Path $ocDest "bin\opencode.exe"
        if (Test-Path $ocBin) {
            Move-Item $ocBin (Join-Path $ocDest "opencode.exe") -Force
            Remove-Item (Join-Path $ocDest "bin") -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host " OK ($((Get-Item (Join-Path $ocDest 'opencode.exe')).Length/1MB -as [int]) MB)" -ForegroundColor Green
    } catch {
        Write-Host " FAILED: $_" -ForegroundColor Red
        Remove-Item $ocTgz -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`nDone. Tools in: $ToolsDir"
