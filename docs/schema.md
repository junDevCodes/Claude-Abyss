# Notion DB 스키마 상세 + MCP 호출 패턴

## Daily Log DB

### 스키마
| Property | Type | 설명 | 제한 |
|----------|------|------|------|
| Date | Date | 기본키. YYYY-MM-DD | |
| Study Flags | Multi-select | 완료 과목 | Options: Algorithm, CS, Embedded, Duolingo, Project |
| Exercise | Select | 운동 여부 | Options: None, Light, Full |
| Sleep Time | Text | 실제 취침 시간 | "02:30" 형식 |
| Wake Time | Text | 실제 기상 시간 | "09:00" 형식 |
| Mood | Number | 감정 상태 | 1-5 정수 |
| Energy | Number | 에너지 레벨 | 1-5 정수 |
| Approached | Rich Text | 오늘 끌린 것 | 2,000자 이내 |
| Avoided | Rich Text | 오늘 피한 것 | 2,000자 이내 |
| Freeform | Rich Text | 자유 메모 | 2,000자 이내 |
| Plan-Reality Gap | Rich Text | PULSE 자동 계산 | 1,500자 이내. 초과 시 페이지 본문 |
| Source | Select | 입력 방식 | Options: Manual, Auto, Ghost |

### MCP 호출 패턴
```
# 오늘 엔트리 검색
notion-search(
  query="YYYY-MM-DD",
  data_source_url="collection://DAILY_LOG_DS_ID",
  filters={created_date_range: {start_date: "YYYY-MM-DD", end_date: "YYYY-MM-DD"}},
  page_size=5, max_highlight_length=0
)

# 새 엔트리 생성 (★ Date는 확장 형식)
notion-create-pages(
  parent={data_source_id: "DAILY_LOG_DS_ID"},
  pages=[{properties: {
    "Name": "2026-04-05",
    "date:Date:start": "2026-04-05",
    "Mood": 4,
    "Energy": 3,
    "Study Flags": "Algorithm, Embedded",
    "Exercise": "Light",
    "Source": "Manual"
  }}]
)

# 기존 엔트리 업데이트
notion-update-page(
  page_id="EXISTING_PAGE_ID",
  command="update_properties",
  properties={"Plan-Reality Gap": "CS 1h 계획→미수행, 임베디드 초과 투자"}
)
```

## Insights DB

### 스키마
| Property | Type | 설명 | 제한 |
|----------|------|------|------|
| Date | Date | 생성일 | |
| Type | Select | 인사이트 유형 | Pattern/Contradiction/Trend/Identity Signal/Prediction |
| Horizon | Select | 시간 범위 | Daily/Weekly/Monthly/Quarterly |
| Content | Rich Text | 요약 | 500자 이내. 상세는 페이지 본문 |
| Evidence | Relation → Daily Log | 근거 | create 후 update로 설정 |
| Confidence | Select | 확신도 | Hypothesis/Emerging/Confirmed/Disconfirmed |
| Status | Select | 상태 | New/Acknowledged/ActingOn/Superseded |
| Tags | Multi-select | 태그 | Identity/Energy/Health/Study/Social/Career/Tech/Market/Industry/AI/Meta |

### Confidence 생애주기
- **Hypothesis**: 1회 발견. 사용자에게 푸시하지 않음.
- **Emerging**: 3주+ 반복. 사용자에게 제시.
- **Confirmed**: 사용자가 검증. 정체성 프로필에 반영.
- **Superseded**: 새 데이터로 무효화. 아카이브.

