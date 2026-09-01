---
id: "2026-09-01-plugin-manifest-install-load-failures"
title: "구조 감사를 통과한 플러그인이 설치·로드에 실패한 3건"
slug: "plugin-manifest-install-load-failures"
date: 2026-09-01
date_created: "2026-09-01T16:40:00+09:00"
date_modified: "2026-09-01T16:40:00+09:00"
project: "packaging-skills"
category: "tooling"
severity: "medium"
tags: [claude-plugin, marketplace, manifest, schema, structure-check, audit-gap]
target_audiences: ["postmortem", "ai-learning", "junior-engineers"]
summary: "마켓플레이스 source 미상속과 plugin.json 미지원 필드로 플러그인이 설치·로드에 실패했고, 구조 감사가 M6 에서 멈춰 이를 통과시키며 오진까지 유발했다"
solution_type: "tooling"
difficulty_level: "intermediate"
reading_time_minutes: 9
blog_ready: false
---

## 1. Executive Summary

`claude-plugin-jira` 에서 플러그인이 설치되지 않거나, 설치된 뒤에도 스킬이 하나도
뜨지 않는 문제가 세 건 연달아 발생했다. 근본 원인은 매니페스트 스키마에 대한
잘못된 가정이었다 — 마켓플레이스의 최상위 `source` 가 각 플러그인에 상속된다고
믿었고, `plugin.json` 의 최상위 필드는 자유롭게 확장할 수 있다고 믿었다. 둘 다
사실이 아니다. 해결은 감사 도구의 범위를 넓히는 것이었다: `structure-check` 에
M7-M10 네 항목을 추가해 매니페스트의 설치·로드 계약을 구조 단계에서 검증한다.
핵심 교훈은 **"필수 항목을 다 통과했다"가 "동작한다"를 의미하지 않으며, 그 간극을
방치하면 감사 결과 자체가 오진의 근거가 된다**는 것이다.

## 2. Problem & Context

증상은 세 가지로 나뉘었고, 뒤로 갈수록 진단이 어려워졌다.

**증상 1 (`claude-plugin-jira#61`) — 설치 실패.** `/plugin install` 이 다음
메시지로 거부했다.

```text
This plugin uses a source type your Claude Code version does not support
```

메시지는 "버전이 낮다"고 읽히지만 실제로는 버전 문제가 아니었다. 마켓플레이스
매니페스트가 최상위에 `source` 를 두고 `plugins[]` 의 각 원소에는 두지 않은
형태였고, Claude Code(관측 버전 2.1.198)는 이 상속을 수행하지 않는다.

**증상 2 (`claude-plugin-jira#63`) — 오진.** 위 상태의 repo 에 구조 감사를
돌렸더니 **PASS** 가 나왔다. 당시 감사는 M1-M6 까지만 평가했고 여섯 항목 모두
문제가 없었기 때문이다. PASS 를 근거로 원인을 다른 곳에서 찾느라 시간이 낭비됐고,
한때는 정상적인 원격 URL 소스 설정이 범인으로 지목되기까지 했다.

**증상 3 (`claude-plugin-jira#65`) — 설치 성공, 로드 실패.** 플러그인이 깨끗하게
설치되고 `enabledPlugins` 도 true 인데 스킬이 하나도 나타나지 않았다. `/plugin`
Errors 탭에만 단서가 있었다.

```text
Plugin ... has an invalid manifest ... Validation errors: skills: Invalid input
```

영향 범위는 개발자 생산성이다. 데이터 손실이나 프로덕션 장애는 없었지만, 세 건
모두 "왜 안 되는지" 를 알아내는 데 드는 비용이 실제 수정 비용보다 훨씬 컸다.

## 3. Root Cause Analysis

세 증상은 하나의 근본 원인으로 수렴한다: **매니페스트 스키마를 문서가 아니라
직관으로 추론했다.**

**원인 1 — 상속 가정.** JSON 설정에서 상위 스코프의 값이 하위로 내려오는 것은
흔한 패턴이다(`.eslintrc`, `tsconfig` 등). 그래서 마켓플레이스 최상위에 `source`
를 한 번 쓰면 모든 플러그인이 물려받으리라 가정했다. Claude Code 는 설치 시점에
`plugins[]` 원소 각각에서 소스를 찾고, 없으면 지원하지 않는 소스 타입으로
처리한다. 상속은 일어나지 않는다.

**원인 2 — 확장 가능 스키마 가정.** `plugin.json` 에 `skills` 배열을 손으로
추가했다. 런타임이 `skills/` 디렉터리를 자동 스캔한다는 사실을 몰랐고, 폴더
이름과 같은 필드명이 있으니 지원되는 필드처럼 보였다. 실제로는 최상위 필드가
화이트리스트로 검증되며, 목록에 없는 키가 하나라도 있으면 매니페스트 전체가
검증에 실패한다. 설치는 파일 복사라 성공하고, 로드는 검증을 거치므로 실패한다 —
이 시차가 진단을 어렵게 만들었다.

