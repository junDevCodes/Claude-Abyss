# /review — 상태 확인 + 회고

$ARGUMENTS: today | week | month (기본값: today)

## 빈 데이터 처리
- Daily Log 없는 날: "오늘 기록이 없어. /daily로 기록하거나, 지금 간단히 알려줘."
- Insights 0개: "아직 인사이트가 없어. 데이터가 쌓이면 패턴이 보이기 시작할 거야."
- Goals 0개: "목표가 없어. /goals add로 추가할 수 있어."

## today (기본)
### MCP 호출 (3회)
```
1. notion-search(query="YYYY-MM-DD", data_source_url="collection://DAILY_LOG_DS_ID",
     filters={created_date_range: {start_date: "오늘", end_date: "오늘"}},
     page_size=5, max_highlight_length=0)
   → 오늘 Daily Log page_id 확인. 필요 시 notion-fetch(page_url)로 상세.

2. notion-search(query="insight", data_source_url="collection://INSIGHTS_DS_ID",
     filters={created_date_range: {start_date: "7일전"}},
     page_size=10, max_highlight_length=100)
   → Status=New인 항목 필터

3. notion-search(query="goal", data_source_url="collection://GOALS_DS_ID",
     filters={}, page_size=25, max_highlight_length=0)
   → Status=Active인 항목 필터
```

### 표시
```
📊 오늘 상태
- Mood: X/5, Energy: X/5
- 공부: [완료 과목], 운동: [여부]
- 🔥 N일 연속 기록

💡 미확인 인사이트 (N개)
- [Content 요약] (Confidence)

🎯 활성 목표 (N개)
- [Title] — [Next Milestone]
```

## week
### MCP 호출 (3-4회)
```
1. notion-search(DAILY_LOG_DS, 7일 date_range, page_size=25)
   필요 시 개별 notion-fetch로 상세
2. notion-search(INSIGHTS_DS, 7일 date_range, page_size=25)
3. (선택) gcal_list_events(7일간) → 계획 대비 실제
```

### 표시
```
📊 주간 회고 (MM/DD ~ MM/DD)
- Mood 평균: X.X (전주 대비 ↑↓)
- Energy 평균: X.X
- 공부 완료율: 과목별 N/7일
- 운동: N/7일
- 이번 주 인사이트: [목록]
- 접근 TOP: [1, 2, 3]
- 회피 TOP: [1, 2, 3]
```

## month
### MCP 호출 (4-6회)
```
1-2. notion-search(DAILY_LOG_DS, 30일, page_size=25) × 1-2회
3.   notion-search(INSIGHTS_DS, 30일, page_size=25)
4.   notion-search(GOALS_DS, page_size=25)
5.   notion-fetch(IDENTITY_PROFILE_PAGE_ID) → 현재 프로필
```

### 표시
```
📊 월간 회고 (M월)
- Mood/Energy 월평균 + 추이
- 인사이트 분포: Hypothesis N / Emerging N / Confirmed N
- 정체성 프로필 요약
- 목표 상태 변화
- "이번 달 발견한 나" 1문단
```
