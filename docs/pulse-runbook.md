# PULSE Runbook — 실행 매뉴얼

PULSE = Periodic Unconscious-pattern Logging and Synthesis Engine.

## MCP 호출 공통 패턴

### Daily Log 읽기 (N일)
```
notion-search(
  query: "daily log",
  data_source_url: "collection://DAILY_LOG_DS_ID",
  filters: {created_date_range: {start_date: "시작일", end_date: "종료일"}},
  page_size: 25,
  max_highlight_length: 0
)
```
→ 반환된 각 page의 url로 notion-fetch(id=page_url)하여 상세 데이터 확인.
→ 7일 이내: 1회 search + 필요시 개별 fetch.
→ 30일: search를 2주 단위로 분할 (25개 제한 대응).

### Insights 읽기
```
notion-search(
  query: "insight pattern",
  data_source_url: "collection://INSIGHTS_DS_ID",
  filters: {created_date_range: {start_date: "시작일"}},
  page_size: 25,
  max_highlight_length: 100
)
```

### Goals 읽기
```
notion-search(
  query: "goal",
  data_source_url: "collection://GOALS_DS_ID",
  filters: {},
  page_size: 25,
  max_highlight_length: 0
)
```

### 페이지 생성 시 Date 속성
```
"date:Date:start": "YYYY-MM-DD"
```

---

## 공통: Ghost 엔트리 처리

매 PULSE 실행 시 마지막 Daily Log 날짜 ~ 어제 사이 빈 날에 Ghost 엔트리 일괄 생성:
```
notion-create-pages(
  parent: {data_source_id: "DAILY_LOG_DS_ID"},
  pages: [
    {properties: {"Name": "2026-04-03", "date:Date:start": "2026-04-03", "Source": "Ghost"}},
    {properties: {"Name": "2026-04-04", "date:Date:start": "2026-04-04", "Source": "Ghost"}}
  ]
)
```

---

## Daily PULSE

### MCP 호출 시퀀스 (4-5회)
```
1. notion-search(DAILY_LOG_DS, 오늘 date_range)  → 오늘 Daily Log
2. gcal_list_events(오늘 00:00~23:59, Asia/Seoul) → 계획 이벤트
3. notion-update-page(오늘 page_id, "update_properties",
     properties: {"Plan-Reality Gap": "계산 결과"})
4. (7일+ 데이터 있을 때만) notion-create-pages(INSIGHTS_DS,
     [{properties: {"Name": "인사이트 제목",
       "date:Date:start": "오늘", "Type": "Pattern",
       "Horizon": "Daily", "Content": "요약 500자 이내",
       "Confidence": "Hypothesis", "Status": "New",
       "Tags": "Energy"}}])
5. (Ghost 필요 시) notion-create-pages(DAILY_LOG_DS, Ghost 엔트리들)
```

### 처리 로직
1. **Plan-Reality Gap**: Calendar 이벤트(계획) vs Daily Log 비교. 1,500자 이내.
2. **상관 기록**: Mood/Energy와 활동 쌍 관찰.
3. **언어 분석**: Freeform 메모에서 감정·몰입 단서 추출.
4. **스트릭**: Source≠Ghost인 연속 날짜 수.

### 마이크로 인사이트 규칙
- 7일+ 데이터 뒷받침 시에만 생성
- Horizon="Daily", Confidence="Hypothesis"
- Content는 500자 이내 요약. 상세는 페이지 본문(content).

---

## Weekly PULSE

### MCP 호출 시퀀스 (6-8회)
```
1. notion-search(DAILY_LOG_DS, 7일 date_range, page_size=25)
2. 필요 시 개별 notion-fetch(page_url)로 상세 데이터 (Approached/Avoided/Freeform)
3. gcal_list_events(7일간, timeZone=Asia/Seoul)
4. notion-search(GOALS_DS, page_size=25)  → Active 목표
5. notion-search(INSIGHTS_DS, 최근 30일)  → 기존 인사이트 (승격 체크)
6. notion-create-pages(INSIGHTS_DS, 3-5개 일괄)  → 새 인사이트
7. (승격 필요 시) notion-update-page(기존 인사이트, Confidence 변경)
8. (Ghost 필요 시) notion-create-pages(DAILY_LOG_DS, Ghost 엔트리)
```

### 분석 항목

#### 1. 요일별 패턴
각 요일 Mood/Energy/공부완료율 비교.
3주+ 동일 패턴 → Confidence="Emerging".

#### 2. 수면-성과 상관
Sleep Time별 다음날 Energy 평균.

#### 3. 접근/회피 랭킹
Approached/Avoided 텍스트에서 주제 빈도 TOP 3.

#### 4. 모순 감지 ★
Goals DB Active 목표 vs Daily Log 실제 행동:
- 목표 Active인데 관련 공부 0회 → Contradiction
- Freeform 긍정 표현이지만 투자 시간 미미 → Contradiction
- 가능성 복수 제시, 질문으로 끝냄 (단정 금지)

#### 5. Confidence 승격
기존 Hypothesis가 3주+ 반복 → notion-update-page로 Emerging 변경.
기존 Emerging이 사용자 검증됨 → Confirmed 변경.

