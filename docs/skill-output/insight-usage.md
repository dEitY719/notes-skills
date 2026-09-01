# insight 사용 결과

> **한 줄 요약** — 대화에서 재사용 가능한 패턴 하나를 뽑아 `docs/guide/learnings/` 노트와 색인 항목을 생성합니다.

```
현재 대화 + repo 룰북  ──▶  /notes:insight  ──▶  learnings 노트 (.md) + README 색인
```

## 1. 실행한 명령

```
범용:  /notes:insight [<topic-hint>]
이번:  /notes:insight "GitHub Pages URL owner 소문자 정규화"
```

이 repo 에는 `docs/guide/learnings/` 가 없어 스킬이 Step 1 에서 설계대로 멈춥니다.
그래서 `~/dotfiles/docs/guide/learnings/` 룰북과 기존 노트 8건을 그대로 복제한
샌드박스 repo 를 대상으로 실행했습니다.

## 2. 입력

이 세션에서 Pages 링크를 만들다 발견한 사실. 스킬이 Step 3~4 에서 실제로 찾아낸
근거는 다음과 같습니다.

| 단계 | 결과 |
|------|------|
| Step 3 중복 검사 | 기존 노트 8건 중 겹침 0건 |
| Step 4 출처 | `op-rules.md:40`, `plan-and-report-templates.md:170` — Pages 공식에 소문자 정규화 단계가 없음 |
| Step 4 대조 증거 | `visuals-skills/README.md` — Pages 링크(22-23행)는 `deity719`, 설치 명령(34·41·47·53·63행)은 `dEitY719` |
| 실측 한계 | 대상 Pages 미배포 — `curl` 이 두 표기 모두 404. 노트의 "주의점" 절에 명시 |

## 3. 결과

71줄 노트 한 개(권장 50~80줄 이내)와 룰북 README 색인 9번 항목이 생성되었습니다.
노트의 `## Code` 스니펫은 SSH/HTTPS 두 remote 형식으로 실행해 `dEitY719` →
`deity719` 변환을 확인했습니다.

생성된 산출물:
[`examples/insight-github-pages-owner-lowercase.md`](./examples/insight-github-pages-owner-lowercase.md)

```
[OK] file=docs/guide/learnings/github-pages-owner-lowercase.md lines=71
     summary="git remote 의 owner 를 Pages URL 에 그대로 넣지 말고 호스트 슬롯만 소문자로 정규화"
```

> Step 7 의 `memory/` 포인터는 설계대로 자동 생성하지 않고 제안만 했습니다.