### MCP 호출 패턴
```
# 인사이트 생성 (일괄, ★ Date는 확장 형식)
notion-create-pages(
  parent={data_source_id: "INSIGHTS_DS_ID"},
  pages=[
    {properties: {"Name": "수요일 에너지 하락 패턴",
     "date:Date:start": "2026-04-05", "Type": "Pattern", "Horizon": "Weekly",
     "Content": "수요일 에너지 하락 3주 연속", "Confidence": "Emerging",
     "Status": "New", "Tags": "Energy"},
     content: "## 상세\n3/17 Energy 2, 3/24 Energy 2, 3/31 Energy 1"},
    {properties: {"Name": "CS 기초 목표 vs 실제 괴리",
     "date:Date:start": "2026-04-05", "Type": "Contradiction", "Horizon": "Weekly",
     "Content": "CS 기초 목표 Active인데 5/7일 스킵", "Confidence": "Hypothesis",
     "Status": "New", "Tags": "Study"}}
  ]
)

# Relation 설정 (생성 후 별도 update — 형식은 런타임 테스트 필요)
notion-update-page(page_id="NEW_INSIGHT_PAGE_ID", command="update_properties",
  properties={"Evidence": "DAILY_LOG_PAGE_ID_1, DAILY_LOG_PAGE_ID_2"})
```

## Goals & Direction DB

### 스키마
| Property | Type | 설명 |
|----------|------|------|
| Title | Title | 목표명 |
| Type | Select | Habit/Skill/Project/Career/Exploration |
| Status | Select | Exploring/Active/Paused/Abandoned |
| Why | Rich Text | 동기 (시간 경과에 따라 업데이트) |
| Connected Insights | Relation → Insights | 관련 인사이트 |
| Trend Context | Rich Text | 월간 PULSE 트렌드 |
| Next Milestone | Rich Text | 다음 구체적 단계 |
| Started | Date | 시작일 |
| Last Touched | Date | 마지막 활동일 |

### 설계 원칙
- Abandoned도 삭제하지 않음 → 회피 패턴 데이터
- Trend Context는 월간 PULSE만 업데이트 (WebSearch 결과)
- Last Touched는 관련 활동이 있을 때마다 자동 갱신

## Identity Profile (단독 페이지)
DB가 아닌 단독 Notion 페이지. /setup 시 생성.
notion-update-page(command="replace_content")로 전체 교체.

## Learning Log DB

### 스키마
| Property | Type | 설명 | 제한 |
|----------|------|------|------|
| Topic | Title | 학습 주제 | |
| Date | Date | 학습일 | |
| Subject | Select | 과목 분류 | CS/Algorithm/Embedded/Vision/Project/Other |
| Tool | Select | 학습 도구 | Claude/ChatGPT/Gemini/Notion/Self |
| Duration | Number | 학습 시간 (분) | |
| Confidence | Number | 이해도 | 1-5 정수 |
| Difficulty | Number | 체감 난이도 | 1-5 정수 |
| Flow | Select | 몰입 상태 | Engaged/Neutral/Struggled/Gave-up |
| Related | Rich Text | 연결되는 다른 주제 | 2,000자 이내 |
| Key Insight | Rich Text | 핵심 1문장 (자기 말로) | 2,000자 이내 |
| Reaction | Rich Text | 학습 후 느낀 점/반응 | 2,000자 이내 |
| Conversation Summary | Rich Text | 대화 요약 (claude.ai 앱 세션) | 2,000자 이내 |

### MCP 호출 패턴
```
# 학습 기록 생성
notion-create-pages(
  parent={data_source_id: "LEARNING_LOG_DS_ID"},
  pages=[{properties: {
    "Topic": "TCP 3-way Handshake",
    "date:Date:start": "2026-04-07",
    "Subject": "CS",
    "Tool": "Claude",
    "Duration": 45,
    "Confidence": 3,
    "Difficulty": 3,
    "Flow": 4,
    "Key Insight": "SYN-ACK는 서버가 연결을 수락했다는 의미",
    "Reaction": "네트워크 계층 구조가 점점 보이기 시작"
  }}]
)

# 최근 학습 검색
notion-search(
  query="",
  data_source_url="collection://LEARNING_LOG_DS_ID",
  filters={created_date_range: {start_date: "YYYY-MM-DD", end_date: "YYYY-MM-DD"}},
  page_size=25
)
```

