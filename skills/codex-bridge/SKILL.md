---
name: codex-bridge
description: OpenAI Codexをセカンドオピニオン／構造化レビュー／修正案生成に活用するブリッジスキル
version: 1.0.0
author: asai
---

# Codex Bridge Skill

Claude CodeからOpenAI Codexを「セカンドオピニオン／構造化レビュー／修正案生成」に活用するためのブリッジスキル。

## 使用法

```
/codex-bridge "バグの原因を調査して"
/codex-bridge --files src/api.ts,src/utils.ts "このAPIのエラーハンドリングを改善して"
/codex-bridge --evidence logs/error.log "このエラーの原因を特定して"
```

## 実行フェーズ

### Phase 1: 情報整理
ユーザーの依頼から以下を整理する：
- **目的 (Goal)**: 何を達成したいか
- **制約 (Constraints)**: 守るべきルール、スタイルガイド
- **対象ファイル (Files)**: 変更対象のファイルパス
- **証拠 (Evidence)**: エラーログ、差分、テスト結果など

### Phase 2: プロンプト生成
```bash
~/.claude/skills/codex-bridge/scripts/codex_prompt_build.sh \
  --goal "目的" \
  --files "file1.ts,file2.ts" \
  --evidence "path/to/error.log" \
  --constraints "追加制約（オプション）"
```
→ `~/.claude/skills/codex-bridge/.codex/prompt.md` に出力

### Phase 3: Codex実行
```bash
~/.claude/skills/codex-bridge/scripts/codex_exec.sh \
  ~/.claude/skills/codex-bridge/.codex/prompt.md
```
→ `~/.claude/skills/codex-bridge/.codex/out.md` に結果保存

### Phase 4: 結果解析
出力は以下のフォーマットで構造化される：
1. **Diagnosis**: 原因仮説と根拠
2. **Plan**: 最短手順、優先度付き
3. **Concrete edits**: ファイル別に「どこをどう変えるか」
4. **Risks & checks**: 副作用と確認テスト

### Phase 5: アクション決定
ユーザーに提示し、次のアクションを決定：
- **適用**: 提案された修正を実装
- **却下**: 別のアプローチを検討
- **追加情報要求**: より詳細な情報をCodexに再度問い合わせ

## ハードルール

| ルール | 説明 |
|--------|------|
| 秘密情報禁止 | 鍵・個人情報・社外秘URL・顧客データをプロンプトに含めない |
| read-only優先 | デフォルトは `--sandbox read-only`。書き込みは明示的に許可が必要 |
| 証拠上限 | エラーログ等は200行でトリム |
| 出力確認必須 | Codexの出力は「提案」。適用前に必ず差分確認とテストを実施 |
| タイムアウト | デフォルト5分。長時間実行は明示的に許可が必要 |

## エラーハンドリング

| エラー | 対処 |
|--------|------|
| `codex: command not found` | Codex CLIがインストールされていない。`npm install -g @openai/codex` |
| タイムアウト | タイムアウト値を延長するか、タスクを分割 |
| APIエラー | OpenAI APIキーの確認、レート制限の確認 |
| 権限エラー | スクリプトに実行権限を付与: `chmod +x scripts/*.sh` |
| プロンプト生成失敗 | 引数の確認、対象ファイルの存在確認 |

## サンドボックスモード

| モード | フラグ | 説明 |
|--------|--------|------|
| read-only | `-s read-only` | デフォルト。ファイル読み取りのみ |
| workspace-write | `-s workspace-write` | ワークスペースへの書き込み許可（要明示） |
| full-access | `-s danger-full-access` | 全権限（非推奨、極めて限定的に使用） |

## オプション: tmuxレイアウト

並行作業用の3ペインレイアウトを設定：
```bash
~/.claude/skills/codex-bridge/scripts/tmux_layout.sh
```
- 左: claude
- 右上: codex
- 右下: tests/log

tmuxがなくても本スキルは動作する。

## ファイル構成

```
~/.claude/skills/codex-bridge/
├── SKILL.md                    # このファイル
├── scripts/
│   ├── codex_exec.sh           # Codex実行スクリプト
│   ├── codex_prompt_build.sh   # プロンプト生成スクリプト
│   └── tmux_layout.sh          # オプション：tmuxレイアウト
├── templates/
│   └── prompt.md.tmpl          # プロンプトテンプレート
└── .codex/
    ├── prompt.md               # 生成されたプロンプト
    └── out.md                  # Codexの出力
```
