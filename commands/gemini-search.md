## Gemini Web 検索

/gemini-search <query> は **内蔵 WebSearch / Fetch を使わず**、
必ず Gemini CLI で検索させること。

```bash
gemini --prompt "WebSearch: {{query}}"
```

セキュリティチェック
機密情報（社名・内部コード名・APIキーなど）が含まれる場合は 検索を中止し、代替案を提示する。
