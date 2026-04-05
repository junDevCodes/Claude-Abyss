# /goals — 목표 관리

$ARGUMENTS: list | add | update (기본값: list)

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
