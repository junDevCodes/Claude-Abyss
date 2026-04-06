# /morning — 하루 시작

## 핵심: Goals + Calendar 기반으로 오늘의 초점 설정

## Step 1: 오늘 Calendar 읽기

```
gcal_list_events(
  calendarId: "primary",
  timeMin: "YYYY-MM-DDT00:00:00",
  timeMax: "YYYY-MM-DDT23:59:59",
  timeZone: "Asia/Seoul",
  condenseEventDetails: true
)
```

## Step 2: Active Goals 확인

```
notion-search(
  query: "goal",
  data_source_url: "collection://GOALS_DS_ID",
  filters: {},
  page_size: 25,
  max_highlight_length: 0
)
```
→ Status=Active 필터

## Step 3: 최근 맥락 확인

```
notion-search(DAILY_LOG_DS, 최근 3일)
```
→ 어제 Mood/Energy, 스트릭, 최근 패턴

```
notion-search(INSIGHTS_DS, 최근 7일, Status=New)
```
→ 미확인 인사이트

## Step 4: 오늘 브리핑 생성

### 구성 (짧게, 1분 읽기)

```
☀️ [요일] 브리핑

📅 오늘 일정:
  09:00 SSAFY
  11:30 🧩 알고리즘
  20:00 💪 상체A

🎯 오늘 초점 (Goals에서):
  1. [가장 임팩트 큰 것 1개]
  2. [두 번째]

📊 어제:
  Mood X / Energy X / [완료/미완료 요약]
  
💡 주목:
  [미확인 인사이트 있으면 1줄 / 없으면 생략]

한마디: [동기부여 또는 관찰 1문장]
```

### 초점 선택 규칙
1. **Goals DB Active 목표 중 Next Milestone이 가장 급한 것** 우선
2. **어제 못한 것** 중 오늘 Calendar에 있는 것 → "어제 못 했으니 오늘은"
3. **PULSE 인사이트 연동**: 패턴 반복 시 → "이번 주 계속 [X] 스킵. 오늘은 해볼 수 있을까?"
4. **Pareto**: 7일간 활동 대비 임팩트 분석 → "이것만 하면 이번 주 80% 달성"

### 톤
- 짧고 명확. 설교 아님.
- 어제 잘 했으면: "어제 페이스 좋았어. 이어가자."
- 어제 안 했으면: "어제는 쉬었으니 오늘 가볍게 시작해보자."
- 중요 마감 있으면: "SSAFY 프로젝트 D-N. 오늘 [구체적 할 것] 집중."

### Pareto 분석 (주 1회, 월요일)
월요일 /morning에서 추가:
```
📊 이번 주 Pareto:
  지난주 시간 배분: 알고리즘 40% / CS 20% / 임베디드 10% / 기타 30%
  취업 임팩트 기준: 알고리즘(높음) / 임베디드(높음) / CS(중간)
  제안: 임베디드 비중 10→25%로 올리면 취업 준비 효율 ↑
```

## Step 5: 사용자 반응 (선택)

사용자가 조정하고 싶으면:
- "오늘 운동 안 할래" → "알겠어. Calendar에서 제외할까?"
- "임베디드 추가하고 싶어" → "좋아. 몇 시에 할 수 있어?"
- 반응 없으면 → 브리핑 그대로 확정. 끝.

**추가 질문 안 함. 브리핑 보여주고 끝.**

## Step 6: System Status 업데이트

```
notion-update-page(SYSTEM_STATUS, "운영 현황":
  "마지막 /morning: YYYY-MM-DD HH:MM ✅")
```

## MCP 호출 총계: 4-5회
```
1. gcal_list_events (오늘)
2. notion-search (Goals)
3. notion-search (Daily Log 3일)
4. notion-search (Insights 7일)
5. notion-update-page (System Status)
```

## 전체 흐름 예시

```
User: /morning

Claude: "☀️ 수요일 브리핑

📅 오늘:
  07:35 🚇 출근길 (듀오+CS)
  11:30 🧩 알고리즘
  20:00 🏃 유산소 데이

🎯 오늘 초점:
  1. 알고리즘 — 해시맵 문제 1개 (이번 주 3/4 완료, 오늘 하면 달성)
  2. CS 영상 — 네트워크 (면접 빈출)

📊 어제: Mood 4 / Energy 3 / 전부 완료 🔥6일 연속

한마디: 수요일은 보통 에너지 떨어지는 날이야. 무리하지 말고 알고리즘 1개만 확실히."
```
