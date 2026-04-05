# /setup — Life Hack 초기 세팅

최초 1회 실행. Notion DB 생성, 뷰 설정, Calendar 연결, 메모리 저장.

## Step 1: Notion 부모 페이지 확인
사용자에게: "Life Hack 시스템을 만들 Notion 페이지 URL 또는 ID를 알려주세요."
- notion-fetch(id=사용자입력)으로 접근 확인
- page_id 추출

## Step 2: DB 3개 생성 (순서 중요)

### 2-1. Daily Log DB
```
notion-create-database(
  parent: {page_id: "PAGE_ID"},
  title: "Daily Log",
  schema: "CREATE TABLE (
    \"Name\" TITLE,
    \"Date\" DATE,
    \"Study Flags\" MULTI_SELECT('Algorithm':blue, 'CS':purple, 'Embedded':green, 'Duolingo':yellow, 'Project':orange),
    \"Exercise\" SELECT('None':gray, 'Light':green, 'Full':blue),
    \"Sleep Time\" RICH_TEXT,
    \"Wake Time\" RICH_TEXT,
    \"Mood\" NUMBER,
    \"Energy\" NUMBER,
    \"Approached\" RICH_TEXT,
    \"Avoided\" RICH_TEXT,
    \"Freeform\" RICH_TEXT,
    \"Plan-Reality Gap\" RICH_TEXT,
    \"Source\" SELECT('Manual':blue, 'Auto':green, 'Ghost':gray)
  )"
)
```
→ 반환된 database_id와 `<data-source url="collection://...">` 의 data_source_id 기록.

### 2-2. Insights DB
```
notion-create-database(
  parent: {page_id: "PAGE_ID"},
  title: "Insights",
  schema: "CREATE TABLE (
    \"Name\" TITLE,
    \"Date\" DATE,
    \"Type\" SELECT('Pattern':blue, 'Contradiction':red, 'Trend':green, 'Identity Signal':purple),
    \"Horizon\" SELECT('Daily':gray, 'Weekly':blue, 'Monthly':purple),
    \"Content\" RICH_TEXT,
    \"Evidence\" RELATION('DAILY_LOG_DATA_SOURCE_ID'),
    \"Confidence\" SELECT('Hypothesis':gray, 'Emerging':yellow, 'Confirmed':green),
    \"Status\" SELECT('New':blue, 'Acknowledged':yellow, 'ActingOn':green, 'Superseded':gray),
    \"Tags\" MULTI_SELECT('Health':green, 'Study':blue, 'Identity':purple, 'Energy':yellow, 'Social':orange, 'Career':red)
  )"
)
```
→ Evidence relation에 Step 2-1의 Daily Log data_source_id 사용.
→ Insights의 database_id, data_source_id 기록.

### 2-3. Goals & Direction DB
```
notion-create-database(
  parent: {page_id: "PAGE_ID"},
  title: "Goals & Direction",
  schema: "CREATE TABLE (
    \"Title\" TITLE,
    \"Type\" SELECT('Habit':blue, 'Skill':green, 'Project':orange, 'Career':purple, 'Exploration':yellow),
    \"Status\" SELECT('Exploring':yellow, 'Active':green, 'Paused':gray, 'Abandoned':red),
    \"Why\" RICH_TEXT,
    \"Connected Insights\" RELATION('INSIGHTS_DATA_SOURCE_ID'),
    \"Trend Context\" RICH_TEXT,
    \"Next Milestone\" RICH_TEXT,
    \"Started\" DATE,
    \"Last Touched\" DATE
  )"
)
```
→ Connected Insights relation에 Step 2-2의 Insights data_source_id 사용.
→ Goals의 database_id, data_source_id 기록.

## Step 3: Identity Profile 페이지 생성
```
notion-create-pages(
  parent: {page_id: "PAGE_ID"},
  pages: [{
    properties: {"title": "Identity Profile"},
    content: "## Confirmed Traits\n(심연 대화 후 채워짐)\n\n## Immersion Triggers\n(심연 대화 후 채워짐)\n\n## Avoidance Patterns\n(심연 대화 후 채워짐)\n\n## Core Values (Estimated)\n(심연 대화 후 채워짐)\n\n## Unconfirmed Hypotheses\n(PULSE 관찰 중)"
  }]
)
```
→ 반환된 page_id 기록.

