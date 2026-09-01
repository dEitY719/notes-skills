# rca 사용 결과

> **한 줄 요약** — 사건 하나를 받아 9개 섹션 고정 템플릿의 Jekyll 호환 RCA 문서를 생성합니다.

```
사건 기록 + 1차 자료  ──▶  /notes:rca  ──▶  9섹션 RCA 문서 (.md)
```

## 1. 실행한 명령

```
범용:  /notes:rca [--commit] [--audience <blog|private|internal>]
이번:  RCA_REPO_PATH=<sandbox> /notes:rca --audience internal
```

기본 경로 `~/para/archive/rca-knowledge` 가 이 머신에 없어 `RCA_REPO_PATH` 로
출력 위치를 지정했습니다 — 이 변수가 모든 출력 경로의 SSOT 입니다.

## 2. 입력

`claude-plugin-jira` 에서 연달아 발생한 플러그인 설치·로드 실패 3건. 1차 자료는
`packaging:structure-check` 의 `references/structure-spec.md` 에 기록된 사고
내용입니다 — 실제 이슈 번호(#61, #63, #65), 관측 버전(2.1.198), 원문 오류
메시지를 그대로 인용했습니다.

## 3. 결과

Step 3 검증을 모두 통과한 240줄 문서 한 개가 생성되었습니다.

| 검증 항목 | 결과 |
|-----------|------|
| 섹션 | 9/9, 순서 준수 |
| 본문 단어 수 | 1331 |
| 이모지 | 0건 |
| frontmatter 파싱 | 성공 (16개 키) |
| `--audience internal` 적용 | `target_audiences` 에서 `blog` 제거, `blog_ready: false` |

생성된 산출물:
[`examples/rca-2026-09-01-plugin-manifest-install-load-failures.md`](./examples/rca-2026-09-01-plugin-manifest-install-load-failures.md)

```
[OK] notes:rca — plugin-manifest-install-load-failures.md written
  words: 1331  sections: 9/9  audience: internal
```

> Step 5 는 `--commit` 을 주지 않아 설계대로 건너뛰었습니다.
