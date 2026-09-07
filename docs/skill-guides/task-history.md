# task-history — 이번 세션의 작업을 일자별 로그에 기록

> **한 줄 요약** — 이번 대화에서 끝낸 작업을 일자별 로그 파일에 덧붙이고, 그대로 복사해 붙일 수 있는 JIRA 티켓 본문과 PR 설명 두 가지 형식을 함께 산출합니다.

## 무엇을 만들어 내는가

`${TASK_HISTORY_DIR:-~/para/archive/playbook/docs/task-history/}/YYYY-MM-DD-task-list.md`
에 항목 하나를 **덧붙입니다**(append). 항목은 두 블록으로 구성됩니다.

- **JIRA 티켓** — 섹션 기호를 쓴 평문. JIRA Description 에 그대로 붙입니다.
- **PR 설명** — 마크다운. 이번 대화에 커밋이 없으면 이 블록은 통째로 생략됩니다.

출력 디렉터리는 **전역** 입니다. 현재 repo 가 어디든 같은 곳에 쌓입니다.

## 언제 쓰는가

세션을 마무리하면서 오늘 한 일을 기록으로 남길 때. 티켓을 채우거나 PR 을 열기
직전에 본문을 뽑아낼 때.

## 언제 쓰지 않는가 — 형제 스킬과의 경계

| 목적 | 쓸 스킬 |
|------|---------|
| 오늘 한 작업의 일지 | **`task-history`** (이 스킬) |
| 재사용 가능한 패턴 | `notes:insight` |
| 형식을 갖춘 포스트모템 | `notes:rca` |
| 세션 1건을 PARA vault Inbox 노트로 | `pkm:obsidian-session-clip` |

`pkm:obsidian-session-clip` 과 특히 헷갈립니다. 이 스킬은 **일자별 daily log 에
append** 하고, 저쪽은 vault Inbox 에 노트를 **한 개 새로 만듭니다**.

## 호출 형식

```
/notes:task-history ["<description>"]
/notes:task-history -h | --help | help
```

| 인자 | 설명 | 기본값 |
|------|------|--------|
| `<description>` | 추가 맥락을 주는 자유 텍스트 | 없음 — 대화에서 추출 |
| `-h` / `--help` / `help` | `references/help.md` 출력 후 종료 | — |

환경변수: `TASK_HISTORY_DIR` (기본값 `~/para/archive/playbook/docs/task-history/`)

## 동작 단계

단계 1~8 은 순차입니다. Step 1 이 쓰기 가능한 디렉터리를 못 찾거나 Step 7 커밋이
실패하면, 반쪽짜리 항목을 남기지 않고 멈춰서 보고합니다.

1. **출력 경로 결정** — 디렉터리 + `YYYY-MM-DD-task-list.md`. 없으면 `mkdir -p`.
2. **대화 분석** — 무엇을 했는지(구체적 행동/변경), 왜 했는지(배경, 계기), 무엇이 나왔는지(결과, 파일, PR, 이슈)를 추출. description 인자는 보조 맥락일 뿐, 대화 분석은 그대로 수행합니다.
3. **git 정보 수집** — `lib/gather-git-context.sh` 한 번으로 프로젝트명, 브랜치, 기본 브랜치(하드코딩된 `main` 이 아니라 `origin/HEAD` 에서 탐지), 커밋 수, diffstat, 최근 커밋 목록을 받습니다. git repo 밖에서도 exit 0 (`project=N/A`). 필드와 대체 경로는 `references/git-context.md`. 오늘 커밋 전부가 아니라 **이번 세션의** 커밋을 대화로 식별합니다.
4. **JIRA 형식 생성** — `references/jira-template.md`.
5. **PR 형식 생성 (조건부)** — `references/pr-template.md`. 대화에 커밋이 없으면 생략.
6. **파일에 쓰기** — append/create 와 구분선 정책은 `references/file-entry-structure.md`.
7. **자동 커밋** — `references/commit-confirm.md` 의 커밋 패턴.
8. **확인** — 최종 verdict 블록 출력.

## 주의사항과 제약

- **Step 7 에서 자동 커밋합니다.** 다른 스킬과 달리 플래그 없이도 커밋이 일어납니다 (`chore(task-history): YYYY-MM-DD <summary>`). push 는 하지 않습니다.
- **Append 전용** 입니다. 기존 항목을 덮어쓰지 않습니다 — 하루에 여러 번 돌리면 같은 파일에 계속 쌓입니다.
- **출력 경로가 repo 상대가 아닙니다.** 어느 프로젝트에서 실행하든 같은 전역 디렉터리로 갑니다.
- 이모지를 쓰지 않습니다. 출력 관례는 `references/file-entry-structure.md` 참고.
- 완성된 예시 항목은 `references/example.md` 에 있습니다.
