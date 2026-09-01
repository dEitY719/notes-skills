# rca — Root Cause Analysis 보고서 작성

> **한 줄 요약** — 장애·버그·반복 실수 하나를 9개 섹션 고정 템플릿의 Jekyll 호환 마크다운 문서 한 개(`YYYY-MM-DD-<slug>.md`)로 산출합니다.

## 무엇을 만들어 내는가

`${RCA_REPO_PATH:-~/para/archive/rca-knowledge}/docs/analysis/YYYY-MM-DD-<slug>.md`
파일 하나. YAML frontmatter + 9개 섹션으로 구성되며, 근본 원인 분석, 재발 방지
체크리스트, 학습 자료를 담습니다.

한 문서가 네 종류의 독자를 동시에 만족시키도록 설계되어 있습니다: 포스트모템
리뷰, 기술 블로그, AI 도구 학습, 주니어 엔지니어 온보딩.

## 언제 쓰는가

- 프로덕션 장애와 포스트모템
- 근본 원인이 자명하지 않은 버그 수정
- 보존할 가치가 있는 기술적 삽질
- 여러 모듈에 걸친 패턴 수준의 실패
- 코드 리뷰에서 발견한 안티패턴

## 언제 쓰지 않는가 — 형제 스킬과의 경계

같은 사건이라도 어떤 문체로 남기느냐에 따라 스킬이 갈립니다.

| 목적 | 쓸 스킬 |
|------|---------|
| 형식을 갖춘 포스트모템 | **`rca`** (이 스킬) |
| 서사형 삽질 블로그 | `notes:blog-dev-learnings` |
| 재사용 가능한 패턴 한 개 | `notes:insight` |
| 오늘 한 작업의 일지 | `notes:task-history` |

셋 중 하나를 고르는 것이지, 같은 사건에 세 개를 다 돌리는 것이 아닙니다.

## 호출 형식

```
/notes:rca [--commit] [--audience <blog|private|internal>] [--private]
/notes:rca -h | --help | help
```

| 인자 | 설명 |
|------|------|
| `--commit` | Step 5 에서 `$RCA_REPO_PATH` 에 `git add` + `commit`. push 는 하지 않습니다. |
| `--audience <target>` | Step 4 의 편집 정책을 선택 (`blog` / `private` / `internal`). 기본값은 네 독자 모두 대응. |
| `--private` | 민감 정보 편집(redaction) 정책 적용. |
| `-h` / `--help` / `help` | `references/help.md` 를 그대로 출력하고 종료. |

전체 플래그 매트릭스는 `references/options.md`, 독자별 편집 정책은
`references/audience-policies.md` 에 있습니다.

## 동작 단계

첫 실패에서 체인이 멈춥니다 — 재시도 없음, 부분 커밋 없음.

1. **Gather** — 인터뷰하거나 소스 자료를 읽어 문제·근본 원인·해결·재발 방지를 추출.
2. **Draft** — `references/document-template.md` 의 9개 섹션 템플릿을 적용해 파일 작성.
3. **Validate** — 구조·내용·품질 검사. 이모지 없음, 섹션 순서 준수, frontmatter 파싱 성공, 네 독자 모두 대응했는지 확인.
4. **Audience apply** — `--audience` 에 따라 편집하거나 보강.
5. **Commit (조건부)** — `--commit` 일 때만 커밋.
6. **Report** — 구체적인 다음 명령이 포함된 verdict 블록 출력.

## 주의사항과 제약

- **`$RCA_REPO_PATH` 가 모든 출력 경로의 SSOT** 입니다. 셸 프로파일에서 한 번 설정해 덮어씁니다. 기본값은 `~/para/archive/rca-knowledge`.
- **미디어는 문서 옆이 아니라 `${RCA_REPO_PATH}/_assets/` 에 중앙 집중** 됩니다.
- **`RCA_AUTO_PUBLISH=true` 가 아니면 절대 push 하지 않습니다.** `--commit` 은 커밋까지만.
- `--commit` 을 쓰려면 대상 경로가 git working tree 여야 합니다.
- 슬러그가 이미 존재하면 조용히 덮어쓰지 않고 멈춥니다.
- 이모지를 쓰지 않습니다 (Step 3 검증 항목).
