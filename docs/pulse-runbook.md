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
5. **무의식 추론 (핵심)**: Gap이 있으면 반드시 "왜?" 가설 분기:
   - 미완료 항목 → 목표 과잉? 에너지 부족? 관심 이탈? 대체 행동?
   - 초과 완료 항목 → 자발적 몰입? 외부 압력? 도피적 몰두?
   - Mood/Energy 이상치 → 선행 사건? 수면? 사회적 맥락?
   이전 패턴 + Abyss 인사이트와 교차하여 가설에 가중치 부여.

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

#### 5. Mood-Activity 상관 (핵심 분석)
어떤 활동이 Mood=4-5를 만드는가? 어떤 활동이 Mood=1-2를 만드는가?
Activities 필드의 자유텍스트에서 활동 추출 → Mood 교차.
→ 이것이 "무엇을 좋아하는가"의 가장 직접적인 데이터.

#### 6. 접근/회피 궤적 (변화 추적)
이번 주 TOP 3와 지난주 TOP 3 비교.
새로 등장한 접근 = 관심 신호. 사라진 접근 = 포기/포화 신호.
정적 랭킹이 아니라 변화 방향이 핵심.

#### 7. Layer 1 마이크로 스캔 (WebSearch 2-3회)
Identity Profile에서 관심 키워드 추출 → 주간 뉴스/동향 검색.
교차: "이번 주 네 몰입과 관련된 세상 움직임"
교차점 있을 때만 Insights DB에 Type="Trend" 기록.

#### 8. 무의식 종합 추론 ★★ (주간 핵심)
이번 주 전체 데이터를 관통하는 무의식 구조를 추론한다.

분석 체인:
```
1. 이번 주 현상 수집
   - 완료/미완료 패턴
   - Mood/Energy 변동
   - 접근/회피 변화
   - 모순 (말 vs 행동)
   - 대체 행동 (안 한 것 대신 한 것)

2. 각 현상에 가설 분기 (최소 2개)
   예: 임베디드 3일 스킵
     A: 강의 난이도 → 좌절 → 회피
     B: 강의 형식(영상) → 지루함 → 관심 자체는 유효
     C: 다른 활동(알고리즘)에 몰입 → 우선순위 무의식 변화

3. 데이터로 가설 검증
   - 스킵 날 대체 행동 확인 → 알고리즘 3일 연속 = 가설 C 유력
   - 임베디드 한 날의 Mood 확인 → Mood 4 = 관심은 있음 = 가설 B 유력
   - 둘 다 유력 → "관심은 있지만 형식이 안 맞아 더 재미있는 것으로 흐른다"

4. 무의식 특성 추출
   "즉각적 성취감이 있는 활동(알고리즘 풀이)을 무의식적으로 선택하고,
    지연된 보상(강의 → 실력)은 밀리는 구조"
   → 도파민 구조(life_design.md)와 교차 확인
   → Confidence: Emerging (3주 후 재확인)

5. Identity Profile 반영
   무의식 매핑 카테고리 중 어디에 해당하는지:
   → 동기 구조: 즉각 보상 선호 패턴 강화
   → 회피 패턴: "지루함" 트리거 확인
```

주간 리포트에 "이번 주 무의식 읽기" 섹션 추가:
```
🧠 무의식 읽기:
  현상: [이번 주 핵심 패턴]
  가설: [A vs B vs C]
  데이터 검증: [유력 가설 + 근거]
  추출: [무의식 특성 1문장]
  교차: [기존 인사이트/Abyss와의 일치/불일치]
```

#### 9. 수치 검증 대시보드 ★★★ (자기보고 의존 탈피)

매주 자동 계산. 전부 Daily Log + Calendar 데이터에서 산출. 자기 보고 아님.

**행동 메트릭:**
| 메트릭 | 공식 | 검증 대상 |
|--------|------|----------|
| Calendar 이행률 | 완료 이벤트 / 계획 이벤트 × 100 | 전체 |
| 접근/회피 비율 | Approached 항목수 / Avoided 항목수 | "하고 싶다" 차단 |
| 자발적 활동 비율 | Calendar에 없는데 한 것 / 전체 활동 | "하고 싶다" 실험 |
| 활동 다양성 (Shannon) | -Σ p(i)·log₂p(i) 활동 카테고리별 | 몰입 공동화 |
| Gaming 비율 | 게임 시간 / (게임+생산 활동) | 도파민 구조 |
| 수면 일관성 | stdev(취침시간) | 전반 안정성 |

