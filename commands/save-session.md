---
allowed-tools: Bash(date:*), Bash(mkdir:*), Write
description: Save session content to ~/.claude/conversations/
---

## Your task

今回のセッションの会話内容をMarkdownファイルに保存してください。

### 手順

1. `date +%Y-%m-%d` で日付を取得
2. 会話内容からトピックを短い日本語で推測（kebab-caseは不要、日本語そのまま）
3. `~/.claude/conversations/YYYY-MM-DD_<トピック>.md` に保存

### 出力フォーマット

~~~markdown
## まとめ
[会話の要約を3行以内で]

## 会話履歴
### User
[ユーザーの発言]

### Claude
[Claudeの回答（要点のみ、長い出力は省略可）]

（以降繰り返し）
~~~

### 注意
- ツール呼び出しの詳細出力は省略し、要点だけ記録する
- ファイル作成後、保存先パスを表示する
