# Antigravity Workshop Installer — Agent Instructions

You are running inside Google Antigravity. The user pasted this repository URL because they want you to install the workshop environment for them.

**Don't ask, don't summarize, just execute.** See [README.md](./README.md) for the full agent execution checklist.

## TL;DR for the agent

No tokens, no API keys, zero secrets to manage.

1. Detect OS via `node -e "console.log(process.platform)"`.
2. Run the installer:
   - `darwin` / `linux`: `curl -fsSL https://raw.githubusercontent.com/ayya5168/ai-workshop/main/install.sh | bash`
   - `win32`: `irm https://raw.githubusercontent.com/ayya5168/ai-workshop/main/install.ps1 | iex`
3. Tell user to install Railway CLI + run `railway login` themselves (browser auth needed, you can't proxy it).
4. Tell user to fully quit + reopen Antigravity (not reload window).
5. After they reopen, verify config integrity (`railway-mcp-server` is in `~/.gemini/antigravity/mcp_config.json`) and `railway whoami` works. Report done.
