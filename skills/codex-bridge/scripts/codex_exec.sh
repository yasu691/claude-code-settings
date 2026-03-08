#!/usr/bin/env bash
#
# codex_exec.sh - Codex実行スクリプト
#
# 使用法:
#   codex_exec.sh <prompt_file> [options]
#
# オプション:
#   -s, --sandbox MODE    サンドボックスモード (read-only|workspace-write|danger-full-access)
#   -m, --model MODEL     使用モデル (デフォルト: $CODEX_MODEL または gpt-5.4)
#   -h, --help            ヘルプを表示
#
# 環境変数:
#   CODEX_MODEL           デフォルトモデル (スクリプト引数で上書き可)
#   CODEX_EXEC_ID         実行ID (未指定時はファイル名から推定 or 自動生成)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CODEX_DIR="${SKILL_DIR}/.codex"

SANDBOX_MODE="read-only"
MODEL="${CODEX_MODEL:-gpt-5.4}"
PROMPT_FILE=""
EXEC_ID="${CODEX_EXEC_ID:-}"

show_help() {
    cat << EOF
Codex実行スクリプト

使用法:
  $(basename "$0") <prompt_file> [options]

引数:
  prompt_file           プロンプトファイルのパス

オプション:
  -s, --sandbox MODE    サンドボックスモード (デフォルト: read-only)
                        - read-only: ファイル読み取りのみ
                        - workspace-write: ワークスペースへの書き込み許可
                        - danger-full-access: 全権限（非推奨）
  -m, --model MODEL     使用モデル (デフォルト: gpt-5.4)
  -h, --help            このヘルプを表示

例:
  $(basename "$0") .codex/20260308_120000_12345_prompt.md
  $(basename "$0") .codex/20260308_120000_12345_prompt.md -s workspace-write -m gpt-5.3-codex

環境変数:
  CODEX_MODEL=gpt-5.3-codex $(basename "$0") prompt.md
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--sandbox)
            SANDBOX_MODE="$2"
            shift 2
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: 不明なオプション: $1" >&2
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$PROMPT_FILE" ]]; then
                PROMPT_FILE="$1"
            else
                echo "Error: 複数のプロンプトファイルが指定されました" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$PROMPT_FILE" ]]; then
    echo "Error: プロンプトファイルが指定されていません" >&2
    show_help
    exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "Error: プロンプトファイルが見つかりません: $PROMPT_FILE" >&2
    exit 1
fi

case "$SANDBOX_MODE" in
    read-only|workspace-write|danger-full-access) ;;
    *)
        echo "Error: 無効なサンドボックスモード: $SANDBOX_MODE" >&2
        echo "有効なモード: read-only, workspace-write, danger-full-access" >&2
        exit 1
        ;;
esac

if [[ "$SANDBOX_MODE" == "danger-full-access" ]]; then
    echo "WARNING: danger-full-access モードは極めて危険です。本当に必要な場合のみ使用してください。" >&2
fi

if ! command -v codex &> /dev/null; then
    echo "Error: codex コマンドが見つかりません" >&2
    echo "インストール: npm install -g @openai/codex" >&2
    exit 1
fi

# EXEC_IDの決定: 環境変数 → ファイル名から推定 → 新規生成
if [[ -z "$EXEC_ID" ]]; then
    BASENAME="$(basename "$PROMPT_FILE")"
    if [[ "$BASENAME" =~ ^([0-9]{8}_[0-9]{6}_[0-9]+)_prompt\.md$ ]]; then
        EXEC_ID="${BASH_REMATCH[1]}"
    else
        EXEC_ID="$(date +%Y%m%d_%H%M%S)_$$"
    fi
fi

OUTPUT_FILE="${CODEX_DIR}/${EXEC_ID}_out.md"
ERROR_FILE="${CODEX_DIR}/${EXEC_ID}_err.log"
LATEST_SYMLINK="${CODEX_DIR}/latest_out.md"

mkdir -p "$CODEX_DIR"

echo "=== Codex実行開始 ===" >&2
echo "プロンプト: $PROMPT_FILE" >&2
echo "サンドボックス: $SANDBOX_MODE" >&2
echo "モデル: $MODEL" >&2
echo "実行ID: $EXEC_ID" >&2
echo "出力先: $OUTPUT_FILE" >&2
echo "" >&2

# プロンプトをstdinで渡す（シェルインジェクション回避）
# --output-last-message でエージェント最終回答のみをファイルに書き込む
codex exec \
    --sandbox "$SANDBOX_MODE" \
    --model "$MODEL" \
    --output-last-message "$OUTPUT_FILE" \
    < "$PROMPT_FILE" \
    2>"$ERROR_FILE"
EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    # latest_out.md シンボリックリンクを最新出力へ更新（tmux tail -f 用）
    ln -sf "$(basename "$OUTPUT_FILE")" "$LATEST_SYMLINK"

    echo "" >&2
    echo "=== Codex実行完了 ===" >&2
    echo "出力: $OUTPUT_FILE" >&2
    cat "$OUTPUT_FILE"
else
    echo "" >&2
    echo "Error: Codex実行エラー (exit code: $EXIT_CODE)" >&2
    if [[ -s "$ERROR_FILE" ]]; then
        echo "エラー詳細:" >&2
        cat "$ERROR_FILE" >&2
    fi
    exit $EXIT_CODE
fi

# 7日以上前の実行ファイルをクリーンアップ
find "$CODEX_DIR" -name "[0-9]*_prompt.md" -mtime +7 -delete 2>/dev/null || true
find "$CODEX_DIR" -name "[0-9]*_out.md" -mtime +7 -delete 2>/dev/null || true
find "$CODEX_DIR" -name "[0-9]*_err.log" -mtime +7 -delete 2>/dev/null || true
