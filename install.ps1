# Antigravity 一鍵安裝: superpowers + Railway MCP (Windows PowerShell)
$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host $msg -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host $msg -ForegroundColor Green }
function Write-Warn($msg) { Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host $msg -ForegroundColor Red }

Write-Step "==> [1/3] 檢查依賴 (node)"
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Err "❌ 缺少 node。請先裝 Node.js (https://nodejs.org)"
  exit 1
}

Write-Step "==> [2/3] 安裝 Superpowers"
$spDir = Join-Path $env:USERPROFILE '.gemini\extensions\superpowers'

if (Get-Command gemini -ErrorAction SilentlyContinue) {
  Write-Host "    使用 gemini CLI 安裝..."
  try { & gemini extensions install https://github.com/obra/superpowers 2>$null } catch {}
  if (-not (Test-Path "$spDir\.git")) {
    try { & gemini extensions update superpowers 2>$null } catch {}
  }
}

if (-not (Test-Path "$spDir\.git")) {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Err "❌ 缺少 git，無法 fallback 安裝 Superpowers"
    exit 1
  }
  Write-Host "    git clone 到 $spDir ..."
  New-Item -ItemType Directory -Force -Path (Split-Path $spDir -Parent) | Out-Null
  & git clone --depth 1 https://github.com/obra/superpowers $spDir
} else {
  Write-Host "    Superpowers 已存在，pull 最新版..."
  & git -C $spDir pull --ff-only
}

Write-Step "==> [3/3] 寫入 Railway MCP 設定"
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
c.mcpServers['railway-mcp-server'] = {
  command: 'npx',
  args: ['-y', '@railway/mcp-server']
};
fs.writeFileSync(p, JSON.stringify(c, null, 2) + '\n');
console.log('    OK: 已合併寫入 railway-mcp-server');
'@

$tmpJs = Join-Path $env:TEMP "antigravity-mcp-merge-$(Get-Random).js"
$mergeJs | Set-Content $tmpJs -Encoding UTF8
& node $tmpJs $cfg
Remove-Item $tmpJs -Force

Write-Host ""
Write-Ok  "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Ok  "✅ 安裝完成。還剩 2 個手動步驟（按順序做）:"
Write-Host ""
Write-Host "1️⃣  Railway CLI + 登入"
Write-Host "    winget install Railway.Railway"
Write-Host "    或: npm install -g `@railway/cli"
Write-Host "    然後: railway login"
Write-Host ""
Write-Host "2️⃣  完全關掉 Antigravity 再開（不是 reload）"
Write-Host "    Agent panel → ... → Manage MCP Servers"
Write-Host "    確認 railway-mcp-server 列出來"
Write-Ok  "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
