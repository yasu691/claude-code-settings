# claude-code-settings

`~/.claude` のうち、PC間で共有したい Claude Code 設定を GitHub で管理するためのリポジトリ。

## リポジトリ方針

- このリポジトリは Claude Code 向け設定のみを管理する
- 管理対象は `~/.claude` 配下のファイルに限定する
- Codex 向け設定（例: `~/AGENTS.md`, `~/.codex/**`）はこのリポジトリで管理しない

## 追跡対象

- `.gitignore`
- `README.md`
- `CLAUDE.md`
- `settings.json`
- `MCP-SETUP.md`
- `mcp-servers.template.json`
- `commands/`
- `agents/`
- `skills/`
- `rules/`

## 導入済み拡張（2026-02-08）

- Skills
  - `skills/frontend-design/SKILL.md`
  - `skills/frontend-patterns/SKILL.md`
- Commands
  - `commands/commit.md`
  - `commands/commit-push-pr.md`
  - `commands/clean_gone.md`
  - `commands/code-review.md`
- Hooks
  - `hooks/security-guidance/security_reminder_hook.py`
  - `settings.json` の `hooks.PreToolUse` に security guidance を設定済み

※ 現在の `.gitignore` 設定では `hooks/` は追跡対象外（ローカル運用）。

## 追跡しないもの

- `settings.local.json`（マシン固有の権限設定）
- `history.jsonl` / `debug/` / `tasks/` などのランタイム生成物

## 新PCセットアップ

### `~/.claude` がまだない場合

```bash
git clone https://github.com/yasu691/claude-code-settings.git ~/.claude
```

### `~/.claude` がすでにある場合

```bash
cd ~/.claude
git init
git remote add origin https://github.com/yasu691/claude-code-settings.git 2>/dev/null || true
git fetch origin
git checkout origin/main -- .gitignore README.md CLAUDE.md settings.json MCP-SETUP.md mcp-servers.template.json commands/ agents/ skills/ rules/
```

## 日常運用

### 変更を反映する

```bash
cd ~/.claude
git add .gitignore README.md CLAUDE.md settings.json MCP-SETUP.md mcp-servers.template.json commands/ agents/ skills/ rules/
git commit -m "Update Claude settings"
git push origin main
```

### 他PCの変更を取り込む

```bash
cd ~/.claude
git pull
```
