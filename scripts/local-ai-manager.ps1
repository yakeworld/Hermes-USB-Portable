param(
    [string]$Action = "start",
    [string]$ToolsDir,
    [string]$ConfigPath
)

$openaiExe = Join-Path $ToolsDir "opencode-openai.exe"
$configTag = "###LOCAL_AI_CONFIG###"

if ($Action -eq "stop") {
    Get-Process "opencode-openai" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "Local AI stopped."
    exit 0
}

# Start opencode-openai in background (hidden window)
Write-Host "Starting Local AI ..."
Start-Process -FilePath $openaiExe -ArgumentList "--port 8787 --api-key public" -WindowStyle Hidden

# Wait for server
Start-Sleep -Seconds 3

# Write config if not already configured
if (Test-Path $ConfigPath) {
    $content = Get-Content $ConfigPath -Raw -ErrorAction SilentlyContinue
    if ($content -and $content.Contains($configTag)) {
        Write-Host "  Config already set."
        exit 0
    }
}

Write-Host "  Writing config.yaml ..."
@"

$configTag - auto-generated
model:
  default: deepseek-v4-flash-free
  provider: custom:local-ai
providers:
  local-ai:
    name: Local AI - opencode-openai free tier
    base_url: http://127.0.0.1:8787/v1
    api_mode: chat_completions
    discover_models: true
"@ | Out-File -FilePath $ConfigPath -Append -Encoding UTF8

Write-Host "  Config auto-set to http://127.0.0.1:8787/v1"
Write-Host "  Applying config ..."

# Apply via Hermes CLI (errors suppressed)
python -c "from hermes_cli.main import main; main()" config set model.default deepseek-v4-flash-free 2>$null
python -c "from hermes_cli.main import main; main()" config set model.provider custom:local-ai 2>$null

Write-Host "  Done."
