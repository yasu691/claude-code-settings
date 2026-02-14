#!/usr/bin/env bash
#
# tmux_layout.sh - Codex Bridge用tmuxレイアウト設定
#
# 3ペインレイアウトを設定:
#   - 左: claude (メイン作業)
#   - 右上: codex (Codex出力)
#   - 右下: tests/log (テスト/ログ監視)
#
# 使用法:
#   tmux_layout.sh [session_name]
#
# オプション:
#   session_name    tmuxセッション名 (デフォルト: codex-bridge)
#   -h, --help      ヘルプを表示
#

set -euo pipefail

SESSION_NAME="${1:-codex-bridge}"

# ヘルプ表示
show_help() {
    cat << EOF
Codex Bridge用tmuxレイアウト設定

使用法:
  $(basename "$0") [session_name]

引数:
  session_name    tmuxセッション名 (デフォルト: codex-bridge)

オプション:
  -h, --help      このヘルプを表示

レイアウト:
  ┌─────────────────┬─────────────────┐
  │                 │     codex       │
  │     claude      ├─────────────────┤
  │                 │   tests/log     │
  └─────────────────┴─────────────────┘

例:
  $(basename "$0")
  $(basename "$0") my-session
EOF
}

# 引数解析
if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

# tmuxの存在確認
if ! command -v tmux &> /dev/null; then
    echo "Warning: tmux がインストールされていません" >&2
    echo "tmuxなしでもcodex-bridgeスキルは動作しますが、並行作業はできません" >&2
    echo "" >&2
    echo "インストール方法:" >&2
    echo "  macOS: brew install tmux" >&2
    echo "  Ubuntu: sudo apt install tmux" >&2
    exit 0
fi

# 既存セッションの確認
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "セッション '$SESSION_NAME' は既に存在します" >&2
    echo "接続: tmux attach -t $SESSION_NAME" >&2
    echo "削除: tmux kill-session -t $SESSION_NAME" >&2
    exit 1
fi

echo "=== tmuxレイアウト設定 ===" >&2
echo "セッション名: $SESSION_NAME" >&2
echo "" >&2

# セッション作成（左ペイン: claude）
tmux new-session -d -s "$SESSION_NAME" -n main

# 右側に縦分割（右上: codex）
tmux split-window -h -t "$SESSION_NAME:main"

# 右側を水平分割（右下: tests/log）
tmux split-window -v -t "$SESSION_NAME:main.1"

# ペインのサイズ調整（左を60%に）
tmux resize-pane -t "$SESSION_NAME:main.0" -x 60%

# 各ペインの名前を設定（表示用）
tmux select-pane -t "$SESSION_NAME:main.0" -T "claude"
tmux select-pane -t "$SESSION_NAME:main.1" -T "codex"
tmux select-pane -t "$SESSION_NAME:main.2" -T "tests/log"

# 左ペイン（claude）を選択
tmux select-pane -t "$SESSION_NAME:main.0"

echo "=== レイアウト設定完了 ===" >&2
echo "" >&2
echo "レイアウト:" >&2
echo "  ┌─────────────────┬─────────────────┐" >&2
echo "  │                 │     codex       │" >&2
echo "  │     claude      ├─────────────────┤" >&2
echo "  │                 │   tests/log     │" >&2
echo "  └─────────────────┴─────────────────┘" >&2
echo "" >&2
echo "接続: tmux attach -t $SESSION_NAME" >&2
echo "" >&2
echo "ペイン移動:" >&2
echo "  Ctrl-b + 矢印キー: ペイン間移動" >&2
echo "  Ctrl-b + z: ペインのズーム切り替え" >&2
