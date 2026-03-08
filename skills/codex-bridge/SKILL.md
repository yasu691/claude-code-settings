---
name: codex-bridge
description: OpenAI Codexをセカンドオピニオン／構造化レビュー／修正案生成に活用するブリッジスキル
version: 1.1.0
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
PROMPT=$(~/.claude/skills/codex-bridge/scripts/codex_prompt_build.sh \
  --goal "目的" \
  --files "file1.ts,file2.ts" \
  --evidence "path/to/error.log" \
  --constraints "追加制約（オプション）")
```
→ stdout に生成されたプロンプトファイルのパスが出力される（例: `.codex/20260308_120000_12345_prompt.md`）
→ 実行IDはファイル名に埋め込まれるため、マルチエージェント実行でも競合しない

### Phase 3: Codex実行
```bash
~/.claude/skills/codex-bridge/scripts/codex_exec.sh "$PROMPT"
```
→ EXEC_IDはファイル名から自動推定
→ `~/.claude/skills/codex-bridge/.codex/{EXEC_ID}_out.md` に最終回答を保存
→ `.codex/latest_out.md` シンボリックリンクを更新（tmux監視用）

### Phase 4: 結果解析
出力は以下のフォーマットで構造化される：
1. **Diagnosis**: 原因仮説と根拠
2. **Plan**: 最短手順、優先度付き
3. **Concrete edits**: ファイル別に差分形式で提示
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
| ソースファイル上限 | `--files` で指定したファイルは500行でトリム（トークン爆発防止） |
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

## モデル設定

デフォルトモデルは `gpt-5.4`。変更方法：

```bash
# 方法1: 環境変数で一時変更
CODEX_MODEL=gpt-5.3-codex ~/.claude/skills/codex-bridge/scripts/codex_exec.sh prompt.md

# 方法2: スクリプトフラグで指定
codex_exec.sh prompt.md -m gpt-5.3-codex

# 方法3: ~/.codex/config.toml でグローバルデフォルト設定
# model = "gpt-5.4"
```

## オプション: tmuxレイアウト

並行作業用の3ペインレイアウトを設定：
```bash
~/.claude/skills/codex-bridge/scripts/tmux_layout.sh
```

起動すると右下ペインが `tail -f .codex/latest_out.md` で自動起動し、
Codex実行完了と同時に最終回答が表示される。

```
┌─────────────────┬─────────────────┐
│                 │  codex-log      │  ← codex実行ログ (stderr)
│     claude      ├─────────────────┤
│                 │  codex-output   │  ← tail -f latest_out.md
└─────────────────┴─────────────────┘
```

tmuxがなくても本スキルは動作する。

## マルチエージェント対応

複数のエージェントが同時に本スキルを使っても、実行IDによりファイルが分離される。

```
.codex/
├── 20260308_120001_11111_prompt.md  ← Agent A
├── 20260308_120001_11111_out.md
├── 20260308_120002_22222_prompt.md  ← Agent B
├── 20260308_120002_22222_out.md
└── latest_out.md -> 20260308_120002_22222_out.md  ← 最新のシンボリックリンク
```

古いファイルは7日後に自動削除される。

## ファイル構成

```
~/.claude/skills/codex-bridge/
├── SKILL.md                    # このファイル
├── scripts/
│   ├── codex_exec.sh           # Codex実行スクリプト
│   ├── codex_prompt_build.sh   # プロンプト生成スクリプト
│   └── tmux_layout.sh          # オプション：tmuxレイアウト
└── .codex/
    ├── {EXEC_ID}_prompt.md     # 生成されたプロンプト（実行IDごと）
    ├── {EXEC_ID}_out.md        # Codexの最終回答（実行IDごと）
    ├── {EXEC_ID}_err.log       # エラーログ（実行IDごと）
    └── latest_out.md           # 最新out.mdへのシンボリックリンク
```
