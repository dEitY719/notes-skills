# insight — 대화에서 재사용 가능한 패턴 하나를 노트로

> **한 줄 요약** — 지금 나눈 대화에서 재사용 가능한 패턴 한 개를 뽑아, 현재 repo 의 `docs/guide/learnings/` 에 50~80줄짜리 한국어 노트 한 개로 남기고 그 디렉터리의 색인까지 갱신합니다.

## 무엇을 만들어 내는가

`<repo-root>/docs/guide/learnings/<slug>.md` 파일 하나와, 같은 디렉터리
`README.md` 의 "현재 문서 목록" 항목 한 줄. 5개 섹션, 50~80줄, 본문은 한국어이고
제목은 영어입니다.

파일명은 **행동이 아니라 패턴** 을 가리킵니다. `fix-worktree-bug.md` 가 아니라
패턴 자체의 이름을 씁니다.

## 언제 쓰는가

대화 중에 "이건 다음에도 또 쓰겠다" 싶은 일반화 가능한 교훈이 나왔을 때. 한 번의
호출은 인사이트 **한 개** 만 처리합니다.

## 언제 쓰지 않는가 — 형제 스킬과의 경계

| 목적 | 쓸 스킬 |
|------|---------|
| 재사용 패턴 한 개 | **`insight`** (이 스킬) |
| 서사형 삽질 블로그 | `notes:blog-dev-learnings` |
| 형식을 갖춘 포스트모템 | `notes:rca` |
| 오늘 한 작업의 일지 | `notes:task-history` |

`docs/guide/learnings/` 가 아니라 `docs/guide/technic/`, `docs/.ssot/`,
`docs/feature/<name>/`, `<plugin>-skills/skills/`, `memory/` 에 속하는 주제라면 스킬이
스스로 거절합니다. 판정 기준은 `references/routing.md` 에 있습니다.

## 호출 형식

```
/notes:insight [<topic-hint>]
/notes:insight -h | --help | help
```

| 인자 | 설명 | 기본값 |
|------|------|--------|
| `<topic-hint>` | 후보를 한정할 자유 텍스트 (예: `git-crypt worktree`) | 없음 — 후보 1~3개를 제안하고 사용자가 고름 |
| `-h` / `--help` / `help` | `references/help.md` 출력 후 종료 | — |

## 동작 단계

1. **Resolve repo + read the rulebook** — `git rev-parse --show-toplevel`, `docs/guide/learnings/README.md` 읽기, 기존 노트 목록화. 디렉터리가 없으면 여기서 중단.
2. **Identify the candidate** — 힌트가 있으면 거기에 고정, 없으면 최근 대화에서 후보 1~3개 제안. `references/routing.md` 로 이 디렉터리 소관인지 확인.
3. **Check for overlap** — `grep -li` 로 기존 노트와 겹치는지 확인. 진짜 겹치면 새 파일 대신 기존 파일 갱신을 권합니다.
4. **Mine the conversation** — PR 번호, 커밋 SHA, 이슈 번호, 리뷰 스레드 URL, 재현 절차, `file:line` 을 대화에서 추출.
5. **Draft** — `references/template.md` 의 섹션 구조와 길이 정책을 따름.
6. **Write + update index** — 파일 작성 후 README 색인에 3줄 형식으로 추가.
7. **Suggest a memory pointer** — 세션을 넘어 재사용될 만하면 물어봅니다. 자동 생성하지 않습니다.
8. **Report** — 두 줄만 출력 (verdict + `Next:`).

## 주의사항과 제약

- **디렉터리 README 가 SSOT 입니다.** 템플릿·길이·언어 규칙은 매 실행마다 다시 읽습니다. 규칙이 충돌하면 README 가 이깁니다. 요약해서 기억해 두지 않습니다.
- **출처 없는 교훈은 거절합니다.** PR / 커밋 / `file:line` 링크가 하나도 안 나오면 Step 4 로 되돌아가거나 작성을 거절합니다.
- **한 번에 한 파일.** 인사이트가 여러 개면 하나를 고르고 나머지는 다음 실행으로 안내합니다.
- **`memory/` 에 자동으로 쓰지 않습니다.** 제안하고 확인을 기다립니다 — `MEMORY.md` 는 매 세션 로드되므로 늘리는 비용이 큽니다.
- **조용히 덮어쓰지 않습니다.** 슬러그가 이미 있으면 diff 를 보여주고 갱신할지 새 슬러그를 쓸지 묻습니다.
- 150줄을 넘어가면 `docs/guide/learnings/` 가 아니라 `docs/guide/technic/` 감입니다.
