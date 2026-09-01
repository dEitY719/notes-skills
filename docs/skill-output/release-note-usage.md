# release-note 사용 결과

> **한 줄 요약** — git 커밋 범위를 받아 사용자 관점 테마로 묶인 릴리즈 노트 마크다운을 생성합니다.

```
git 커밋 범위  ──▶  /notes:release-note  ──▶  릴리즈 노트 (.md)
```

## 1. 실행한 명령

```
범용:  /notes:release-note [<anchor-ref>] [<head-ref>]
이번:  /notes:release-note ea4bfc49 HEAD        (대상 repo: ~/dotfiles)
```

## 2. 입력

`~/dotfiles` 의 커밋 범위 `ea4bfc49..HEAD`. 앵커는 "#1410 Phase 0 — packaging-skills
마켓플레이스 repo 등록" 커밋이고, 여기부터 HEAD 까지가 스킬 마켓플레이스 분리
작업 전체입니다.

스킬이 수집·분류한 실제 수치:

| 총 커밋 | feat | fix | refactor | chore | test | 비관례 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 23 | 6 | 10 | 5 | 1 | 1 | 0 |

기존 릴리즈 노트 관례는 없었습니다 (`docs/release-notes/`, `CHANGELOG*` 모두 부재)
— 기본 템플릿으로 진행.

## 3. 결과

23개 커밋이 1:1 나열 대신 **3개 사용자 관점 테마**로 묶였습니다: 스킬 마켓플레이스
분리, 플러그인 동기화 끄기, 대량 배치 스캔 안정화. 기능과 무관한 수정은 "버그
수정", `/simplify` 정리는 "리팩토링" 섹션으로 분리되었습니다.

생성된 산출물 (68줄):
[`examples/release-note-2026-09-01-1410-phase0-2.md`](./examples/release-note-2026-09-01-1410-phase0-2.md)

```
[OK] notes:release-note — #1410 Phase 0-2 notes written
  themes: 3  commits_grouped: 23  non_conventional_checked: yes
```

> Step 5 의 `git commit` 은 이번 실행에서 의도적으로 생략했습니다 (문서화 작업 중 커밋 금지).
