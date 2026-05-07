#!/usr/bin/env bash
# Antigravity 一鍵安裝: superpowers + GitHub MCP + Railway MCP
set -euo pipefail

C_BLUE='\033[0;36m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'; C_RED='\033[0;31m'; C_OFF='\033[0m'

echo -e "${C_BLUE}==> [1/3] 檢查依賴 (gemini, node)${C_OFF}"
for cmd in gemini node; do
  if ! command -v "$cmd" >/dev/null; then
    echo -e "${C_RED}❌ 缺少 $cmd，請從 Antigravity 內建 terminal 執行${C_OFF}"
    exit 1
  fi
done

echo -e "${C_BLUE}==> [2/3] 安裝 Superpowers (Gemini extension)${C_OFF}"
gemini extensions install https://github.com/obra/superpowers 2>/dev/null \
  || gemini extensions update superpowers 2>/dev/null \
  || echo -e "${C_YELLOW}⚠️  superpowers 安裝/更新跳過（可能已存在）${C_OFF}"

echo -e "${C_BLUE}==> [3/3] 寫入 MCP 設定: ~/.gemini/antigravity/mcp_config.json${C_OFF}"
CFG="$HOME/.gemini/antigravity/mcp_config.json"
mkdir -p "$(dirname "$CFG")"
if [ -f "$CFG" ]; then
  STAMP=$(date +%Y%m%d-%H%M%S)
  cp "$CFG" "$CFG.bak.$STAMP"
  echo "    已備份舊設定 → $CFG.bak.$STAMP"
else
  echo '{}' > "$CFG"
fi

node - "$CFG" <<'NODE'
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
console.log('    ✅ 已合併寫入 github + railway-mcp-server');
NODE

cat <<POST

${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 安裝完成。還剩 3 個手動步驟（按順序做）:${C_OFF}

1️⃣  建立 GitHub PAT
    https://github.com/settings/tokens
    scopes 勾: repo, read:org, read:user
    編輯 ${CFG}
    把 YOUR_GITHUB_PAT 換成 token

2️⃣  Railway CLI + 登入
    macOS:  brew install railway
    其他:   npm install -g @railway/cli
    然後:   railway login

3️⃣  完全關掉 Antigravity 再開（不是 reload）
    Agent panel → ... → Manage MCP Servers
    確認 github / railway-mcp-server 都列出來
${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_OFF}
POST
