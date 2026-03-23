---
name: multi-review
description: 変更差分やPlanを多角的にレビューする。観点は自動判定、Subagent並列 + Codexクロスモデル
---

## Usage

```bash
/multi-review              # 未コミットの変更をレビュー
/multi-review HEAD~3       # 直近3コミットをレビュー
/multi-review <path>       # 指定ファイル/ディレクトリをレビュー
/multi-review --plan       # 直前のPlanをレビュー
```

## 自動トリガー条件

高リスク変更時のみ自動実行する。それ以外は `/multi-review` で手動実行。

高リスクの例: 変更ファイル2件以上 / 認証・外部I/O・設定変更・削除処理・データ移行を含む / Planが3ステップ以上 / 破壊的変更を含む

## Output Contract

最終出力は `CRITICAL / WARNING / INFO` の3段階。下位レビュアーが別体系を使う場合は正規化する:
- P0, P1 → CRITICAL
- P2 → WARNING
- P3 → INFO

## 手順

### 1. レビュー対象の取得

- 引数なし: `git diff` + `git diff --staged`
- `HEAD~N`: `git diff HEAD~N..HEAD`
- ファイルパス: 直接読む
- `--plan`: 直前の会話で合意したPlan内容

### 2. レビュー観点の判定

変更内容から関連するレビュー観点を判定する（シンプルさの観点を常に含むこと）。判定根拠を出力に必ず明記する。

### 3. Subagent + Codex の並列実行

各観点でSubagentを並列スポーンする。`subagent_type` は利用可能なものを優先し、未存在なら `general-purpose` にフォールバック。ツールは Read, Grep, Glob, Bash（書き込み不可）。

Subagentへの指示:
- 「{観点名}」の専門家として批判的にレビューせよ
- 「問題なし」で済ませず潜在リスクを探せ
- 各指摘に severity / 該当箇所 / 問題 / 推奨 / 理由 を含めよ

**Codex（並列）**: `/codex-bridge` 経由で「Claudeが見落としそうな問題点を指摘せよ」と投げる。失敗時はClaude-onlyで継続し、出力に `degraded mode: Claude-only` を明記する。

### 4. 結果統合

- 重複指摘はマージ（最も深刻なseverityを採用）
- Claude vs Codex で矛盾する指摘は両方残し相違を明記
- CRITICAL は冒頭で強調

### 5. 対応

全指摘をユーザーに提示する。修正はレビュー完了後の別ステップとして扱う。
