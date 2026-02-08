# claude-code-settings

`~/.claude` のうち、PC間で共有したい Claude Code 設定を GitHub で管理するためのリポジトリ。

## リポジトリ方針

- このリポジトリは Claude Code 向け設定のみを管理する
- 管理対象は `~/.claude` 配下のファイルに限定する
- Codex 向け設定（例: `~/AGENTS.md`, `~/.codex/**`）はこのリポジトリで管理しない

## 追跡対象

- `.gitignore`
- `CLAUDE.md`
- `settings.json`
- `commands/`

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
git checkout origin/main -- .gitignore CLAUDE.md settings.json commands/
```

## 日常運用

### 変更を反映する

```bash
cd ~/.claude
git add .gitignore CLAUDE.md settings.json commands/
git commit -m "Update Claude settings"
git push origin main
```

### 他PCの変更を取り込む

```bash
cd ~/.claude
git pull
```
