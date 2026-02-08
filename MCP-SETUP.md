# MCP設定メモ

## 現在の状態

`user` スコープ（グローバル）に以下3つを登録済み。

1. `context7`
2. `playwright`
3. `serena`

## 確認コマンド

```bash
claude mcp list
claude mcp get context7
claude mcp get playwright
claude mcp get serena
```

## 補足

- `serena` は `uvx` で GitHub ソースから起動する設定
- `context7` / `playwright` は `npx` 起動設定
- 接続に失敗する場合は、ネットワーク到達性とローカル依存（`npx` / `uvx`）を確認する
