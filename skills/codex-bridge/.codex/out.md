OpenAI Codex v0.98.0 (research preview)
--------
workdir: /Users/yasutaka/repo/private-note-vault
model: gpt-5.3-codex
provider: openai
approval: never
sandbox: read-only
reasoning effort: xhigh
reasoning summaries: auto
session id: 019ccdaa-7bc9-74a2-8675-b17e4d824b72
--------
user
# Role
あなたはCodex。非対話モードで動作し、提案のみを行う。実際の適用は人間が行う。

# Goal
確定申告の税務計算レビュー：国庫補助金不算入申請の有利不利判定

# Constraints
- read-only前提（変更は提案のみ）
- 変更範囲: (未指定)
- スタイル: 既存のlint/formatに従う
- 税務計算の正確性・令和7年分所得税・認定長期優良住宅の住宅ローン控除ルール

# Forbidden
- 秘密情報（鍵・個人情報・社外秘URL・顧客データ）の出力禁止
- 実行時の副作用を持つコードの実行禁止

# Context

## 対象ファイル
(対象ファイル未指定)

## 証拠（エラーログ/差分）
(証拠ファイルが見つかりません: ## 状況
- ペアローンで住宅購入
- 夫のローン: 4300万円スタート（頭金なし）
- 年末残高予定: 42,281,768円
- 住宅種別: 認定長期優良住宅（認定通知書あり）
- 補助金: 子育てエコホーム支援事業 100万円（夫名義）
- 申告: 令和7年分 所得税（e-Tax提出済み）
- 借入限度額: 4500万円（認定長期優良住宅、令和6・7年入居）

## 私の計算結果

### 国庫補助金不算入申請をした場合の住宅ローン控除への影響
- 持分対応取得価額 − 補助金 = 4300万 − 100万 = 4200万円
- 年末残高 = 4228万1768円
- 差額 = 28万1768円
- 控除減 = 28万1768 × 0.7% ≈ 1,972円（今年1年分のみ）

### 比較
- 不算入申請で控除減: 約2,000円（今年のみ）
- 不算入申請で節税（一時所得回避）: 約37,500〜75,000円（税率15〜30%）

### 結論
国庫補助金不算入を申請した方が圧倒的に得。更正の請求で修正すべき。

## レビュー依頼
1. 計算・前提に誤りや見落としはないか
2. 更正の請求以外に考慮すべき手続きはあるか
3. その他リスクや注意点)

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
mcp startup: no servers
2026-03-08T13:37:09.814803Z ERROR codex_api::endpoint::responses: error=http 403 Forbidden: Some("")
Reconnecting... 1/5 (unexpected status 403 Forbidden: Unknown error, url: https://chatgpt.com/backend-api/codex/responses, cf-ray: 9d923b99fdfc9802-NRT)
2026-03-08T13:37:13.197462Z ERROR codex_api::endpoint::responses: error=http 403 Forbidden: Some("")
Reconnecting... 2/5 (unexpected status 403 Forbidden: Unknown error, url: https://chatgpt.com/backend-api/codex/responses, cf-ray: 9d923ba63ac0d50f-NRT)
codex
依頼内容を把握しました。まずリポジトリ規約に従うため、`System/Rules/vault-operating-rules.md` と関連ルールを確認し、その後に税制要件（令和7年分・認定長期優良住宅）を一次情報で照合して判定します。
exec
/bin/zsh -lc "sed -n '1,220p' System/Rules/task-management-policy.md" in /Users/yasutaka/repo/private-note-vaultexec
/bin/zsh -lc "sed -n '1,220p' System/Rules/vault-operating-rules.md" in /Users/yasutaka/repo/private-note-vaultexec
/bin/zsh -lc 'pwd && ls -la' in /Users/yasutaka/repo/private-note-vault succeeded in 52ms:
# タスク管理ポリシー

最終更新: 2026-02-23（大量起票パターンを追加）

## 方針

人生全般のタスク・やりたいこと・ライフイベントを **GitHub Issues + GitHub Projects** で一元管理する。

- タスクの正本は GitHub Issues に置く
- GitHub Projects は「ビュー」（カンバン表示、並び替え、フィルタ）として使う
- スマホからは Issue の作成とクローズだけ行う（GitHub Mobile で十分実用的）
- vault はナレッジベースであり、タスク管理には使わない

## Issue の粒度

成果物・マイルストーン単位（数日〜数週間）で1 Issue とする。

- 良い例: 「引っ越し先を決める」「トークン管理を分離する」「必要書類を集める」
- 大きすぎる例: 「引っ越し」「認証基盤リファクタ」（これはプロジェクト単位）
- 小さすぎる例: 「不動産サイトを3件見る」「関数名を変更する」（これはサブタスク）
 succeeded in 50ms:
# Vault Operating Rules (DERJA)

最終更新: 2026-02-23

このファイルは、この vault の一次ルールです。  
この vault は Zettelkasten ではなく、**DERJA（デアジャ）方式**で運用します。

## 1. 目的

- この vault はタスク管理ツールではなく、**テキストナレッジベース**として使う。
- 保存対象は「背景」「判断理由」「学び」「参照情報」。
- 実行管理（ステータス、担当、期限）は外部ツールに任せる。

## 2. フォルダ方式（DERJA）

- `Domains/`: 継続責務。終わりがない領域（家庭、健康、家計、仕事方針など）。
- `Events/`: 期限付きライフイベント。完了条件があるもの（妊娠・出産、引っ越し、確定申告など）。
- `Resources/`: 参照情報、調査メモ、再利用したい知識。
- `Journal/`: 日次・週次のログ。原則として時系列で保管。
- `Archive/`: 完了済み/非アクティブのノート。
 succeeded in 51ms:
/Users/yasutaka/repo/private-note-vault
total 5480
drwxr-xr-x   32 yasutaka  staff    1024 Mar  8 12:11 .
drwxr-xr-x@  28 yasutaka  staff     896 Jan 10 12:09 ..
-rw-r--r--@   1 yasutaka  staff   10244 Dec  7 23:50 .DS_Store
drwxr-xr-x    4 yasutaka  staff     128 Mar  8 11:23 .claude
drwxr-xr-x@   3 yasutaka  staff      96 Oct 19 16:49 .cursor
drwxr-xr-x   15 yasutaka  staff     480 Mar  8 22:36 .git
drwxr-xr-x    4 yasutaka  staff     128 Feb 23 15:30 .github
-rw-r--r--@   1 yasutaka  staff     268 Feb 14 11:16 .gitignore
drwxr-xr-x   15 yasutaka  staff     480 Feb  8 20:54 .obsidian
drwxr-xr-x@   6 yasutaka  staff     192 Feb 11 10:39 .serena
drwxr-xr-x   56 yasutaka  staff    1792 Feb 23 14:24 .trash
lrwxr-xr-x@   1 yasutaka  staff       9 Feb 23 15:19 AGENTS.md -> CLAUDE.md
drwxr-xr-x@   7 yasutaka  staff     224 Feb 23 23:23 Archive
-rw-r--r--@   1 yasutaka  staff    1631 Feb 23 15:34 CLAUDE.md
drwxr-xr-x@   5 yasutaka  staff     160 Feb 28 10:34 Domains
drwxr-xr-x@   5 yasutaka  staff     160 Feb 23 15:10 Events
drwxr-xr-x@ 140 yasutaka  staff    4480 Mar  7 16:10 Inbox
drwxr-xr-x@   4 yasutaka  staff     128 Feb  8 20:40 Journal

thinking
**Planning CLAUDE.md review**
codex
リポジトリの最優先ルールは確認できました。追加の運用制約がないか `CLAUDE.md` も確認し、回答形式に反映します。
exec
/bin/zsh -lc "sed -n '1,260p' CLAUDE.md" in /Users/yasutaka/repo/private-note-vault succeeded in 52ms:
---
created: 2025-06-22T22:49
updated: 2026-02-08T21:30
---
# エージェント共通ルール

このファイルは、このリポジトリで作業する際の AI エージェント（Claude Code, Codex 等）へのガイドです。
`AGENTS.md` は本ファイルへのシンボリックリンクです。

## 最優先ルール

作業開始時に必ず `System/Rules/vault-operating-rules.md` を読み、その内容に従ってください。

この vault は **DERJA（デアジャ）方式**で運用します:
- `Domains/` - 継続責務
- `Events/` - 期限付きライフイベント
- `Resources/` - 参照知識
- `Journal/` - 日次/週次ログ
- `Archive/` - 完了・非アクティブ


thinking
**Searching tax-related notes**
exec
/bin/zsh -lc 'rg -n "子育てエコホーム|国庫補助金不算入|住宅ローン控除|住宅借入金等特別控除|認定長期優良住宅|更正の請求" -S' in /Users/yasutaka/repo/private-note-vaultexec
/bin/zsh -lc "rg --files | rg '確定申告|住宅ローン|税|エコホーム|国庫補助|長期優良|住宅借入金等特別控除'" in /Users/yasutaka/repo/private-note-vault succeeded in 152ms:
Events/tax-return-mortgage/2025年確定申告.md
Resources/Literature/年末調整と確定申告って何してるの？.md
Domains/General/2025年年末調整&確定申告メモ.md
 succeeded in 176ms:
Events/tax-return-mortgage/準備物ガイド.md:1:# 住宅ローン控除 確定申告 — 準備物ガイド
Events/tax-return-mortgage/準備物ガイド.md:101:  - 「認定長期優良住宅建築証明書」でも代用可能
Events/tax-return-mortgage/準備物ガイド.md:133:- [国税庁「住宅ローン控除を受ける方へ」](https://www.nta.go.jp/taxes/shiraberu/shinkoku/tokushu/keisubetsu/juutaku.htm)
Events/tax-return-mortgage/準備物ガイド.md:134:- [freee「住宅ローン控除の1年目は確定申告が必要！」](https://www.freee.co.jp/kb/kb-kakuteishinkoku/housing-loan-deduction/)
Events/tax-return-mortgage/README.md:1:	# 住宅ローン控除・初年度確定申告
Events/tax-return-mortgage/README.md:10:住宅ローン控除（住宅借入金等特別控除）の**1年目は、会社員でも確定申告が必須**。
Events/tax-return-mortgage/README.md:34:- 住宅借入金等特別控除額の計算明細書 ← 同上
Events/tax-return-mortgage/README.md:44:- 住宅用家屋証明書（または認定長期優良住宅建築証明書）
Events/tax-return-mortgage/README.md:72:1. 「給与所得がある方」→「住宅借入金等特別控除」を選択
Events/tax-return-mortgage/README.md:92:- 2年目以降は、税務署から「住宅借入金等特別控除申告書」が郵送で届く。勤務先に年末調整で提出するだけでよい。
Events/tax-return-mortgage/README.md:98:- [国税庁「令和7年分 確定申告特集 - 住宅ローン控除」](https://www.nta.go.jp/taxes/shiraberu/shinkoku/tokushu/keisubetsu/juutaku.htm)
Events/tax-return-mortgage/README.md:100:- [freee「住宅ローン控除の1年目は確定申告が必要！」](https://www.freee.co.jp/kb/kb-kakuteishinkoku/housing-loan-deduction/)
Events/tax-return-mortgage/README.md:101:- [Yahoo!くらし「2026年版住宅ローン控除の手続きガイド」](https://kurashi.yahoo.co.jp/procedure/contents/tax-return/mortgage/)
Events/tax-return-mortgage/2025年確定申告.md:17:自分の申告書で**子育てエコホーム支援事業**の補助金を申告していなかった可能性がある。
Events/tax-return-mortgage/2025年確定申告.md:18:→ 住宅ローン控除の入力画面で「補助金等の交付を受けていますか？」という質問があり、見落としたかもしれない。
Events/tax-return-mortgage/2025年確定申告.md:30:| 住宅ローン控除（新築・増改築等、控除期間10年or13年） | 入力あり |
Events/tax-return-mortgage/2025年確定申告.md:35:住宅ローン控除で「認定長期優良住宅」として申請する際の証明書は2種類ある。
Events/tax-return-mortgage/2025年確定申告.md:37:| | 長期優良住宅の認定通知書 | 認定長期優良住宅建築証明書 |
Events/tax-return-mortgage/2025年確定申告.md:45:### 住宅ローン控除の入力で答えた内容（妻の申告時点での確認用）
Events/tax-return-mortgage/2025年確定申告.md:56:| 補助金等の交付を受けているか | 受けていない（子育てエコホーム支援事業は夫名義のため、妻の申告では対象外） |

thinking
**Inspecting existing markdown file**
codex
関連ノートが見つかったため、計算前提の整合性を取るために `Events/tax-return-mortgage/2025年確定申告.md` を確認します。ここに対する修正案として差分提案を出します。
exec
/bin/zsh -lc "sed -n '1,260p' Events/tax-return-mortgage/2025年確定申告.md" in /Users/yasutaka/repo/private-note-vault succeeded in 52ms:

申告書の作成は完了した（作成したのは**所得税**の申告書）
![[Pasted image 20260228230339.png]]

書類の準備
![[Pasted image 20260228230743.png]]

e-taxソフトを使うと電子データで送れるらしい
https://www.keisan.nta.go.jp/r7yokuaru/cat1/cat16/cat163/cid945.html

## あっちゃん（妻）の確定申告

現在、妻の分の確定申告を進めている。

### 要確認：自分の申告に補助金申告漏れの可能性

自分の申告書で**子育てエコホーム支援事業**の補助金を申告していなかった可能性がある。
→ 住宅ローン控除の入力画面で「補助金等の交付を受けていますか？」という質問があり、見落としたかもしれない。

### 所得・控除の入力画面での選択内容（画面番号：SS-AA-070c）

thinking
**Analyzing subsidy impact on mortgage deduction**
exec
/bin/zsh -lc 'rg -n "4300|42,281,768|42281768|100万|ペアローン|持分" Events/tax-return-mortgage -S' in /Users/yasutaka/repo/private-note-vault exited 1 in 52ms:


thinking
**Planning official source search**
codex
ここから税務の一次情報を確認します。国税庁・制度実施機関の公開情報で、借入限度額、補助金不算入、修正手続の3点を照合します。
🌐 Searching the web...
🌐 Searched: 国税庁 令和7年分 住宅借入金等特別控除 認定長期優良住宅 借入限度額 4500万円

thinking
**Refining search with exact domain**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 令和7年分 住宅ローン控除 借入限度額 認定長期優良住宅

thinking
**Identifying source for mortgage deduction details**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp No.1213-1 令和4年以降に居住の用に供した場合 住宅借入金等特別控除

thinking
**Inspecting special individual note**
🌐 Searching the web...
🌐 Searched: https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1.htm

thinking
**Identifying pattern around limits**
🌐 Searching the web...
🌐 Searched: 'いずれか少ない' in https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1.htm

thinking
**Searching borrowing limit text**
🌐 Searching the web...
🌐 Searched: '5000万円' in https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1.htm

thinking
**Identifying explicit borrowing limit source**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 令和7年分 確定申告特集 住宅ローン控除 借入限度額 認定長期優良住宅 4500

thinking
**Opening webpage for data extraction**
codex
借入限度額（4,500万円／5,000万円）の根拠を明確にするため、国税庁の「令和7年分 確定申告特集」ページ内の表や案内資料を確認します。
🌐 Searching the web...
🌐 Searched: https://www.nta.go.jp/taxes/shiraberu/shinkoku/tokushu/keisubetsu/juutaku.htm

thinking
**Verifying housing loan limit and subsidy rules**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 住宅取得 補助金 一時所得 国庫補助金等の総収入金額不算入

thinking
**Checking amendment procedure sources**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 更正の請求 修正申告 所得税 申告書提出後

thinking
**Considering formula sourcing**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp No.1490 一時所得 計算方法 特別控除 50万円

thinking
**Checking mortgage deduction details**
🌐 Searching the web...
🌐 Searched the web

thinking
**Planning alternative data sourcing**
codex
補助金の所得区分（不算入適用前は一時所得）と、特例対象個人の上限額（5,000万円）の根拠も確認しています。次に該当条文・FAQを絞り込みます。
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 認定長期優良住宅 5000万円 特例対象個人

thinking
**Confirming official filing deadlines**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 令和7年分 所得税 申告期限 令和8年3月16日

thinking
**Extracting borrowing limit data**
🌐 Searching the web...
🌐 Searched the web

thinking
**Scoping subsidy source verification**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 子育てエコホーム支援事業 一時所得

thinking
**Clarifying subsidy deduction calculations**
exec
/bin/zsh -lc "awk 'BEGIN{a=42281768*0.007;b=42000000*0.007;printf(\"raw_a=%.3f raw_b=%.3f\\n\",a,b);printf(\"rounded100_a=%d rounded100_b=%d diff=%d\\n\",int(a/100)*100,int(b/100)*100,int(a/100)*100-int(b/100)*100)}'" in /Users/yasutaka/repo/private-note-vault succeeded in 51ms:
raw_a=295972.376 raw_b=294000.000
rounded100_a=295900 rounded100_b=294000 diff=1900

thinking
**Planning incremental tax computation**
exec
/bin/zsh -lc "awk 'BEGIN{x=250000;for(i=1;i<=4;i++){if(i==1){r=0.15;name=\"15%\"}if(i==2){r=0.20;name=\"20%\"}if(i==3){r=0.23;name=\"23%\"}if(i==4){r=0.33;name=\"33%\"}tax=x*r*1.021;printf(\"%s %.0f\\n\",name,tax)}}'" in /Users/yasutaka/repo/private-note-vault succeeded in 52ms:
15% 38288
20% 51050
23% 58707
33% 84232
















thinking
**Searching one-time formula source**
thinking
**Searching for hidden formula lines**
thinking
**Exploring search result text patterns**
thinking
**Identifying source for specific formula details**
thinking
**Searching for specific pattern**
thinking
**Inspecting file start lines**
thinking
**Defining text search pattern**
thinking
**Identifying condition dependencies**
thinking
**Searching specific date string**
thinking
**Searching for deadline pattern**
thinking
**Considering alternative data source**
thinking
**Searching for specific pattern**
thinking
**Focusing on tax decrease source**
thinking
**Identifying source for resubmission deadline**
thinking
**Searching for specific patterns**
thinking
**Identifying due date source**
🌐 Searching the web...
🌐 Searched the web
🌐 Searching the web...
🌐 Searched the web

thinking
**Assessing session reference persistence**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 令和7年分 所得税 確定申告 3月16日

thinking
**Planning borrowing limits sourcing**
🌐 Searching the web...
🌐 Searched the web

thinking
**Planning targeted search**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 住宅借入金等特別控除額の計算明細書【令和7年分用】 PDF


thinking
**Assessing PDF for formula extraction**
thinking
**Searching mortgage section**
🌐 Searching the web...
🌐 Searched: '住宅借入金等特別控除'

thinking
**Resolving reference reliability by using URLs**
🌐 Searching the web...
🌐 Searched: https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1.htm

thinking
**Verifying known URLs manually**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 1211-1qa

thinking
**Identifying key numeric limits**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp 1211-1qa 4,500万円 35万円

thinking
**Evaluating URL validity**
🌐 Searching the web...
🌐 Searched the web

thinking
**Testing query retrieval persistence**
🌐 Searching the web...
🌐 Searched: サイト 住宅借入金等特別控除 4,500万円 5,000万円 子育て世帯 若者夫婦世帯 国税庁 1211-1qa

thinking
**Correcting query structure**
🌐 Searching the web...
🌐 Searched: 住宅借入金等特別控除 4,500万円 5,000万円 子育て世帯 若者夫婦世帯 1211-1qa

thinking
**Testing direct URL access**
🌐 Searching the web...
🌐 Searched the web

thinking
**Planning exact URL search before open**
🌐 Searching the web...
🌐 Searched: www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1qa.htm

thinking
**Exploring official FAQ for housing subsidy**
🌐 Searching the web...
🌐 Searched: site:keisan.nta.go.jp r7yokuaru 住宅借入金等特別控除 補助金等の交付を受けているか

thinking
**Opening website to explore data**
🌐 Searching the web...
🌐 Searched the web

thinking
**Confirming citation strategy**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp e-Tax 法定申告期限内 再送信 最後に送信されたデータが有効

thinking
**Identifying official tax deadline source**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp No.2026 申告を間違えたとき

thinking
**Reviewing related cases**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp No.2024 更正の請求

thinking
**Planning source retrieval for No.2202**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp No.2202 国庫補助金等の総収入金額不算入

thinking
**Confirming subsidy treatment source**
🌐 Searching the web...
🌐 Searched the web

thinking
**Confirming formula source**
🌐 Searching the web...
🌐 Searched: site:nta.go.jp No.1490 一時所得 特別控除額50万円 2分の1

thinking
**Preparing to verify references**
🌐 Searching the web...
🌐 Searched the web

thinking
**Planning official subsidy source search**
🌐 Searching the web...
🌐 Searched: 子育てエコホーム支援事業 国土交通省 補助金 事業概要

thinking
**Assessing subsidy documentation sources**
🌐 Searching the web...
🌐 Searched: site:keisan.nta.go.jp r7yokuaru 該当する補助金等を確認する 住宅借入金等特別控除

thinking
**Searching official borrowing limits**
🌐 Searching the web...
🌐 Searched: site:keisan.nta.go.jp 認定長期優良住宅 4,500万円 5,000万円 令和7

thinking
**Planning tax document patch**
codex
一次情報の根拠は揃いました。これから、既存ノートに反映する想定で「どこをどう直すか」を差分案に落とし込み、手続き分岐（期限内再申告／期限後の修正申告・更正請求）まで整理します。
exec
/bin/zsh -lc "nl -ba Events/tax-return-mortgage/2025年確定申告.md | sed -n '1,260p'" in /Users/yasutaka/repo/private-note-vault succeeded in 52ms:
     1	
     2	申告書の作成は完了した（作成したのは**所得税**の申告書）
     3	![[Pasted image 20260228230339.png]]
     4	
     5	書類の準備
     6	![[Pasted image 20260228230743.png]]
     7	
     8	e-taxソフトを使うと電子データで送れるらしい
     9	https://www.keisan.nta.go.jp/r7yokuaru/cat1/cat16/cat163/cid945.html
    10	
    11	## あっちゃん（妻）の確定申告
    12	
    13	現在、妻の分の確定申告を進めている。
    14	
    15	### 要確認：自分の申告に補助金申告漏れの可能性
    16	
    17	自分の申告書で**子育てエコホーム支援事業**の補助金を申告していなかった可能性がある。
    18	→ 住宅ローン控除の入力画面で「補助金等の交付を受けていますか？」という質問があり、見落としたかもしれない。
    19	
    20	### 所得・控除の入力画面での選択内容（画面番号：SS-AA-070c）

thinking
**Summarizing detailed tax review and edits proposal**
codex
## 1. Diagnosis
- 結論は概ね正しいです。`国庫補助金等の総収入金額不算入`を使えるなら、有利になる可能性は高いです。  
- ただし前提に1点ズレがあります。住宅ローン控除では、補助金は「不算入を使うかどうかに関係なく」取得対価から控除して計算する扱いです。  
- 控除減の試算は `約1,972円` ではなく、100円未満切捨てを入れると `1,900円` です。  
  - 補助金控除なし: `42,281,768 × 0.7% = 295,972.376 → 295,900円`
  - 補助金控除あり: `42,000,000 × 0.7% = 294,000円`
  - 差額: `1,900円`
- 「借入限度額4,500万円」は通常枠として妥当ですが、`特例対象個人`なら年控除上限35万円（= 借入限度額5,000万円相当）です。  
  - ここは「19歳未満扶養親族の有無」「夫婦年齢要件」で再確認が必要です。
- 手続き面は、**2026-03-16（月）まで**なら更正の請求ではなく、e-Taxの再送信（最後の提出データが有効）が最短です。期限後は「税額増なら修正申告、税額減なら更正の請求」です。

根拠:
- https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1.htm  
- https://www.nta.go.jp/taxes/shiraberu/shinkoku/qa/kokuzei/04.htm  
- https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/2202.htm  
- https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1490.htm  
- https://www.nta.go.jp/taxes/shiraberu/shinkoku/tokushu/index.htm  

## 2. Plan
1. まず申告控えを確認し、夫の申告で「補助金入力」「一時所得入力」「不算入適用」の3点が実際どうなっているかを確定する。  
2. 次に、`ローン額`ではなく`売買契約書ベースの持分対応取得対価`で再計算する（補助金1,000,000円控除、100円未満切捨て）。  
3. 2026-03-16（月）までならe-Taxで再送信する。  
4. 2026-03-17以降なら、再計算結果の「最終税額の増減」で `修正申告` か `更正の請求` を選ぶ。  
5. 補助金の入金日が2025年か2026年かを確認し、一時所得（または不算入）を適用する年分を合わせる。  

## 3. Concrete edits
対象ファイル未指定なので、既存ノートへの追記案です。  
提案先: [Events/tax-return-mortgage/2025年確定申告.md](/Users/yasutaka/repo/private-note-vault/Events/tax-return-mortgage/2025年確定申告.md)

```diff
@@
 提出書類メモ
 ![[Pasted image 20260308121145.png]]
+
+## 国庫補助金不算入の計算レビュー（2026-03-08）
+
+- 夫の子育てエコホーム補助金100万円は、住宅ローン控除計算上、取得対価から控除して計算する。
+- 住宅ローン控除額の差は約1,900円（100円未満切捨て後）。
+  - 補助金控除なし: 42,281,768円 × 0.7% = 295,972.376円 → 295,900円
+  - 補助金控除あり: 42,000,000円 × 0.7% = 294,000円
+  - 差額: 1,900円
+- 借入限度額は通常4,500万円。特例対象個人なら年控除上限35万円（借入限度額5,000万円相当）。
+- 2026-03-16（月）までならe-Tax再送信で訂正可能（最後に送信した申告データが有効）。
+- 期限後は、税額が増えるなら修正申告、減るなら更正の請求。
+- 補助金入金日（2025年か2026年か）で一時所得・不算入の対象年分が変わるため、入金日を要確認。
```

## 4. Risks & checks
- 補助金の受領年誤認リスク: 受領が2026年なら令和8年分側の論点になります。  
- 取得対価の誤認リスク: `借入額=取得対価` と決め打ちするとズレます。売買契約書・持分按分で確認してください。  
- 手続選択ミス: 期限内は再送信、期限後は増減で `修正申告/更正の請求` を分岐。  
- 限度額の見落とし: 特例対象個人なら実質5,000万円枠です（年35万円上限からの推定）。  
- 住民税影響の見落とし: 一時所得を計上する場合は翌年度住民税にも影響します。  
- 最終検証項目: e-Tax受信通知の最終版、補助金交付決定通知・入金記録、住宅ローン年末残高証明書、売買契約書（持分）。
tokens used
186,015
## 1. Diagnosis
- 結論は概ね正しいです。`国庫補助金等の総収入金額不算入`を使えるなら、有利になる可能性は高いです。  
- ただし前提に1点ズレがあります。住宅ローン控除では、補助金は「不算入を使うかどうかに関係なく」取得対価から控除して計算する扱いです。  
- 控除減の試算は `約1,972円` ではなく、100円未満切捨てを入れると `1,900円` です。  
  - 補助金控除なし: `42,281,768 × 0.7% = 295,972.376 → 295,900円`
  - 補助金控除あり: `42,000,000 × 0.7% = 294,000円`
  - 差額: `1,900円`
- 「借入限度額4,500万円」は通常枠として妥当ですが、`特例対象個人`なら年控除上限35万円（= 借入限度額5,000万円相当）です。  
  - ここは「19歳未満扶養親族の有無」「夫婦年齢要件」で再確認が必要です。
- 手続き面は、**2026-03-16（月）まで**なら更正の請求ではなく、e-Taxの再送信（最後の提出データが有効）が最短です。期限後は「税額増なら修正申告、税額減なら更正の請求」です。

根拠:
- https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1211-1.htm  
- https://www.nta.go.jp/taxes/shiraberu/shinkoku/qa/kokuzei/04.htm  
- https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/2202.htm  
- https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1490.htm  
- https://www.nta.go.jp/taxes/shiraberu/shinkoku/tokushu/index.htm  

## 2. Plan
1. まず申告控えを確認し、夫の申告で「補助金入力」「一時所得入力」「不算入適用」の3点が実際どうなっているかを確定する。  
2. 次に、`ローン額`ではなく`売買契約書ベースの持分対応取得対価`で再計算する（補助金1,000,000円控除、100円未満切捨て）。  
3. 2026-03-16（月）までならe-Taxで再送信する。  
4. 2026-03-17以降なら、再計算結果の「最終税額の増減」で `修正申告` か `更正の請求` を選ぶ。  
5. 補助金の入金日が2025年か2026年かを確認し、一時所得（または不算入）を適用する年分を合わせる。  

## 3. Concrete edits
対象ファイル未指定なので、既存ノートへの追記案です。  
提案先: [Events/tax-return-mortgage/2025年確定申告.md](/Users/yasutaka/repo/private-note-vault/Events/tax-return-mortgage/2025年確定申告.md)

```diff
@@
 提出書類メモ
 ![[Pasted image 20260308121145.png]]
+
+## 国庫補助金不算入の計算レビュー（2026-03-08）
+
+- 夫の子育てエコホーム補助金100万円は、住宅ローン控除計算上、取得対価から控除して計算する。
+- 住宅ローン控除額の差は約1,900円（100円未満切捨て後）。
+  - 補助金控除なし: 42,281,768円 × 0.7% = 295,972.376円 → 295,900円
+  - 補助金控除あり: 42,000,000円 × 0.7% = 294,000円
+  - 差額: 1,900円
+- 借入限度額は通常4,500万円。特例対象個人なら年控除上限35万円（借入限度額5,000万円相当）。
+- 2026-03-16（月）までならe-Tax再送信で訂正可能（最後に送信した申告データが有効）。
+- 期限後は、税額が増えるなら修正申告、減るなら更正の請求。
+- 補助金入金日（2025年か2026年か）で一時所得・不算入の対象年分が変わるため、入金日を要確認。
```

## 4. Risks & checks
- 補助金の受領年誤認リスク: 受領が2026年なら令和8年分側の論点になります。  
- 取得対価の誤認リスク: `借入額=取得対価` と決め打ちするとズレます。売買契約書・持分按分で確認してください。  
- 手続選択ミス: 期限内は再送信、期限後は増減で `修正申告/更正の請求` を分岐。  
- 限度額の見落とし: 特例対象個人なら実質5,000万円枠です（年35万円上限からの推定）。  
- 住民税影響の見落とし: 一時所得を計上する場合は翌年度住民税にも影響します。  
- 最終検証項目: e-Tax受信通知の最終版、補助金交付決定通知・入金記録、住宅ローン年末残高証明書、売買契約書（持分）。
