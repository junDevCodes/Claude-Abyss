# /daily — 일일 리포트 제출

사용자의 하루를 30초 이내로 기록. 질문하지 않는다. 단일 자유입력을 파싱.

## 사용자 입력 예시
```
m4 e3 알O CSX 임O 운X 잠0230 기0900 끌림:UART구현 피함:OS강의 프로젝트하느라시간가는줄몰랐음
```
```
기분좋 에너지3 알고리즘했고 CS안함 임베디드O 운동light 끌린것:디버깅 피한것:문서작성
```

## 파싱 규칙
- m/무드/기분/Mood + 숫자 → Mood (1-5)
- e/에너지/Energy + 숫자 → Energy (1-5)
- 알/알고리즘/algo + O/했/완료 → Study Flags에 "Algorithm"
- CS/cs + O/했 → "CS" (X/안함이면 포함하지 않음)
- 임/임베디드/embedded → "Embedded"
- 듀오/Duolingo → "Duolingo"
- 프로젝트/project → "Project"
- 운/운동/exercise → Exercise (None/Light/Full)
- 잠/취침/sleep + 시간 → Sleep Time (HH:MM 형식으로 정규화)
- 기/기상/wake + 시간 → Wake Time
- 끌림/끌린것/approached: 이후 텍스트 → Approached
- 피함/피한것/avoided: 이후 텍스트 → Avoided
- 나머지 분류 안 되는 텍스트 → Freeform
- **빠진 필드 = null. 추가 질문 절대 금지.**

## 실행 순서

### 1. 파싱
사용자 입력을 위 규칙으로 파싱. 오늘 날짜 확인.

### 2. 오늘 엔트리 존재 확인
```
notion-search(
  query: "YYYY-MM-DD",
  data_source_url: "collection://DAILY_LOG_DS_ID",
  filters: {created_date_range: {start_date: "YYYY-MM-DD", end_date: "YYYY-MM-DD"}},
  page_size: 5,
  max_highlight_length: 0
)
```
반환된 결과에서 오늘 날짜의 엔트리가 있는지 확인. page_id 추출.

### 3a. 엔트리 없으면 → 생성
```
notion-create-pages(
  parent: {data_source_id: "DAILY_LOG_DS_ID"},
  pages: [{
    properties: {
      "Name": "YYYY-MM-DD",
      "date:Date:start": "YYYY-MM-DD",
      "Mood": 4,
      "Energy": 3,
      "Study Flags": "Algorithm, Embedded",
      "Exercise": "Light",
      "Sleep Time": "02:30",
      "Wake Time": "09:00",
      "Approached": "UART 구현",
      "Avoided": "OS 강의",
      "Freeform": "프로젝트하느라 시간 가는 줄 몰랐음",
      "Source": "Manual"
    }
  }]
)
```

### 3b. 엔트리 있으면 → 업데이트
```
notion-update-page(
  page_id: "기존_PAGE_ID",
  command: "update_properties",
  properties: {파싱된 필드만 업데이트, null 필드는 생략}
)
```

### 4. Calendar 이벤트 수집
```
gcal_list_events(
  calendarId: "primary",
  timeMin: "YYYY-MM-DDT00:00:00",
  timeMax: "YYYY-MM-DDT23:59:59",
  timeZone: "Asia/Seoul",
  condenseEventDetails: true
)
```

### 5. Plan-Reality Gap 계산
Calendar 이벤트(계획) vs Daily Log(실제) 비교.
- 계획에 있는데 보고 안 된 것 = 스킵/회피
- 계획에 없는데 보고된 것 = 자발적 선택
- 1,500자 이내로 작성

### 6. Gap 업데이트
```
notion-update-page(
  page_id: "오늘_PAGE_ID",
  command: "update_properties",
  properties: {"Plan-Reality Gap": "CS 1h 계획→미수행. 임베디드 계획 1h→실제 2.5h 초과투자."}
)
```

### 7. 스트릭 계산
notion-search로 최근 Daily Log 확인. Source≠Ghost인 연속 날짜 수.

## 응답 (한 줄)
"✅ 기록 완료. Gap: [요약]. 🔥 N일 연속!" 또는 "✅ 기록 완료. Gap: [요약]. 다시 시작!"

## MCP 호출 합계: 4-5회
1. notion-search (중복 확인)
2. notion-create-pages 또는 notion-update-page (기록)
3. gcal_list_events (Calendar)
4. notion-update-page (Gap)
5. (선택) notion-search (스트릭 계산 — 2에서 이미 최근 데이터 있으면 생략)
