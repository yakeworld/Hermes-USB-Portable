# ============================================================================
# link-opencode-skills.ps1 — 将 Synthos 技能链接到 opencode 可发现路径 (Windows)
# 用法: link-opencode-skills.ps1 -Src <Synthos-skills目录> [-Dest <目标目录>]
# 默认目标: $env:USERPROFILE\.agents\skills
# 使用 Junction（目录链接，无需管理员权限）
# ============================================================================
param(
    [Parameter(Mandatory = $true)][string]$Src,
    [string]$Dest = (Join-Path $env:USERPROFILE ".agents\skills")
)

if (-not (Test-Path $Src)) {
    Write-Host "  [ERR] Synthos skills dir not found: $Src" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $Dest | Out-Null

$count = 0
$skipped = 0
Get-ChildItem -Path $Src -Filter "SKILL.md" -Recurse -File | ForEach-Object {
    $skillDir = $_.Directory.FullName
    if ($skillDir -like "*.archive*") { $skipped++; return }
    $name = Split-Path $skillDir -Leaf
    $target = Join-Path $Dest $name
    if (Test-Path $target) {
        Remove-Item $target -Recurse -Force -ErrorAction SilentlyContinue
    }
    cmd /c mklink /J "`"$target`"" "`"$skillDir`"" 2>$null | Out-Null
    if (-not (Test-Path (Join-Path $target "SKILL.md"))) {
        # mklink 失败（如跨卷）→ 回退目录复制
        Copy-Item $skillDir $target -Recurse -Force -ErrorAction SilentlyContinue
    }
    $count++
}
Write-Host "  [OK] Linked $count Synthos skills -> $Dest (skipped $skipped archived)" -ForegroundColor Green