**기여 요인 1 — 감사 범위와 실패 지점의 불일치.** 감사는 "디렉터리와 파일이 제
자리에 있는가"를 봤고, 실패는 "매니페스트 안의 값이 계약을 지키는가"에서 났다.
같은 파일을 열어 놓고도 서로 다른 것을 보고 있었다.

**기여 요인 2 — PASS 의 과잉 신뢰.** 감사가 좁은 범위를 검사한다는 사실이 결과에
표시되지 않았다. PASS 는 "구조 6항목 통과"였는데 읽는 쪽은 "설치된다"로 읽었다.
도구가 자기 한계를 말하지 않으면 사용자가 그 한계를 알 방법이 없다.

**환경.** Claude Code 2.1.x 매니페스트 스키마 기준. 최상위 허용 필드는
`name`(필수), `version`(필수), `description`, `author`, `homepage`,
`repository`, `license`, `keywords` 여덟 개다.

## 4. Solution & Implementation

감사 도구에 네 개의 필수 항목을 추가해, 실패가 실제로 발생하는 지점을 검사하도록
범위를 옮겼다.

수정 전 — 최상위 `source` 하나에 의존하는 형태:

```json
{
  "source": "./plugins/foo",
  "plugins": [
    { "name": "foo", "version": "0.1.0" }
  ]
}
```

수정 후 — 각 원소가 자기 소스를 갖는 형태:

```json
{
  "plugins": [
    { "name": "foo", "version": "0.1.0", "source": "./plugins/foo" }
  ]
}
```

`plugin.json` 쪽은 필드를 지우는 것으로 끝난다. 런타임이 `skills/` 를 자동
스캔하므로 이 배열은 불필요하고 동시에 스키마 위반이다.

```json
{
  "name": "foo",
  "version": "0.1.0",
  "skills": ["./skills/a", "./skills/b"]
}
```

위에서 `skills` 키를 제거하면 로드된다.

추가된 감사 항목은 다음과 같다.

1. **M7** — `plugins[]` 의 각 원소가 소스로 해석되는가. 문자열 원소는 그 자체가
   소스이고, 객체 원소는 자기 `source` 키를 가져야 한다.
2. **M8** — 해석된 소스의 형태가 유효한가. 로컬 경로 문자열이거나
   `{"source":"url","url":"..."}` 형태여야 한다.
3. **M9** — mono 레이아웃에서 선언된 로컬 플러그인 디렉터리가 디스크에 실재하는가.
4. **M10** — `plugin.json` 의 최상위 키가 전부 화이트리스트 안에 있는가.

## 5. Deep Dive — Technical Principles

**설치 시점과 로드 시점은 다른 계약을 검증한다.** 증상 3 이 특히 헷갈렸던 이유는
설치가 성공했기 때문이다. 설치는 소스를 해석해 파일을 가져오는 단계이고, 로드는
가져온 매니페스트를 스키마로 검증하는 단계다. 두 단계가 서로 다른 조건을 보므로
"설치됐다"는 "동작한다"의 근거가 되지 못한다. 진단할 때는 어느 단계에서 멈췄는지를
먼저 확정해야 하고, 그 신호는 보통 다른 UI 표면에 있다 — 설치 실패는 명령 출력에,
로드 실패는 Errors 탭에 나타났다.

**엄격한 화이트리스트와 관대한 파서의 차이.** 설정 스키마는 두 부류로 나뉜다.
모르는 키를 무시하는 관대한 쪽과, 모르는 키를 오류로 처리하는 엄격한 쪽이다.
관대한 쪽에 익숙해지면 "일단 넣어 보고 안 되면 무시되겠지"라는 습관이 생기는데,
엄격한 스키마에서는 그 한 줄이 문서 전체를 무효화한다. `plugin.json` 은 후자다.
실제로 관대하게 작성된 다른 플러그인들(`aws-login`, `ds-skills`)은 이 필드를 아예
쓰지 않는다.

**이름이 같다고 계약이 같지는 않다.** `skills` 배열이 특히 위험했던 것은 그것이
**틀려 보이지 않았기** 때문이다. 런타임이 자동 스캔하는 폴더 이름과 정확히 같아서,
지원되는 필드를 명시적으로 쓰는 것처럼 읽힌다. 이런 함정은 오타보다 훨씬 오래
살아남는다 — 코드 리뷰에서도 자연스러워 보이기 때문이다.

**감사 도구는 자기 범위를 말해야 한다.** 증상 2 는 도구 자체의 버그가 아니라
커뮤니케이션 실패였다. 감사는 정확히 설계된 대로 여섯 항목을 검사했고 정직하게
PASS 를 냈다. 문제는 그 PASS 가 무엇을 보증하고 무엇을 보증하지 않는지가 결과에
없었다는 점이다. 그래서 수정에는 항목 추가뿐 아니라 **모든 리포트에 붙는 고정
면책 문구**가 포함됐다: 구조 감사 통과는 설치·런타임 성공과 같지 않다.

