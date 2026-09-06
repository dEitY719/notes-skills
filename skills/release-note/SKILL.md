---
name: release-note
description: >-
  두 릴리즈 사이 git 히스토리를 사용자 관점 테마로 묶은 한국어 릴리즈 노트 작성. Use for
  `/notes:release-note`, "릴리즈 노트 만들어줘". Do NOT use for 대화 기반 기록 — 작업 로그는
  notes:task-history, 장애 분석은 notes:rca.
allowed-tools: Read, Bash, Grep, Glob, Write, Edit
license: MIT
metadata:
  model_recommendation:
    tier: sonnet
    reason: "release note generation: commit categorization, user-perspective theme grouping, project convention detection"
    claude: prefer
    non_claude: advisory-only
---

# Release Notes 작성

## Help

If args is `-h`/`--help`/`help`, read `references/help.md` verbatim and stop.

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `<anchor-ref>` | 이전 릴리즈 경계 (태그 / 커밋 / 브랜치). 주면 1단계 자동 탐지를 건너뛴다. | 자동 탐지 |
| `<head-ref>` | 커밋 범위의 상한. | `HEAD` |
| `-h` / `--help` / `help` | `references/help.md` 를 그대로 출력하고 종료. | — |

## 핵심 원칙

커밋은 *무엇이* 바뀌었는지 말해주고, 릴리즈 노트는 그것이 *사용자에게 어떤 의미인지* 말해준다.

## 워크플로

> 단계 1–5 는 순차 — anchor 를 찾을 수 없거나 저장 경로 쓰기 실패 시 즉시 보고하고 다음 단계로 진행하지 않는다.

### 1. 앵커 커밋 찾기

`<anchor-ref>` 인자가 있으면 그것을 앵커로 쓰고 이 단계를 건너뛴다. 없으면 이전
릴리즈의 경계 커밋을 찾는다. 우선순위:

1. **git 태그** (있으면 가장 신뢰할 수 있음)
2. **이전 릴리즈 노트 문서의 커밋** (태그가 없는 프로젝트의 관례)
3. **사용자에게 시작점 확인**

구체적인 git 명령어는 `references/git-commands.md` 참고.

### 2. 커밋 수집 및 분류

`bash "${CLAUDE_PLUGIN_ROOT}/lib/collect-commits.sh" <anchor> [<head-ref>]` 로
범위의 커밋을 한 번에 수집·분류한다. **`CLAUDE_PLUGIN_ROOT` 는 Claude Code 전용 —
그 외 하네스는 반드시 `references/git-commands.md` 의 대체 경로를 쓸 것.** 출력은
커밋당 한 줄 `<type><TAB><sha><TAB><subject>` (type 은 conventional prefix 또는
`other`) + 요약 줄 `total=<n> other=<n> first_date=<d> last_date=<d>`.

[WARN] `other` 로 분류된 커밋(비관례)을 반드시 확인 — 놓치기 쉬움.

앵커를 직접 찾아야 하는 경우의 git 명령은 `references/git-commands.md` 참고.

### 3. 테마로 그룹핑 (가장 중요)

**커밋을 1:1로 나열하지 말 것.** 관련 커밋을 **사용자 관점 테마**로 묶는다.

- 같은 컴포넌트의 여러 `feat:` → 하나의 테마 섹션
- `feat:` + 관련 `fix:` + `refactor:` → 기능 개발 전체를 묶는 섹션
- 독립 `fix:` → "버그 수정" 섹션
- 독립 `refactor:` → "리팩토링" 섹션

그룹핑 휴리스틱, **테마 네이밍 규칙**, 흔한 실수 체크리스트는
`references/grouping-heuristics.md` 참고.

### 4. 릴리즈 노트 작성

프로젝트의 기존 관례를 먼저 확인한다 —
`ls docs/release-notes/ 2>/dev/null || ls CHANGELOG* 2>/dev/null`. 기존 릴리즈 노트가
있으면 그 포맷이 최우선, 없으면 `references/template.md`의 기본 템플릿을 사용.

### 5. 저장 및 커밋

```bash
git add "<release-notes-path>"
git commit -m "docs: add <version> release notes"
```

저장/커밋 후 결과를 한 줄 verdict 로 보고:

```
[OK] notes:release-note — <version> notes written
  path: <release-notes-path>
  themes: <n>  commits_grouped: <n>  non_conventional_checked: yes

Next: review <release-notes-path>, then git push origin <branch>
```

## Related skills

작업 로그는 [[notes:task-history]], 재사용 패턴 문서화는 [[notes:insight]], 장애 분석은 [[notes:rca]], 서사형 삽질 블로그는 [[notes:blog-dev-learnings]].
