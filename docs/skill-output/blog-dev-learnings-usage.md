# blog-dev-learnings 사용 결과

> **한 줄 요약** — 디버깅 삽질기를 받아 7개 섹션 서사 구조의 한국어 개발 블로그 글을 생성합니다.

```
삽질 기록 (커밋/이슈)  ──▶  /notes:blog-dev-learnings  ──▶  블로그 글 (.md)
```

## 1. 실행한 명령

```
범용:  /notes:blog-dev-learnings ["<topic-hint>"]
이번:  /notes:blog-dev-learnings "gcp-scan 대량 배치 0건 적용 삽질"
```

## 2. 입력

`~/dotfiles` 커밋 `91237664` 와 그 이슈 `#1647`. 대량 배치에서 후보 수백 건을
스캔하고도 커밋 0건만 적용된 채 충돌 worktree 를 남기고 끝나던 버그입니다.
글에 인용된 수치는 모두 실제 값입니다.

| 항목 | 값 |
|------|-----|
| 결함 수 | 2건 (선례 판정이 pick 순서 무시 / 충돌 1건에 배치 전체 포기) |
| 변경 규모 | 3 files, 335 insertions, 24 deletions |
| 테스트 | `gcp.bats` 92/92 통과 (신규 4건 포함) |
| 신규 플래그 | `--stop-on-conflict` (레거시 all-or-nothing 을 opt-in 으로) |

Step 1 에서 제목 후보 3개를 제안하고 그중 고통과 불신을 한 줄에 담은 안을
채택했습니다 — 반전인 "결함 두 개"는 4절 Root Cause 로 내렸습니다.

## 3. 결과

188줄 글 한 개 (권장 150~300줄). 서사 구조 고통 → 삽질 → 깨달음 → 해결을 따라
7개 섹션이 생성되었습니다: 제목/부제, TL;DR, 문제 상황, 진짜 원인, 해결, 교훈, 결론.

산출물 경로 (샌드박스):
`dev-learnings/gcp-scan-batch-zero-applied-blog.md`

```
[OK] notes:blog-dev-learnings — gcp-scan-batch-zero-applied-blog.md
  lines: 188  title: "후보 수백 건 스캔했는데 커밋 0건 적용됐습니다" (+이모지 1개)
```

> 이 스킬만 설계상 이모지를 사용합니다. 그래서 산출물을 이 repo 안에 복사하지
> 않았습니다 — CI 이모지 게이트가 `skills/blog-dev-learnings/references/` 밖의
> 이모지를 거부하기 때문입니다. 나머지 네 스킬의 산출물은 `examples/` 에 있습니다.
