#!/usr/bin/env bash
#
# tmux_layout.sh - Codex Bridge用tmuxレイアウト設定
#
# 3ペインレイアウトを設定:
#   - 左: claude (メイン作業)
#   - 右上: codex実行ログ (stdout)
#   - 右下: tail -f latest_out.md (Codex最終回答をリアルタイム監視)
#
# 使用法:
#   tmux_layout.sh [session_name]
#
# オプション:
#   session_name    tmuxセッション名 (デフォルト: codex-bridge)
#   -h, --help      ヘルプを表示
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CODEX_DIR="${SKILL_DIR}/.codex"
LATEST_OUT="${CODEX_DIR}/latest_out.md"

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
  │                 │  codex stdout   │
  │     claude      ├─────────────────┤
  │                 │ tail -f out.md  │
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
tmux select-pane -t "$SESSION_NAME:main.1" -T "codex-log"
tmux select-pane -t "$SESSION_NAME:main.2" -T "codex-output"

# 右下ペイン（codex-output）でlatest_out.mdをリアルタイム監視
mkdir -p "$CODEX_DIR"
# latest_out.mdがなければ空ファイルを作成（tail -f が即座に起動できるよう）
[[ -f "$LATEST_OUT" ]] || touch "$LATEST_OUT"
tmux send-keys -t "$SESSION_NAME:main.2" \
    "echo 'Codex出力を待機中...' && tail -f '${LATEST_OUT}'" Enter

# 左ペイン（claude）を選択
tmux select-pane -t "$SESSION_NAME:main.0"

echo "=== レイアウト設定完了 ===" >&2
echo "" >&2
echo "レイアウト:" >&2
echo "  ┌─────────────────┬─────────────────┐" >&2
echo "  │                 │  codex-log      │" >&2
echo "  │     claude      ├─────────────────┤" >&2
echo "  │                 │  codex-output   │" >&2
echo "  │                 │  (tail -f)      │" >&2
echo "  └─────────────────┴─────────────────┘" >&2
echo "" >&2
echo "接続: tmux attach -t $SESSION_NAME" >&2
echo "" >&2
echo "ペイン移動:" >&2
echo "  Ctrl-b + 矢印キー: ペイン間移動" >&2
echo "  Ctrl-b + z: ペインのズーム切り替え" >&2
