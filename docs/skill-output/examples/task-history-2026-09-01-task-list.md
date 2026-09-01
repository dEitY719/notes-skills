# 2026-09-01 Task List

## 16:38 | notes-skills | 스킬 문서 트리 신설 및 Pages 링크 연결

### JIRA Ticket

```text
[Title]
[notes-skills] 스킬별 가이드/실행예시 문서 트리 신설 및 README Pages 링크 연결

[Description]
> Background
- packaging:structure-check 감사 결과 FAIL — 필수 항목 M5(docs/skill-guides,
  docs/skill-output) 위반, docs/ 디렉터리 자체가 부재
- 권장 항목 6건 중 R1/R2/R5 세 건이 모두 M5 하나에서 파생된 문제로 확인
- visuals-skills repo 에서 검증된 문서 규격을 그대로 이식하기로 결정

> Work performed
- docs/skill-guides/, docs/skill-output/ 디렉터리 생성
- 스킬 5종(rca, insight, release-note, task-history, blog-dev-learnings)의
  SKILL.md 를 근거로 가이드 문서 5건 작성 — 산출물, 형제 스킬 경계, 호출 형식,
  동작 단계, 제약을 각각 기술
- 각 스킬을 1회씩 실제 실행해 실행 기록 문서 작성. 실제 아카이브 오염을 피하기
  위해 RCA_REPO_PATH / TASK_HISTORY_DIR 환경변수와 샌드박스 repo 로 출력을 격리
- git remote 에서 Pages base URL 을 유도하되 owner 만 소문자로 정규화
  (dEitY719 -> deity719), repo 경로는 대소문자 보존

> Results
- release-note 실행: ~/dotfiles ea4bfc49..HEAD 23개 커밋을 3개 사용자 관점
  테마로 그룹핑, 비관례 커밋 0건 확인
- insight 실행: 71줄 노트 1건 + 룰북 README 색인 9번 항목 생성. Pages URL
  owner 정규화 누락을 op-rules.md:40 과 visuals-skills/README.md 대조로 입증
- structure-check 필수 FAIL 1건(M5) 해소 경로 확보

> Notes
- 이번 세션은 커밋을 만들지 않았으므로 PR 섹션은 스킬 규칙에 따라 생략
- Pages 미배포 상태라 owner 대소문자별 응답 차이는 실측 불가(양쪽 404)
```
