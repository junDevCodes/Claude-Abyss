# /setup — Life Hack 초기 세팅 + 재연결

## Step 0: 기존 시스템 감지 (재연결 플로우)
먼저 기존 Notion 시스템이 있는지 확인:
```
notion-search(query="Life Hack System Config", filters={}, page_size=5)
```
- **찾으면** → 재연결 모드:
  1. System Config 페이지 fetch → 모든 ID 추출
  2. 각 DB fetch로 접근 확인
  3. Claude 메모리에 캐시 저장
  4. "기존 시스템에 재연결 완료! 데이터 N일치 확인됨." 표시
  5. 종료 (Step 1~8 스킵)
- **못 찾으면** → 신규 설치 모드: Step 1부터 진행

---

## Step 1: Notion 부모 페이지 확인 (신규 설치)
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

## Step 7: System Config 페이지 생성 (Notion — 진실의 원천)
모든 시스템 ID와 설정을 Notion에 저장. 어떤 기기에서든 이 페이지로 시스템 복원 가능.
```
notion-create-pages(
  parent: {page_id: "PARENT_PAGE_ID"},
  pages: [{
    properties: {"title": "Life Hack System Config"},
    icon: "⚙️",
    content: "## Database IDs\n- Daily Log DB: [database_id]\n- Daily Log DS: collection://[data_source_id]\n- Insights DB: [database_id]\n- Insights DS: collection://[data_source_id]\n- Goals DB: [database_id]\n- Goals DS: collection://[data_source_id]\n- Identity Profile Page: [page_id]\n- Parent Page: [parent_page_id]\n\n## Google Calendar\n- Primary Calendar: [calendar_id]\n\n## PULSE 관찰 지침\n(Abyss 실행 후 자동 업데이트)\n\n## 사용자 설정\n- Timezone: Asia/Seoul\n- 일일 리포트 시간: 23:30\n- PULSE 톤: 상황 적응형\n\n## 시스템 버전\n- 설치일: YYYY-MM-DD\n- 마지막 /pulse monthly: (미실행)"
  }]
)
```

## Step 8: Claude 메모리에 캐시 (선택, 속도 최적화)
Claude 메모리는 **캐시**일 뿐. 없어도 Step 0에서 Notion으로 복원 가능.
```
파일: ~/.claude/projects/<project>/memory/life-hack-db-ids.md
---
name: life-hack-db-ids
type: reference
description: Life Hack DB ID 캐시 (Notion System Config가 진실의 원천)
---
(System Config 페이지 내용 복사)
```

## Step 9: System Status 페이지 생성
```
notion-create-pages(
  parent: {page_id: "PARENT_PAGE_ID"},
  pages: [{
    properties: {"title": "Life Hack System Status"},
    icon: "📊",
    content: "(초기 상태 — /verify에서 자동 채워짐)"
  }]
)
```

## Step 10: 자동 검증 실행
/verify를 자동 실행하여 전체 시스템 점검.
결과가 System Status 페이지에 기록됨.
사용자는 Notion 앱에서 이 페이지만 확인하면 됨.

## Step 11: 완료
"셋업 + 검증 완료! Notion 'System Status' 페이지에서 결과 확인 가능.

다음 단계:
- /abyss — 심연 탐색 시작 (45-60분, 추천)
- /daily — 일일 기록 시작

다른 기기에서도 이 레포를 클론하고 /setup 하면 자동으로 기존 시스템에 재연결됩니다."