**언어 분석 메트릭 (Freeform + 마무리 대화 텍스트):**
| 메트릭 | 측정 | 검증 대상 |
|--------|------|----------|
| 헤징 빈도 | "아마/글쎄/모르겠/그럴수도" 횟수/주 | "하고 싶다" 차단 |
| 감정어 비율 | 감정 표현 / 전체 단어 | F→T 전환 |
| 인과어 비율 | "때문에/그래서/왜냐면" / 전체 | F→T 전환 |
| I/We 비율 | 1인칭 / (1인칭+복수) | 관계 일방향성 |
| 욕구 표현 빈도 | "하고싶/해보고싶/끌리/재밌" 횟수 | "하고 싶다" 실험 추적 |

**계산 방법:**
Daily Log 7일치 텍스트(Activities, Approached, Avoided, Freeform)를 Claude가 분석.
각 메트릭을 숫자로 산출 → 주간 리포트에 포함 → Insights DB에 Type="Trend", Tags="Meta"로 기록.

**주간 대시보드 형식:**
```
📊 수치 대시보드 (W14)
행동:
  Calendar 이행률: 78% (전주 65% ↑13)
  접근/회피 비율: 2.1 (전주 1.4 ↑)
  자발적 활동: 23% (전주 15% ↑)
  활동 다양성: 2.3bit (전주 2.1 ↑)
  Gaming 비율: 31% (전주 42% ↓)
  수면 일관성: σ=1.2h (전주 1.8 개선)

언어:
  헤징: 12회 (전주 18 ↓)
  감정어: 8% (전주 5% ↑)
  욕구 표현: 5회 (전주 2 ↑)

추이 판정:
  ✅ "하고 싶다" 실험 효과 보임 (욕구 표현 ↑, 접근 비율 ↑)
  ⚠️ F→T: 감정어 아직 낮음
  ✅ 몰입 공동화: Gaming 비율 ↓, 다양성 ↑
```

#### 10. Confidence 승격
기존 Hypothesis가 3주+ 반복 → notion-update-page로 Emerging 변경.
기존 Emerging이 수치 메트릭으로 트렌드 확인 → Confirmed 변경.
**수치 기반 승격 기준:** 관련 메트릭이 3주 연속 같은 방향 → 트렌드 확인.

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

### MCP 호출 시퀀스 (12-20회)
```
1-2. notion-search(INSIGHTS_DS, 30일, page_size=25) × 1-2회
3.   notion-search(GOALS_DS, page_size=25)
4.   notion-fetch(IDENTITY_PROFILE_PAGE_ID)
5.   docs/life_design.md 읽기 (삶의 맥락 참조)

Layer 1 스캔 (WebSearch 5-6회, 매월 필수):
6.   Identity Profile에서 관심 키워드 추출
7.   "[키워드] 기술 트렌드 2026" (예: "임베디드 AI TinyML 트렌드")
8.   "[키워드] 채용 시장 한국" (예: "IoT 스마트팩토리 채용")
9.   "AI 대체 어려운 개발 영역 2026"
10.  "주니어 개발자 [관심분야] 진입 경로"
11.  "[관심분야] 요구 기술 스택"

Layer 2 스캔 (WebSearch 3-4회, 매월):
12.  "IT 스타트업 투자 트렌드 한국 2026"
13.  "[관심분야] 산업 성장 전망"
14.  "원격근무 개발자 트렌드 한국"

Layer 3 스캔 (WebSearch 3-5회, 분기=3,6,9,12월만):
15.  "한국 경제 전망 [년도]"
16.  "AI 규제 동향"
17.  "개발자 인력 수급 전망"
18.  "신기술 돌파구 (양자, 바이오, RISC-V 등)"
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

#### 7. 시스템 4경로 검증 (메타 메트릭)
매월 기록 (Insights DB에 Type="Trend", Tags="Meta"):

**경로 1: 행동 예측 적중률**
- Insights DB에서 Type="Prediction" 검색
- Daily Log 데이터와 대조 → 적중/미적중 판정
- 60%+ = 유효, 40% 미만 = 방법론 수정

**경로 2: 자기 인식 변화**
- 각 인사이트의 사전인지도(1-5)와 정확도(1-5) 교차
- 가치 = 정확도 × (1 - 사전인지도/5)
- 평균 가치 > 2.0 = 시스템이 새로운 것을 정확히 발견

**경로 3: 의사결정 품질**
사용자에게 물어봄:
"이번 달 인사이트를 참고해서 내린 결정이 있었어? 만족도는?"
- 인사이트 참고 결정 만족도 vs 미참고 결정 만족도 비교

**경로 4: 반사실적 검증**
사용자에게 물어봄:
"이번 달 시스템이 알려준 것 중, 시스템 없이도 알아챘을 게 몇 개야?"
- 시스템 고유 가치율 = (몰랐을 것 / 전체)
- 30% 미만 = 분석 깊이 강화 필요

**종합 기록:**
- Daily Log 수 (Manual vs Ghost)
- 인사이트 Confidence 분포
- 인사이트 무시율 (New 14일+ 유지 비율)
- 4경로 점수
→ Insights DB에 월간 메타 메트릭 페이지 생성.

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
