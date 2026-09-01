# GitHub Pages URL 의 owner 소문자 정규화

## Context

- **파일**: `claude/skills/claude-plugin-structure-refactor/references/op-rules.md:40`
  — Pages base 를 `https://<owner>.github.io/<repo>` 로 정의
- **파일**: `claude/skills/claude-plugin-structure-refactor/references/plan-and-report-templates.md:170`
  — 같은 공식이 한 번 더 등장
- **파일**: `visuals-skills/README.md:22-23` (Pages 링크) vs `:34,41,47,53,63` (설치 명령)
- **발견 상황**: `notes-skills` repo 에 스킬 가이드/usage HTML 을 추가하고 README 에
  Pages 절대 URL 로 링크를 거는 작업 중. `git remote get-url origin` 이 돌려주는
  `git@github.com:dEitY719/notes-skills.git` 에서 owner 를 그대로 뽑으면
  `https://dEitY719.github.io/...` 가 만들어진다.

## Pattern

Pages URL 의 owner 는 **remote URL 에서 복사하는 값이 아니라 소문자로 정규화해야 하는
값**이다. `op-rules.md` 의 공식 `https://<owner>.github.io/<repo>` 는 문자열 치환처럼
보이지만, `<owner>` 슬롯만 다른 규칙을 따른다. 같은 README 안에서 설치 명령
(`/plugin marketplace add dEitY719/...`) 은 원래 대소문자를 유지하고 Pages 링크만
소문자라는 점이 이 규칙의 증거다 — 한 파일 안에 두 표기가 공존하는 것은 실수가 아니라
서로 다른 네임스페이스이기 때문이다.

정규화를 빠뜨려도 로컬에서는 아무 신호가 없다. 링크는 문법적으로 멀쩡하고, 파일 존재
검사(`ls`)도 통과한다. 틀렸다는 사실은 Pages 가 배포된 뒤 사람이 클릭해야 드러난다.

## Code

```sh
# repo 의 remote 에서 Pages base 를 유도할 때
origin=$(git remote get-url origin)          # git@github.com:dEitY719/notes-skills.git
owner=$(basename "$(dirname "$origin")" | sed 's/.*://')   # dEitY719
repo=$(basename "$origin" .git)              # notes-skills

# [BAD] owner 를 그대로 사용
pages_base="https://${owner}.github.io/${repo}"

# [GOOD] owner 만 소문자로 정규화 (repo 이름은 대소문자 보존)
pages_base="https://$(printf '%s' "$owner" | tr '[:upper:]' '[:lower:]').github.io/${repo}"
```

`repo` 를 같이 소문자로 만들지 않는 것이 중요하다. 경로 부분은 대소문자를 구분하므로
`MyRepo` 를 `myrepo` 로 바꾸면 그때는 정말 404 가 된다.

## When to use

적용:

- `git remote` 에서 Pages URL 을 유도하는 모든 자동화 (README 백필, 링크 생성 스킬)
- owner 가 카멜케이스·혼합 대소문자인 계정 (`dEitY719`)

적용하지 않음:

- 설치 명령·클론 URL·API 경로의 `<owner>/<repo>` — 여기는 원래 표기를 유지한다
- GHE 호스팅(`https://<host>/pages/<owner>/<repo>`) — owner 가 호스트명이 아니라
  경로 세그먼트라서 이 정규화 규칙이 그대로 적용되지 않는다

## 주의점

이번 작업에서는 두 표기의 실제 응답 차이를 확인하지 못했다 — 대상 repo 의 Pages 가
아직 배포되지 않아 `curl` 이 두 형태 모두 404 를 돌려줬다. 즉 **이 함정은 Pages 배포
전에는 검증할 수 없다.** 링크를 만드는 시점에 규칙으로 막아야 하고, 나중에 눌러 보고
고치는 방식으로는 늦다.

## Related

- `claude/skills/claude-plugin-structure-refactor/references/op-rules.md` — Pages base
  유도 표. 소문자 정규화 단계가 빠져 있다
- `visuals-skills/README.md` — 정규화가 반영된 참조 구현
- [[git-worktree-detection]] — 같은 계열의 "remote/경로 정보를 그대로 믿지 말고 한 번
  가공하라" 패턴