### 인사이트 생성 형식
```
notion-create-pages(
  parent: {data_source_id: "INSIGHTS_DS_ID"},
  pages: [{
    properties: {
      "Name": "수요일 에너지 하락 패턴",
      "date:Date:start": "2026-04-05",
      "Type": "Pattern",
      "Horizon": "Weekly",
      "Content": "수요일 에너지 하락 3주 연속 관찰. 월화 SSAFY 후 번아웃 추정.",
      "Confidence": "Emerging",
      "Status": "New",
      "Tags": "Energy"
    },
    content: "## 상세 분석\n- 3/17(수) Energy 2, 3/24(수) Energy 2, 3/31(수) Energy 1\n- 월화 평균 Energy 3.5 대비 수요일 1.7\n- 가설: 월화 집중 후 수요일 회복 필요\n\n## 관련 Daily Log\n- [3/17], [3/24], [3/31]"
  }]
)
```

### 주간 리포트 형식
```
📊 주간 PULSE (MM/DD ~ MM/DD)

🔄 패턴:
- [요일별/수면/에너지 패턴]

🔍 모순:
- [Goals vs 실제 불일치]

📈 접근/회피 TOP 3:
- 접근: [1, 2, 3]
- 회피: [1, 2, 3]

💡 인사이트 (N개):
- [Content] (Confidence)

💬 질문:
- [핵심 모순/패턴에 대한 질문 1개]
```

---

## Monthly PULSE

### MCP 호출 시퀀스 (8-12회)
```
1-2. notion-search(INSIGHTS_DS, 30일, page_size=25) × 1-2회
3.   notion-search(GOALS_DS, page_size=25)
4.   notion-fetch(IDENTITY_PROFILE_PAGE_ID)
5-6. WebSearch × 1-2회 (관련 트렌드)
7.   notion-update-page(IDENTITY_PROFILE, "replace_content", 새 프로필)
8-9. notion-update-page(Goals, Trend Context 업데이트) × 필요한 목표 수
10.  notion-create-pages(INSIGHTS_DS, 월간 인사이트)
11.  (승격/Superseded) notion-update-page × 필요 수
12.  Claude 메모리 파일 업데이트 (Write tool)
```

### 처리 항목

#### 1. 정체성 프로필 업데이트
Confirmed 인사이트 종합 → Identity Profile 페이지 전체 교체:
```
notion-update-page(
  page_id: "IDENTITY_PROFILE_PAGE_ID",
  command: "replace_content",
  new_str: "## Confirmed Traits\n- 구체적 실습형\n- 독립 작업 선호\n\n## Immersion Triggers\n- 임베디드 프로젝트\n- 알고리즘 문제풀이\n\n## Avoidance Patterns\n- CS 이론 강의\n- 문서 작성\n\n## Core Values (Estimated)\n- 가시적 결과물\n- 자율성\n\n## Unconfirmed Hypotheses\n- 수요일 번아웃 패턴 (Emerging)\n- 네트워킹 회피 (Hypothesis)"
)
```

#### 2. 방향 추론
Identity Signal 누적 → 커리어 방향 제시. Confidence 명시.

#### 3. 세상 읽기
WebSearch로 트렌드 → Goals DB Trend Context 업데이트.

#### 4. 분석 프레임 교체
매월 다른 렌즈 (습관일관성 → 에너지패턴 → 사회적에너지 → 회피심층분석).
Claude 메모리에 "이번 달 프레임: [X]" 저장.

#### 5. 메모리 동기화
정체성 프로필 요약을 Claude 메모리에 반영. 구 메모리 항목 제거/수정.

#### 6. 예측 검증 (Abyss 포함)
지난달 Hypothesis → 이번 달 데이터로 확인/기각.

**Abyss 행동 예측 검증** (Abyss 실행 30일 후):
- Insights DB에서 Type="Prediction" 항목 검색
- 각 예측의 성공/실패 기준을 Daily Log 데이터와 대조
- 적중률 계산: N/총예측수
- 결과:
  - 60%+ 적중 → Abyss가 실제 패턴을 잡았음. Confirmed로 승격.
  - 40-60% → 부분적. Emerging 유지. 방향은 맞으나 세부 조정 필요.
  - 40% 미만 → Abyss가 잘못 짚음. 해당 인사이트 Superseded 처리.
    → /abyss 재실행 또는 질문 방법론 수정 고려.

#### 7. 시스템 자기 검증 (메타 메트릭)
매월 기록 (Insights DB에 Type="Trend", Tags="Meta"):
- Daily Log 엔트리 수 (Manual vs Ghost)
- 인사이트 Confidence 분포
- 인사이트 무시율 (Status=New가 14일 이상 유지된 비율)
- 행동 예측 적중률 (있는 경우)
→ 시스템 자체의 유효성을 장기 추적.

### 월간 리포트 형식
```
🧬 [M월] 종합 리포트

📋 정체성:
- Confirmed: [성향들]
- Emerging: [패턴들]
- 신규: [이번 달 발견]

🧭 방향: [데이터 기반 방향] (Confidence)

🌍 트렌드: [세상 동향]

📊 예측 검증:
- [가설] → [결과]

🔭 이번 달 프레임: [새 렌즈]

💬 질문: [정체성 관련 깊은 질문 1개]
```
