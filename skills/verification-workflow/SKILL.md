---
name: verification-workflow
description: PR前の検証（build/type/lint/test/差分確認）を体系的に実行する。
---

# 検証 Skill

## 目的

PR前に必要な品質ゲートをまとめて確認する。

## 検証順序

1. Build
2. Type Check
3. Lint
4. Test（可能ならカバレッジ）
5. 不要ログ・不要差分の確認

## レポート形式

```text
VERIFICATION: PASS/FAIL
Build: OK/FAIL
Types: OK/X errors
Lint: OK/X issues
Tests: X/Y passed, Z%
Ready for PR: YES/NO
```

## 運用ルール

- FAIL項目がある場合は、原因と次アクションを明記する
- 検証不能な項目がある場合は、未実施理由を明記する
