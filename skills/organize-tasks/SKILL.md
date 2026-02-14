---
name: organize-tasks
description: |
  GitHub Projects の Inbox タスクを対話的に整理するスキル。
  ユーザーが "タスクを整理", "organize tasks", "Inbox整理" と言った時に使用。
  タスク一覧を表示し、選択されたタスクについてゴール・次アクション・優先度をヒアリングして更新する。
version: 1.0.0
author: asai
---

# タスク整理スキル

GitHub ProjectsのInboxにある未整理タスクを対話でReady状態にする。

## 使用法

```
/organize-tasks
```

トリガーワード: "タスクを整理", "タスク整理", "organize tasks", "Inbox整理"

## ワークフロー

### Phase 1: Inbox一覧取得・表示

1. GitHub ProjectsからStatus=Inboxのタスクを取得

```bash
gh project item-list 1 --owner "@me" --format json | jq '[.items[] | select(.status == "Inbox")]'
```

2. 取得したタスクを一覧表示:
   - Issue番号
   - タイトル
   - 現状（ゴール設定済み/未設定、次アクション設定済み/未設定）

3. 0件の場合は「Inboxは空です。整理するタスクがありません。」と表示して終了

### Phase 2: 整理対象の選択

AskUserQuestionを使用してユーザーに整理するタスクを選択させる:

```yaml
question: "どのタスクを整理しますか？"
header: "選択"
multiSelect: true
options:
  - label: "全部整理する"
    description: "Inbox内の全タスクを順番に整理"
  - label: "#12 API設計"
    description: "現状: ゴール未設定"
  - label: "#15 ドキュメント作成"
    description: "現状: 次アクション未設定"
  # 動的に生成（最大3件表示）
  # 残りはOtherで番号指定
```

### Phase 3: 各タスクのヒアリング

選択されたタスクごとに以下を順番にヒアリング:

#### Q1: ゴール（Definition of Done）

```yaml
question: "#12「API設計」のゴール（完了条件）は？"
header: "ゴール"
multiSelect: false
options:
  - label: "現状維持"
    description: "既存のゴールをそのまま使う"
  # ユーザーは「Other」でフリーテキスト入力可能
```

#### Q2: 次アクション（複数可）

次アクションは複数のチェックボックスで管理する。
ユーザーに繰り返し質問し、「完了」が選択されるまで追加を続ける。

```yaml
# 1回目
question: "次アクションを追加してください（1件目）"
header: "Next Action"
multiSelect: false
options:
  - label: "現状維持"
    description: "既存の次アクションをそのまま使う"
  # ユーザーは「Other」でフリーテキスト入力

# 2回目以降（「現状維持」「完了」以外が選択された場合）
question: "次アクションを追加しますか？"
header: "追加"
multiSelect: false
options:
  - label: "完了"
    description: "次アクションの追加を終了"
  # ユーザーは「Other」で追加のアクションを入力
```

**ヒアリングフロー:**
1. 「現状維持」→ 既存のチェックボックスを保持、次の質問へ
2. 「Other」で入力 → リストに追加し、再度「追加しますか？」を質問
3. 「完了」→ 次アクションのヒアリング終了、優先度の質問へ

#### Q3: 優先度

```yaml
question: "優先度は？"
header: "Priority"
multiSelect: false
options:
  - label: "P0 - 緊急"
    description: "今すぐ対応"
  - label: "P1 - 今週"
    description: "今週中に着手"
  - label: "P2 - 通常"
    description: "近いうちに"
  - label: "P3 - Backlog"
    description: "そのうち"
```

### Phase 4: 更新実行

ヒアリング結果に基づいてIssueを更新:

#### 4.1 Issue本文更新

既存のIssue本文に以下のセクションを追加/更新:

```markdown
## ゴール（Definition of Done）
[ヒアリングで設定したゴール]

## 次アクション（Next Action）
- [ ] [アクション1]
- [ ] [アクション2]
- [ ] [アクション3]
（ヒアリングで追加された分だけチェックボックスを生成）
```

**更新ルール:**
- 「現状維持」の場合: 既存の次アクションセクションをそのまま保持
- 新規追加の場合: 既存のチェックボックス（完了済み含む）は保持し、新しいアクションを末尾に追加

コマンド:
```bash
# 現在の本文を取得
gh issue view <NUMBER> --json body -q '.body'

# 本文を更新（ゴール・次アクションを追加）
gh issue edit <NUMBER> --body "..."
```

#### 4.2 優先度ラベル更新

```bash
# 既存のpriority:*ラベルを削除
gh issue edit <NUMBER> --remove-label "priority:P0,priority:P1,priority:P2,priority:P3"

# 新しい優先度ラベルを追加
gh issue edit <NUMBER> --add-label "priority:P2"
```

#### 4.3 Status更新（Inbox → Ready）

```bash
# Project Item IDを取得
ITEM_ID=$(gh project item-list 1 --owner "@me" --format json | jq -r '.items[] | select(.content.number == <NUMBER>) | .id')

# Statusフィールドを更新
gh project item-edit --project-id <PROJECT_ID> --id "$ITEM_ID" --field-id <STATUS_FIELD_ID> --single-select-option-id <READY_OPTION_ID>
```

#### 4.4 結果サマリー表示

```
## 整理完了

| Issue | タイトル | ゴール | 次アクション | 優先度 |
|-------|----------|--------|--------------|--------|
| #12 | API設計 | ○ 設定 | ○ 設定 | P1 |
| #15 | ドキュメント作成 | ○ 設定 | ○ 設定 | P2 |

全てのタスクがReady状態になりました。
```

## gh CLI コマンドリファレンス

### Project情報取得

```bash
# Projectリスト
gh project list --owner "@me" --format json

# Project Item一覧
gh project item-list <PROJECT_NUMBER> --owner "@me" --format json

# Projectフィールド情報
gh project field-list <PROJECT_NUMBER> --owner "@me" --format json
```

### Issue操作

```bash
# Issue詳細取得
gh issue view <NUMBER> --json number,title,body,labels

# Issue本文更新
gh issue edit <NUMBER> --body "<NEW_BODY>"

# ラベル操作
gh issue edit <NUMBER> --add-label "priority:P1"
gh issue edit <NUMBER> --remove-label "priority:P0"
```

### Project Item操作

```bash
# Status変更
gh project item-edit --project-id <PROJECT_ID> --id <ITEM_ID> --field-id <FIELD_ID> --single-select-option-id <OPTION_ID>
```

## 注意事項

- Issue本文を更新する際は、既存の内容を保持しつつゴール/次アクションセクションを追加する
- **次アクションは複数のチェックボックスで管理**: ユーザーが「完了」を選択するまで繰り返し追加可能
- 既存の次アクション（完了済みチェックボックス含む）は保持し、新規アクションは末尾に追加
- 優先度ラベルは `priority:P0`, `priority:P1`, `priority:P2`, `priority:P3` の形式を使用
- StatusフィールドのIDとオプションIDはProject設定により異なるため、事前に取得が必要
- 「現状維持」が選択された場合は、そのフィールドの更新をスキップする

## エラーハンドリング

| エラー | 対処 |
|--------|------|
| `gh: command not found` | GitHub CLIがインストールされていない |
| 認証エラー | `gh auth login` で認証 |
| Projectが見つからない | Project番号を確認 |
| フィールドIDエラー | `gh project field-list` でID確認 |
