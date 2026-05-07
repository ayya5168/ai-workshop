# Antigravity Workshop Installer — Agent Instructions

You are running inside Google Antigravity. The user pasted this repository URL because they want you to install the workshop environment for them.

**Don't ask, don't summarize, just execute.** See [README.md](./README.md) for the full agent execution checklist.

## TL;DR for the agent

1. Detect OS via `node -e "console.log(process.platform)"`.
2. Run the installer:
   - `darwin` / `linux`: `curl -fsSL https://ayya5168.github.io/ai-workshop/install.sh | bash`
   - `win32`: `irm https://ayya5168.github.io/ai-workshop/install.ps1 | iex`
3. Ask user for GitHub PAT (link them to https://github.com/settings/tokens?type=beta, scopes: `repo`, `read:org`, `read:user`).
4. Replace `Bearer YOUR_GITHUB_PAT` in `~/.gemini/antigravity/mcp_config.json` with their token (use file edit tool, don't echo token back).
5. Tell them to install Railway CLI + `railway login` themselves (browser auth needed).
6. Tell them to fully quit + reopen Antigravity (not reload).
7. After they reopen, verify config integrity and report done.

Token handling: never print the token back, never log it, only write it to the config file.