## Curriculum DB

### 스키마
| Property | Type | 설명 | 제한 |
|----------|------|------|------|
| Topic | Title | 학습 항목명 | |
| Subject | Select | 과목 분류 | Algorithm/CS/Embedded/Project/Language |
| Type | Select | Tier 구분 | Tier1-Core/Tier2-Advanced/Tier3-Explore |
| Order | Number | 학습 순서 | |
| Status | Select | 진행 상태 | NotStarted/InProgress/Review/Mastered |
| Mastery | Number | 숙련도 | 1-5 정수 |
| Next Review | Date | 다음 복습일 (Spaced Repetition) | |
| Review Count | Number | 복습 횟수 | |
| Parent Week | Text | 소속 주차 | "W1", "W2" 등 |
| Algorithm Tag | Multi-select | 알고리즘 카테고리 | Array/String/Stack/Queue/Tree/Graph/DP/Greedy/Sort/Search/Hash/BFS/DFS |
| Difficulty | Select | 문제 난이도 | Bronze/Silver/Gold/Platinum |
| Platform | Select | 문제 출처 | BOJ/Programmers/LeetCode/SWEA |
| Problem ID | Text | 문제 번호 | |
| Language | Select | 풀이 언어 | Python/Java/C/C++ |
| Solved | Checkbox | 풀이 완료 여부 | |
| Solve Time | Number | 풀이 시간 (분) | |

### MCP 호출 패턴
```
# 커리큘럼 항목 생성 (일괄)
notion-create-pages(
  parent={data_source_id: "CURRICULUM_DS_ID"},
  pages=[{properties: {
    "Topic": "배열 기초",
    "Subject": "Algorithm",
    "Type": "Tier1-Core",
    "Order": 1,
    "Status": "NotStarted",
    "Mastery": 0,
    "Parent Week": "W1",
    "Algorithm Tag": "Array"
  }}]
)

# 문제 풀이 기록
notion-create-pages(
  parent={data_source_id: "CURRICULUM_DS_ID"},
  pages=[{properties: {
    "Topic": "BOJ 1920 수 찾기",
    "Subject": "Algorithm",
    "Type": "Tier1-Core",
    "Algorithm Tag": "Search, Hash",
    "Difficulty": "Silver",
    "Platform": "BOJ",
    "Problem ID": "1920",
    "Language": "Python",
    "Solved": true,
    "Solve Time": 25
  }}]
)

# 복습 대상 검색 (Mastery < 3)
notion-search(
  query="",
  data_source_url="collection://CURRICULUM_DS_ID",
  page_size=25
)
```

## 일반 규칙
- 쿼리 시 항상 date-range 필터 사용 (전체 스캔 금지)
- Rich Text property는 2,000자 제한. 초과 시 page body 사용.
- notion-create-pages는 최대 100페이지 일괄 가능.
- Notion API: 3 req/sec. 연속 호출 시 간격 고려.
- notion-search의 page_size 최대 25. 25개 초과 시 date-range를 분할하여 다중 호출.
- Multi-select 값은 쉼표 구분 문자열: "Algorithm, Embedded" (런타임 테스트 필요)

## ⚠️ 알려진 제한사항
- **created_date_range는 페이지 생성일 기준**, Date property 값 기준이 아님.
  → 소급 생성 시 제목(날짜 문자열) 검색으로 우회 가능.
- **Relation 속성**: create-pages에서 직접 설정 가능. 형식: `["https://notion.so/page_id"]`
- **Multi-select 속성**: 쉼표 구분 문자열. `"Algorithm, Embedded"` (JSON 배열 아님)
- **notion-search는 시맨틱 검색**: 정확한 속성값 매칭이 아님. 결과 검증 필수.
- **검색 인덱싱 지연**: 생성 직후 시맨틱 검색 수 초 지연. 키워드+date 필터 조합 사용.