**트레이드오프.** 화이트리스트 방식의 M10 은 Claude Code 가 새 필드를 지원할
때마다 갱신이 필요하다. 알 수 없는 필드를 경고로만 처리하면 유지보수는 줄지만
증상 3 을 다시 놓친다. 실패가 조용하고 진단이 비싼 쪽을 막는 편이 낫다고 판단해
FAIL 로 두고, 화이트리스트의 SSOT 위치를 명시해 갱신 지점을 하나로 고정했다.

## 6. Compatibility Matrix

| 항목 | single 레이아웃 | mono 레이아웃 | 평가 불가 조건 |
|------|-----------------|---------------|----------------|
| M7 source 해석 | yes | yes | M1 실패 또는 플러그인 0건이면 N/A |
| M8 source 형태 | yes | yes | 소스 미해석 원소는 M7 소관이라 건너뜀 |
| M9 디렉터리 실재 | no (N/A) | yes | 원격 url 소스만 있으면 N/A |
| M10 필드 화이트리스트 | yes | yes | plugin.json 없거나 깨졌으면 M3 소관 |

## 7. Prevention & Checklists

1. **매니페스트 필드는 추론하지 말고 스키마를 확인한다.** 특히 상속 여부와 허용
   필드 목록은 직관과 자주 어긋난다.
2. **감사 항목은 실패가 실제로 발생하는 지점에 둔다.** 파일 존재 검사가 값 검증을
   대신하지 못한다.
3. **도구는 자기가 검사하지 않은 것을 명시한다.** PASS 옆에 범위를 적는다.
4. **실제 사고에서 항목을 역산한다.** M7-M10 은 셋 다 실제 실패에서 나왔다.

코드 리뷰 체크리스트:

- `plugins[]` 의 모든 객체 원소가 자기 `source` 를 갖는가
- `plugin.json` 최상위에 화이트리스트 밖의 키가 없는가 (`skills` 특히 주의)
- 선언된 로컬 플러그인 디렉터리가 실재하는가
- 마켓플레이스 최상위 `source` 에 의존하는 곳이 남아 있지 않은가

테스트 전략: 화이트리스트를 fixture 의 단일 상수로 두고, Claude Code 매니페스트
스키마가 바뀔 때 버전 주석과 함께 그 한 곳만 갱신한다.

## 8. Related Issues & Patterns

**안티패턴 1 — 상속 가정(Assumed Inheritance).** 중첩 설정에서 상위 값이 하위로
내려온다고 믿고 하위에 명시하지 않는 것. 상속이 없는 스키마에서는 조용히 깨진다.

**안티패턴 2 — 그럴듯한 확장 필드(Plausible Extra Field).** 런타임이 이미 아는
개념과 같은 이름의 필드를 매니페스트에 직접 추가하는 것. 문서화된 필드처럼 보여서
리뷰를 통과한다.

**안티패턴 3 — 범위를 밝히지 않는 초록불(Unqualified Green).** 좁은 검사만 하는
도구가 그 사실을 말하지 않고 PASS 를 내는 것. 그 PASS 는 다음 진단에서 잘못된
근거로 재사용된다. 증상 2 가 정확히 이 형태였다.

적용 시점: 새 플러그인 repo 를 만들 때, 매니페스트를 손으로 편집한 뒤, 그리고
"설치는 됐는데 안 뜬다"는 보고를 받았을 때. 마지막 경우에는 설치 단계가 아니라
로드 단계 로그부터 본다.

## 9. Quick Reference

설치가 거부될 때 — `plugins[]` 의 각 객체가 자기 `source` 를 갖는지 확인:

```bash
jq -r '.plugins[] | if type=="object" then (.name + " source=" + (.source // "MISSING")) else "string:"+. end' \
  .claude-plugin/marketplace.json
```

설치는 됐는데 스킬이 안 뜰 때 — `plugin.json` 최상위에 미지원 필드가 있는지 확인:

```bash
jq -r --argjson k '["name","version","description","author","homepage","repository","license","keywords"]' \
  '[keys[]|select(. as $x|$k|index($x)|not)]|join(", ")' .claude-plugin/plugin.json
```

환경 요구사항: Claude Code 2.1.x 매니페스트 스키마. 필수 필드는 `name` 과
`version` 뿐이고 나머지 여섯 개는 선택이다.

흔한 함정: 최상위 `source` 는 상속되지 않는다. `skills` 배열은 지원되지 않는다.
구조 감사 PASS 는 설치·로드 성공을 보증하지 않는다.

더 읽을거리: `packaging:structure-check` 의 `references/structure-spec.md`
(M7-M10 정의와 판정 규칙), 원 사고 기록 `claude-plugin-jira#61`, `#63`, `#65`.
