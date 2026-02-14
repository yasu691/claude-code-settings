#!/usr/bin/env bash
#
# codex_prompt_build.sh - Codex用プロンプト生成スクリプト
#
# 使用法:
#   codex_prompt_build.sh --goal "目的" --files "file1,file2" [options]
#
# オプション:
#   -g, --goal TEXT         達成目標（必須）
#   -f, --files FILES       対象ファイル（カンマ区切り）
#   -e, --evidence FILE     エラーログや差分ファイルのパス
#   -c, --constraints TEXT  追加制約
#   -o, --output FILE       出力ファイル (デフォルト: .codex/prompt.md)
#   -l, --lines NUM         証拠の最大行数 (デフォルト: 200)
#   -h, --help              ヘルプを表示
#

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CODEX_DIR="${SKILL_DIR}/.codex"
TEMPLATE_FILE="${SKILL_DIR}/templates/prompt.md.tmpl"

# デフォルト値
GOAL=""
FILES=""
EVIDENCE_FILE=""
CONSTRAINTS=""
OUTPUT_FILE="${CODEX_DIR}/prompt.md"
MAX_EVIDENCE_LINES=200

# ヘルプ表示
show_help() {
    cat << EOF
Codex用プロンプト生成スクリプト

使用法:
  $(basename "$0") --goal "目的" [options]

必須オプション:
  -g, --goal TEXT         達成目標

オプション:
  -f, --files FILES       対象ファイル（カンマ区切り）
  -e, --evidence FILE     エラーログや差分ファイルのパス
  -c, --constraints TEXT  追加制約
  -o, --output FILE       出力ファイル (デフォルト: .codex/prompt.md)
  -l, --lines NUM         証拠の最大行数 (デフォルト: 200)
  -h, --help              このヘルプを表示

例:
  $(basename "$0") --goal "バグを修正して" --files "src/api.ts,src/utils.ts"
  $(basename "$0") -g "エラーの原因を調査" -f "src/main.ts" -e "logs/error.log"
  $(basename "$0") --goal "リファクタリング" --constraints "型安全性を維持"
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--goal)
            GOAL="$2"
            shift 2
            ;;
        -f|--files)
            FILES="$2"
            shift 2
            ;;
        -e|--evidence)
            EVIDENCE_FILE="$2"
            shift 2
            ;;
        -c|--constraints)
            CONSTRAINTS="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -l|--lines)
            MAX_EVIDENCE_LINES="$2"
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
            echo "Error: 不明な引数: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# 必須引数の確認
if [[ -z "$GOAL" ]]; then
    echo "Error: --goal は必須です" >&2
    show_help
    exit 1
fi

# 出力ディレクトリの確認
OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# ファイルリストの生成
generate_file_list() {
    local files="$1"
    if [[ -z "$files" ]]; then
        echo "(対象ファイル未指定)"
        return
    fi

    echo ""
    IFS=',' read -ra FILE_ARRAY <<< "$files"
    for file in "${FILE_ARRAY[@]}"; do
        file="$(echo "$file" | xargs)"  # trim whitespace
        if [[ -f "$file" ]]; then
            echo "### $file"
            echo '```'
            cat "$file"
            echo '```'
            echo ""
        else
            echo "### $file (ファイルが見つかりません)"
            echo ""
        fi
    done
}

# 証拠の読み込み
read_evidence() {
    local evidence_file="$1"
    local max_lines="$2"

    if [[ -z "$evidence_file" ]]; then
        echo "(証拠未提供)"
        return
    fi

    if [[ ! -f "$evidence_file" ]]; then
        echo "(証拠ファイルが見つかりません: $evidence_file)"
        return
    fi

    local total_lines
    total_lines=$(wc -l < "$evidence_file")

    if [[ $total_lines -gt $max_lines ]]; then
        echo "（${total_lines}行中、最初の${max_lines}行を表示）"
        echo '```'
        head -n "$max_lines" "$evidence_file"
        echo '```'
        echo "... (以下省略)"
    else
        echo '```'
        cat "$evidence_file"
        echo '```'
    fi
}

# 追加制約の生成
format_constraints() {
    local constraints="$1"
    if [[ -n "$constraints" ]]; then
        echo "- $constraints"
    fi
}

# ファイルリスト（パスのみ）
get_file_paths() {
    local files="$1"
    if [[ -z "$files" ]]; then
        echo "(未指定)"
    else
        echo "$files"
    fi
}

# プロンプト生成
generate_prompt() {
    cat << EOF
# Role
あなたはCodex。非対話モードで動作し、提案のみを行う。実際の適用は人間が行う。

# Goal
${GOAL}

# Constraints
- read-only前提（変更は提案のみ）
- 変更範囲: $(get_file_paths "$FILES")
- スタイル: 既存のlint/formatに従う
$(format_constraints "$CONSTRAINTS")

# Forbidden
- 秘密情報（鍵・個人情報・社外秘URL・顧客データ）の出力禁止
- 実行時の副作用を持つコードの実行禁止

# Context

## 対象ファイル
$(generate_file_list "$FILES")

## 証拠（エラーログ/差分）
$(read_evidence "$EVIDENCE_FILE" "$MAX_EVIDENCE_LINES")

# Required Output Format
以下のフォーマットで回答してください：

## 1. Diagnosis
原因仮説と根拠を説明してください。

## 2. Plan
最短手順を優先度付きで列挙してください。

## 3. Concrete edits
ファイル別に「どこをどう変えるか」を具体的に示してください。
差分形式またはコードブロックで明示してください。

## 4. Risks & checks
副作用のリスクと、確認すべきテストや検証項目を列挙してください。
EOF
}

# プロンプト生成と保存
echo "=== プロンプト生成 ===" >&2
echo "目標: $GOAL" >&2
echo "ファイル: ${FILES:-未指定}" >&2
echo "証拠: ${EVIDENCE_FILE:-未提供}" >&2
echo "出力先: $OUTPUT_FILE" >&2
echo "" >&2

generate_prompt > "$OUTPUT_FILE"

echo "=== プロンプト生成完了 ===" >&2
echo "生成されたプロンプト: $OUTPUT_FILE" >&2
