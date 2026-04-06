# /goals — 목표 관리

$ARGUMENTS: list | add | update | seed (기본값: list)

## seed (초기 탐색 목표 세팅)
Goals DB가 비어있을 때 사용. 확정이 아니라 **탐색 실험**.

**원칙:**
- life_design.md는 참고만. 맹신 금지. 틀렸을 수 있음.
- Abyss 결과 (Insights DB)가 1순위 근거.
- 사용자가 **지금 실제로 하고 있는 것** (Calendar 이벤트)이 2순위 근거.
- 세 소스를 종합하되, 불일치가 있으면 사용자에게 물어본다.
- 모든 목표는 Status="Exploring". 데이터가 쌓여야 Active로 승격.
- PULSE weekly가 2주 후 행동 데이터 기반으로 Goals 재평가.

**프로세스:**
1. Notion Insights DB에서 Abyss Identity Signal 읽기 (1순위)
2. Calendar에서 현재 반복 이벤트 읽기 → "실제로 하고 있는 것" (2순위)
3. docs/life_design.md 읽기 (참고, 3순위)
4. 세 소스 교차 → 일치하는 것은 Exploring으로 등록, 불일치는 사용자에게 질문
5. 사용자 확인 후 생성:

```
notion-create-pages(
  parent: {data_source_id: "GOALS_DS_ID"},
  pages: [
    {properties: {"Title": "SSAFY 프로젝트 완수", "Type": "Project", "Status": "Active",
      "Why": "Phase 1 핵심. 6월 말 종료 전 완수 필요.",
      "Next Milestone": "2학기 프로젝트 완료", "date:Started:start": "2026-04-01", "date:Last Touched:start": "오늘"}},
    {properties: {"Title": "알고리즘 주 4문제", "Type": "Skill", "Status": "Active",
      "Why": "취업 면접 대비. 배열/문자열→해시맵→스택큐→이진탐색 순서.",
      "Next Milestone": "이번 주 4문제 완료", "date:Started:start": "2026-04-01", "date:Last Touched:start": "오늘"}},
    {properties: {"Title": "CS 기초 (출근길 영상)", "Type": "Skill", "Status": "Active",
      "Why": "면접 빈출 주제. 컴구→OS→네트워크→DB→자료구조→웹→디자인패턴.",
      "Next Milestone": "이번 주 주제 완료", "date:Started:start": "2026-04-01", "date:Last Touched:start": "오늘"}},
    {properties: {"Title": "임베디드 강의 (주말)", "Type": "Skill", "Status": "Active",
      "Why": "하드웨어+소프트웨어 접점. 차별화 경쟁력. life_design: '내 손으로 만들어서 작동시키는 것'.",
      "Next Milestone": "주말 3-5강", "date:Started:start": "2026-04-01", "date:Last Touched:start": "오늘"}},
    {properties: {"Title": "운동 주 5회 + 감량 90→73kg", "Type": "Habit", "Status": "Active",
      "Why": "이택민 2분할. 신경 리모델링. 6-8개월 프로젝트.",
      "Next Milestone": "이번 주 5회 달성", "date:Started:start": "2026-04-01", "date:Last Touched:start": "오늘"}},
    {properties: {"Title": "취업 준비", "Type": "Career", "Status": "Exploring",
      "Why": "Phase 2-3. 포트폴리오+이력서+면접. 스마트팩토리/IoT/로보틱스 타겟.",
      "Next Milestone": "Phase 2 시작 시 이력서 1차 작성", "date:Started:start": "2026-04-01", "date:Last Touched:start": "오늘"}},
    {properties: {"Title": "임베디드/IoT 방향 탐색", "Type": "Exploration", "Status": "Exploring",
      "Why": "Abyss + life_design: 물리적 세계+디지털 연결. 현장 경험이 자산.",
      "Next Milestone": "임베디드 사이드 프로젝트 주제 선정", "date:Started:start": "2026-04-01", "date:Last Touched:start": "오늘"}}
  ]
)
```

4. 사용자에게 결과 표시: "이렇게 세팅했어. 수정할 거 있어?"
5. 수정 요청 있으면 → update로 처리. 없으면 끝.

## list (기본)
### MCP 호출 (1회)
```
notion-search(
  query="goal",
  data_source_url="collection://GOALS_DS_ID",
  filters={},
  page_size=25,
  max_highlight_length=100
)
```
필요 시 개별 notion-fetch(page_url)로 상세.

### 표시 (상태별 그룹)
```
🎯 목표 현황

Active:
- [Title] | [Type] | 시작: [Started] | 다음: [Next Milestone]
  Why: [Why 요약]

Exploring:
- [Title] | 관련 인사이트: N개

Paused:
- [Title] | 마지막 활동: [Last Touched]

Abandoned (최근 3개):
- [Title]
```

## add
사용자에게 순서대로 질문:
1. "목표 이름은?"
2. "종류? (Habit/Skill/Project/Career/Exploration)"
3. "왜 하고 싶어?"
4. "다음 구체적 단계는?"

### MCP 호출 (1회)
```
notion-create-pages(
  parent={data_source_id: "GOALS_DS_ID"},
  pages=[{properties: {
    "Title": "사용자 입력",
    "Type": "Skill",
    "Status": "Exploring",
    "Why": "사용자 입력",
    "Next Milestone": "사용자 입력",
    "date:Started:start": "YYYY-MM-DD",
    "date:Last Touched:start": "YYYY-MM-DD"
  }}]
)
```

## update
1. 먼저 list 표시
2. "어떤 목표를 수정할래?" → 선택
3. "뭘 바꿀까? (상태/마일스톤/동기/기타)" → 해당 필드

### MCP 호출 (1-2회)
```
notion-search(GOALS_DS, 선택한 목표명)  → page_id 확인
notion-update-page(
  page_id="TARGET_PAGE_ID",
  command="update_properties",
  properties={변경 필드, "date:Last Touched:start": "YYYY-MM-DD"}
)
```

주의: Abandoned로 변경 시 삭제하지 않음. 회피 패턴 데이터로 보존.
