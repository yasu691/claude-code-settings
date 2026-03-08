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
#   -l, --lines NUM         証拠の最大行数 (デフォルト: 200)
#   -F, --file-lines NUM    ソースファイルの最大行数 (デフォルト: 500)
#   -h, --help              ヘルプを表示
#
# 出力:
#   生成したプロンプトファイルのパスを stdout に出力。
#   ログは stderr へ。
#
# 環境変数:
#   CODEX_EXEC_ID           実行ID (未指定時は自動生成)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CODEX_DIR="${SKILL_DIR}/.codex"

GOAL=""
FILES=""
EVIDENCE_FILE=""
CONSTRAINTS=""
MAX_EVIDENCE_LINES=200
MAX_FILE_LINES=500

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
  -l, --lines NUM         証拠の最大行数 (デフォルト: 200)
  -F, --file-lines NUM    ソースファイルの最大行数 (デフォルト: 500)
  -h, --help              このヘルプを表示

例:
  $(basename "$0") --goal "バグを修正して" --files "src/api.ts,src/utils.ts"
  $(basename "$0") -g "エラーの原因を調査" -f "src/main.ts" -e "logs/error.log"
  $(basename "$0") --goal "リファクタリング" --constraints "型安全性を維持"

出力:
  生成されたプロンプトファイルのパスを stdout に出力します。
  続けて codex_exec.sh に渡してください:
    PROMPT=\$($(basename "$0") --goal "..."); codex_exec.sh "\$PROMPT"
EOF
}

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
        -l|--lines)
            MAX_EVIDENCE_LINES="$2"
            shift 2
            ;;
        -F|--file-lines)
            MAX_FILE_LINES="$2"
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

if [[ -z "$GOAL" ]]; then
    echo "Error: --goal は必須です" >&2
    show_help
    exit 1
fi

# 実行IDの決定（マルチエージェント対応: 各実行にユニークなファイルパスを割り当て）
EXEC_ID="${CODEX_EXEC_ID:-$(date +%Y%m%d_%H%M%S)_$$}"
OUTPUT_FILE="${CODEX_DIR}/${EXEC_ID}_prompt.md"

mkdir -p "$CODEX_DIR"

# ソースファイルの埋め込み（行数上限付き）
generate_file_list() {
    local files="$1"
    if [[ -z "$files" ]]; then
        echo "(対象ファイル未指定)"
        return
    fi

    echo ""
    IFS=',' read -ra FILE_ARRAY <<< "$files"
    for file in "${FILE_ARRAY[@]}"; do
        file="${file#"${file%%[![:space:]]*}"}"  # trim leading whitespace
        file="${file%"${file##*[![:space:]]}"}"  # trim trailing whitespace
        if [[ -f "$file" ]]; then
            local total_lines
            total_lines=$(wc -l < "$file")
            echo "### $file"
            if [[ $total_lines -gt $MAX_FILE_LINES ]]; then
                echo "（${total_lines}行中、最初の${MAX_FILE_LINES}行を表示）"
                echo '```'
                head -n "$MAX_FILE_LINES" "$file"
                echo '```'
                echo "... (以下省略)"
            else
                echo '```'
                cat "$file"
                echo '```'
            fi
            echo ""
        else
            echo "### $file (ファイルが見つかりません)"
            echo ""
        fi
    done
}

# 証拠の読み込み（行数上限付き）
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

get_file_paths() {
    if [[ -z "$1" ]]; then echo "(未指定)"; else echo "$1"; fi
}

format_constraints() {
    if [[ -n "$1" ]]; then echo "- $1"; fi
}

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
- 何が問題なのか
- なぜそう判断したか（コードの該当箇所を引用）

## 2. Plan
最短手順を優先度付きで列挙してください。
1. [優先度: 高] 最初にすべきこと
2. [優先度: 中] 次にすべきこと
3. ...

## 3. Concrete edits
ファイル別に「どこをどう変えるか」を差分形式で示してください。

\`\`\`diff
- 削除する行
+ 追加する行
\`\`\`

## 4. Risks & checks
副作用のリスクと、確認すべきテストや検証項目を列挙してください。

### リスク
- [ ] リスク1: 説明

### 確認項目
- [ ] テストを実行
- [ ] 動作確認
EOF
}

echo "=== プロンプト生成 ===" >&2
echo "目標: $GOAL" >&2
echo "ファイル: ${FILES:-未指定}" >&2
echo "証拠: ${EVIDENCE_FILE:-未提供}" >&2
echo "実行ID: $EXEC_ID" >&2
echo "出力先: $OUTPUT_FILE" >&2
echo "" >&2

generate_prompt > "$OUTPUT_FILE"

echo "=== プロンプト生成完了 ===" >&2

# 生成したプロンプトファイルのパスを stdout に出力（codex_exec.sh に渡す用）
echo "$OUTPUT_FILE"
