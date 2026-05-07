# Antigravity 一鍵安裝: superpowers + GitHub MCP + Railway MCP (Windows PowerShell)
$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host $msg -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host $msg -ForegroundColor Green }
function Write-Warn($msg) { Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host $msg -ForegroundColor Red }

Write-Step "==> [1/3] 檢查依賴 (gemini, node)"
foreach ($cmd in 'gemini','node') {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Err "❌ 缺少 $cmd，請從 Antigravity 內建 terminal 執行"
    exit 1
  }
}

Write-Step "==> [2/3] 安裝 Superpowers (Gemini extension)"
$installed = $false
try {
  & gemini extensions install https://github.com/obra/superpowers 2>$null
  $installed = $true
} catch { }
if (-not $installed) {
  try { & gemini extensions update superpowers 2>$null } catch {
    Write-Warn "⚠️  superpowers 安裝/更新跳過（可能已存在）"
  }
}

Write-Step "==> [3/3] 寫入 MCP 設定"
$cfg = Join-Path $env:USERPROFILE '.gemini\antigravity\mcp_config.json'
$cfgDir = Split-Path $cfg -Parent
New-Item -ItemType Directory -Force -Path $cfgDir | Out-Null

if (Test-Path $cfg) {
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $bak = "$cfg.bak.$stamp"
  Copy-Item $cfg $bak
  Write-Host "    已備份舊設定 → $bak"
} else {
  '{}' | Set-Content $cfg -Encoding UTF8
}

$mergeJs = @'
const fs = require('fs');
const p = process.argv[2];
const raw = fs.readFileSync(p, 'utf8').trim() || '{}';
const c = JSON.parse(raw);
c.mcpServers = c.mcpServers || {};
c.mcpServers.github = {
  serverUrl: 'https://api.githubcopilot.com/mcp/',
  headers: { Authorization: 'Bearer YOUR_GITHUB_PAT' }
};
c.mcpServers['railway-mcp-server'] = {
  command: 'npx',
  args: ['-y', '@railway/mcp-server']
};
fs.writeFileSync(p, JSON.stringify(c, null, 2) + '\n');
console.log('    OK: 已合併寫入 github + railway-mcp-server');
'@

$tmpJs = Join-Path $env:TEMP "antigravity-mcp-merge-$(Get-Random).js"
$mergeJs | Set-Content $tmpJs -Encoding UTF8
& node $tmpJs $cfg
Remove-Item $tmpJs -Force

Write-Host ""
Write-Ok  "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Ok  "✅ 安裝完成。還剩 3 個手動步驟（按順序做）:"
Write-Host ""
Write-Host "1️⃣  建立 GitHub PAT"
Write-Host "    https://github.com/settings/tokens"
Write-Host "    scopes 勾: repo, read:org, read:user"
Write-Host "    編輯 $cfg"
Write-Host "    把 YOUR_GITHUB_PAT 換成 token"
Write-Host ""
Write-Host "2️⃣  Railway CLI + 登入"
Write-Host "    winget install Railway.Railway"
Write-Host "    或: npm install -g `@railway/cli"
Write-Host "    然後: railway login"
Write-Host ""
Write-Host "3️⃣  完全關掉 Antigravity 再開（不是 reload）"
Write-Host "    Agent panel → ... → Manage MCP Servers"
Write-Host "    確認 github / railway-mcp-server 都列出來"
Write-Ok  "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