## Step 4: Notion 뷰 생성

### Daily Log 뷰
```
notion-create-view(
  database_id: "DAILY_LOG_DB_ID",
  data_source_id: "DAILY_LOG_DS_ID",
  name: "Calendar",
  type: "calendar",
  configure: "CALENDAR BY \"Date\""
)

notion-create-view(
  database_id: "DAILY_LOG_DB_ID",
  data_source_id: "DAILY_LOG_DS_ID",
  name: "Recent",
  type: "table",
  configure: "SORT BY \"Date\" DESC; SHOW \"Date\", \"Mood\", \"Energy\", \"Study Flags\", \"Exercise\", \"Source\""
)
```

### Insights 뷰
```
notion-create-view(
  database_id: "INSIGHTS_DB_ID",
  data_source_id: "INSIGHTS_DS_ID",
  name: "By Confidence",
  type: "board",
  configure: "GROUP BY \"Confidence\"; FILTER \"Status\" != \"Superseded\""
)

notion-create-view(
  database_id: "INSIGHTS_DB_ID",
  data_source_id: "INSIGHTS_DS_ID",
  name: "Recent",
  type: "table",
  configure: "SORT BY \"Date\" DESC; FILTER \"Status\" != \"Superseded\""
)
```

### Goals 뷰
```
notion-create-view(
  database_id: "GOALS_DB_ID",
  data_source_id: "GOALS_DS_ID",
  name: "By Status",
  type: "board",
  configure: "GROUP BY \"Status\""
)
```

## Step 5: Google Calendar 확인
```
gcal_list_calendars()
```
사용자에게 주 사용 캘린더 확인. calendar_id 기록.

## Step 6: PULSE 리마인더 이벤트 생성
```
gcal_create_event(
  calendarId: "PRIMARY_CAL_ID",
  summary: "🔍 /pulse daily 실행",
  start: {dateTime: "2026-04-05T23:30:00", timeZone: "Asia/Seoul"},
  end: {dateTime: "2026-04-05T23:45:00", timeZone: "Asia/Seoul"},
  recurrence: ["RRULE:FREQ=DAILY"],
  reminders: {overrides: [{method: "popup", minutes: 0}]}
)

gcal_create_event(
  calendarId: "PRIMARY_CAL_ID",
  summary: "📊 /pulse weekly 실행",
  start: {dateTime: "2026-04-06T21:30:00", timeZone: "Asia/Seoul"},
  end: {dateTime: "2026-04-06T21:45:00", timeZone: "Asia/Seoul"},
  recurrence: ["RRULE:FREQ=WEEKLY;BYDAY=SU"],
  reminders: {overrides: [{method: "popup", minutes: 0}]}
)

gcal_create_event(
  calendarId: "PRIMARY_CAL_ID",
  summary: "🧬 /pulse monthly 실행",
  start: {dateTime: "2026-05-01T10:00:00", timeZone: "Asia/Seoul"},
  end: {dateTime: "2026-05-01T10:15:00", timeZone: "Asia/Seoul"},
  recurrence: ["RRULE:FREQ=MONTHLY;BYMONTHDAY=1"],
  reminders: {overrides: [{method: "popup", minutes: 0}]}
)
```

## Step 7: Claude 메모리에 저장
Write tool로 메모리 파일 생성:
```
파일: ~/.claude/projects/<project>/memory/life-hack-db-ids.md
---
name: life-hack-db-ids
type: reference
description: Life Hack 시스템의 Notion DB ID와 Calendar ID
---
- Daily Log DB: [database_id]
- Daily Log DS: collection://[data_source_id]
- Insights DB: [database_id]  
- Insights DS: collection://[data_source_id]
- Goals DB: [database_id]
- Goals DS: collection://[data_source_id]
- Identity Profile Page: [page_id]
- Primary Calendar: [calendar_id]
```
MEMORY.md 인덱스에도 추가.

## Step 8: 완료
"셋업 완료! 다음 중 선택:
- /abyss — 심연 탐색 시작 (45-60분, 추천)
- /daily — 일일 기록 시작 (30초)"
