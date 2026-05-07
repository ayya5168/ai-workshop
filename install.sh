#!/usr/bin/env bash
# Antigravity 一鍵安裝: superpowers + Railway MCP
set -euo pipefail

C_BLUE=$'\033[0;36m'; C_GREEN=$'\033[0;32m'; C_YELLOW=$'\033[0;33m'; C_RED=$'\033[0;31m'; C_OFF=$'\033[0m'

echo -e "${C_BLUE}==> [1/3] 檢查依賴 (node)${C_OFF}"
if ! command -v node >/dev/null; then
  echo -e "${C_RED}❌ 缺少 node。請先裝 Node.js (https://nodejs.org)${C_OFF}"
  exit 1
fi

echo -e "${C_BLUE}==> [2/3] 安裝 Superpowers${C_OFF}"
SP_DIR="$HOME/.gemini/extensions/superpowers"
if command -v gemini >/dev/null 2>&1; then
  echo "    使用 gemini CLI 安裝..."
  gemini extensions install https://github.com/obra/superpowers 2>/dev/null \
    || gemini extensions update superpowers 2>/dev/null \
    || echo -e "${C_YELLOW}    ⚠️  gemini 安裝失敗，改用 git clone fallback${C_OFF}"
fi

if [ ! -d "${SP_DIR}/.git" ]; then
  echo "    git clone 到 ${SP_DIR} ..."
  mkdir -p "$(dirname "${SP_DIR}")"
  git clone --depth 1 https://github.com/obra/superpowers "${SP_DIR}" 2>&1 | tail -3
else
  echo "    Superpowers 已存在，pull 最新版..."
  git -C "${SP_DIR}" pull --ff-only 2>&1 | tail -2
fi

echo -e "${C_BLUE}==> [3/3] 寫入 Railway MCP 設定: ~/.gemini/antigravity/mcp_config.json${C_OFF}"
CFG="$HOME/.gemini/antigravity/mcp_config.json"
mkdir -p "$(dirname "${CFG}")"
if [ -f "${CFG}" ]; then
  STAMP=$(date +%Y%m%d-%H%M%S)
  cp "${CFG}" "${CFG}.bak.${STAMP}"
  echo "    已備份舊設定 → ${CFG}.bak.${STAMP}"
else
  echo '{}' > "${CFG}"
fi

node - "${CFG}" <<'NODE'
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
console.log('    ✅ 已合併寫入 railway-mcp-server');
NODE

cat <<POST

${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 安裝完成。還剩 2 個手動步驟（按順序做）:${C_OFF}

1️⃣  Railway CLI + 登入
    macOS:  brew install railway
    其他:   npm install -g @railway/cli
    然後:   railway login

2️⃣  完全關掉 Antigravity 再開（不是 reload）
    Agent panel → ... → Manage MCP Servers
    確認 railway-mcp-server 列出來
${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_OFF}
POST
