# task-history 사용 결과

> **한 줄 요약** — 이번 세션의 작업을 받아 일자별 로그에 JIRA 티켓 + PR 설명 항목을 덧붙입니다.

```
현재 대화 + git 상태  ──▶  /notes:task-history  ──▶  일자별 로그 (.md) 항목 append
```

## 1. 실행한 명령

```
범용:  /notes:task-history ["<description>"]
이번:  TASK_HISTORY_DIR=<sandbox> \
       /notes:task-history "notes-skills 문서화 — structure-check 감사 후 문서 트리 신설"
```

기본 출력 경로(`~/para/archive/playbook/docs/task-history/`)에는 실제 로그 4건이
이미 쌓여 있어, 데모 항목을 섞지 않으려고 `TASK_HISTORY_DIR` 로 출력만 돌렸습니다.

## 2. 입력

이번 세션의 대화와 repo 의 git 상태. 스킬이 Step 3 에서 수집한 실제 값:

| 항목 | 값 |
|------|-----|
| project | `notes-skills` (`git remote` 에서 추출) |
| branch | `wt/feat/1` |
| 이번 세션 커밋 | 0건 |
| working tree | `?? docs/` (미추적) |
| 파일 모드 | CREATE (오늘자 파일 없음) |

## 3. 결과

38줄 항목 하나가 생성되었습니다. **PR 섹션은 실제로 생략되었습니다** — Step 5 는
"대화에 커밋이 존재할 때만" PR 블록을 만드는데 이번 세션은 커밋을 만들지 않았고,
스킬이 그 분기를 그대로 탔습니다.

생성된 산출물:
[`examples/task-history-2026-09-01-task-list.md`](./examples/task-history-2026-09-01-task-list.md)

```
[OK] notes:task-history — entry appended
  time: 16:38  project: notes-skills  pr_section: skipped
```

> Step 7 의 자동 커밋은 이번 실행에서 의도적으로 생략했습니다 (문서화 작업 중 커밋 금지).
