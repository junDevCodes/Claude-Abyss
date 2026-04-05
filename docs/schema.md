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
| Type | Select | 인사이트 유형 | Pattern/Contradiction/Trend/Identity Signal |
| Horizon | Select | 시간 범위 | Daily/Weekly/Monthly |
| Content | Rich Text | 요약 | 500자 이내. 상세는 페이지 본문 |
| Evidence | Relation → Daily Log | 근거 | create 후 update로 설정 |
| Confidence | Select | 확신도 | Hypothesis/Emerging/Confirmed |
| Status | Select | 상태 | New/Acknowledged/ActingOn/Superseded |
| Tags | Multi-select | 태그 | Health/Study/Identity/Energy/Social/Career |

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
- **Multi-select 속성**: JSON 배열 형식 사용. `["Algorithm", "Embedded"]` (쉼마 구분 문자열 아님)
- **notion-search는 시맨틱 검색**: 정확한 속성값 매칭이 아님. 결과 검증 필수.
- **검색 인덱싱 지연**: 생성 직후 시맨틱 검색 수 초 지연. 키워드+date 필터 조합 사용.
