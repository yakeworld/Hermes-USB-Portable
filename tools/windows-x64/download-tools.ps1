param([string]$ToolsDir = "$PSScriptRoot")

$tools = @(
    @{Name="opencode-openai.exe"; Url="https://github.com/yakeworld/opencode-openai/releases/latest/download/opencode-openai.exe"},
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

Write-Host "`nDone. Tools in: $ToolsDir"
