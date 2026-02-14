#!/usr/bin/env bash
#
# codex_exec.sh - Codex実行スクリプト
#
# 使用法:
#   codex_exec.sh <prompt_file> [options]
#
# オプション:
#   -s, --sandbox MODE    サンドボックスモード (read-only|workspace-write|danger-full-access)
#   -o, --output FILE     出力ファイル (デフォルト: .codex/out.md)
#   -h, --help            ヘルプを表示
#

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CODEX_DIR="${SKILL_DIR}/.codex"

# デフォルト値
SANDBOX_MODE="read-only"
OUTPUT_FILE="${CODEX_DIR}/out.md"
PROMPT_FILE=""

# ヘルプ表示
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
  -o, --output FILE     出力ファイル (デフォルト: .codex/out.md)
  -h, --help            このヘルプを表示

例:
  $(basename "$0") prompt.md
  $(basename "$0") prompt.md -s workspace-write
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--sandbox)
            SANDBOX_MODE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
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

# プロンプトファイルの確認
if [[ -z "$PROMPT_FILE" ]]; then
    echo "Error: プロンプトファイルが指定されていません" >&2
    show_help
    exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "Error: プロンプトファイルが見つかりません: $PROMPT_FILE" >&2
    exit 1
fi

# サンドボックスモードの検証
case "$SANDBOX_MODE" in
    read-only|workspace-write|danger-full-access)
        ;;
    *)
        echo "Error: 無効なサンドボックスモード: $SANDBOX_MODE" >&2
        echo "有効なモード: read-only, workspace-write, danger-full-access" >&2
        exit 1
        ;;
esac

# 危険なモードの警告
if [[ "$SANDBOX_MODE" == "danger-full-access" ]]; then
    echo "WARNING: danger-full-access モードは極めて危険です。本当に必要な場合のみ使用してください。" >&2
fi

# Codexの存在確認
if ! command -v codex &> /dev/null; then
    echo "Error: codex コマンドが見つかりません" >&2
    echo "インストール: npm install -g @openai/codex" >&2
    exit 1
fi

# 出力ディレクトリの確認
OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# プロンプト内容を読み込み
PROMPT_CONTENT="$(cat "$PROMPT_FILE")"

echo "=== Codex実行開始 ===" >&2
echo "プロンプト: $PROMPT_FILE" >&2
echo "サンドボックス: $SANDBOX_MODE" >&2
echo "出力先: $OUTPUT_FILE" >&2
echo "" >&2

# Codex実行
# codex exec はファイルから直接読むか、パイプで渡す
codex exec \
    --sandbox "$SANDBOX_MODE" \
    "$PROMPT_CONTENT" \
    > "$OUTPUT_FILE" 2>&1
EXIT_CODE=$?

# 結果の処理
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "" >&2
    echo "=== Codex実行完了 ===" >&2
    echo "出力: $OUTPUT_FILE" >&2
    # 標準出力にも出力
    cat "$OUTPUT_FILE"
else
    echo "" >&2
    echo "Error: Codex実行エラー (exit code: $EXIT_CODE)" >&2
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo "エラー詳細:" >&2
        cat "$OUTPUT_FILE" >&2
    fi
    exit $EXIT_CODE
fi
