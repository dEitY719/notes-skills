# Git Commands for Release Notes

> **전제 조건**: 아래 명령어는 git repository 내부에서 실행되어야 한다. 호출 전 `git rev-parse --show-toplevel >/dev/null 2>&1` 로 확인하거나, 실패 시 사용자에게 "릴리즈 노트 작성은 git repo 안에서 실행해 주세요"로 안내할 것.

## 앵커 커밋 찾기

### 1) 태그 기반 (가장 신뢰할 수 있음)

```bash
# 로컬 태그
git tag --list '*<prev-version>*' --sort=-creatordate

# 원격에만 태그가 있을 수 있음
git fetch --tags
git tag --list '*<prev-version>*'
```

### 2) 이전 릴리즈 노트 문서 커밋

태그가 없는 프로젝트에서 가장 흔한 관례. 릴리즈 노트 커밋 자체가 릴리즈 경계 역할을 한다.

```bash
git log --oneline --format="%H %s" | grep -i "<prev-version>"
# 예시 출력: 073376f docs: add v0.1.0-alpha2 release notes
```

### 3) 사용자 확인

위 두 가지로 찾을 수 없으면 사용자에게 시작 커밋 해시 또는 날짜를 직접 확인한다.

## 커밋 수집 및 분류

Step 2 는 이 두 가지를 스킬에 동봉된 `skills/release-note/lib/collect-commits.sh`
한 번의 호출로 처리한다 (커밋별 type/sha/subject + 총계/날짜 범위 요약).
helper 는 스킬 디렉토리 안에 있으므로 Hermes tap / `npx skills add` 처럼 이 스킬
디렉토리 하나만 설치하는 하네스에서도 함께 따라온다.

경로 해석은 `SKILL.md` Step 2 의 가드 블록이 담당한다 (정본:
`dEitY719/harness-skills` `references/plugin-root.md`):

1. `${HERMES_SKILL_DIR}` 가 비어 있지 않으면 `${HERMES_SKILL_DIR}/lib/collect-commits.sh`
   (스킬 루트 기준 — Hermes 가 `SKILL.md` 본문에 치환해 넣는다).
2. 아니면 `CLAUDE_PLUGIN_ROOT` 가 비어 있지 않을 때
   `$CLAUDE_PLUGIN_ROOT/skills/release-note/lib/collect-commits.sh` (플러그인 루트 기준).
3. 둘 다 없으면 `[FAIL]` 로 멈춘다. `$PWD`/`.` 으로 추측하지 않는다 — 이 워크플로는
   릴리즈 노트를 만들 대상 프로젝트에서 실행되므로 CWD 는 이 스킬이 아니다.

`[FAIL]` 을 받은 하네스(Codex, Kimi, Gemini, OpenCode, Antigravity 등)는 `SKILL.md` 를
읽은 디렉토리(= 이 파일의 상위 디렉토리)를 직접 지정해 실행한다:

```bash
export HERMES_SKILL_DIR="<SKILL.md 가 있는 디렉토리의 절대 경로>"
bash "$HERMES_SKILL_DIR/lib/collect-commits.sh" <anchor> [<head-ref>]
```

아래는 그 스크립트가 감싼 개별 명령어 — 스크립트가 실패하거나 범위를 수동으로
다시 확인해야 할 때만 참고.

```bash
# 전체 커밋 (시간 순)
git log --oneline --reverse <anchor>..HEAD

# 개수
git log --oneline --reverse <anchor>..HEAD | wc -l

# 날짜 범위 (시작 / 끝)
git log --format="%ad" --date=short <anchor>..HEAD | sort | head -1
git log --format="%ad" --date=short <anchor>..HEAD | sort | tail -1
```

## 변경 파일 확인 (테마 그룹핑 시 유용)

```bash
# 특정 커밋이 어느 영역을 건드렸는지
git show --stat <commit-hash>

# 범위 전체에서 자주 변경된 파일 (핵심 변경 영역 파악)
git log --name-only --pretty=format: <anchor>..HEAD | sort | uniq -c | sort -rn | head -20
```

## 기여자 목록

```bash
git log --format="%an" <anchor>..HEAD | sort -u
```
