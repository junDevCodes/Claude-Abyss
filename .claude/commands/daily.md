# /daily — 일일 리포트 제출

사용자의 하루를 30초 이내로 기록. 질문하지 않는다. 자유 입력을 파싱.

## 사용자 기존 형식 (우선 지원)
```
Phase 1 보고

아: 쉐이크
점: 제육
저: 닭볶음탕
야: X

듀오 O / CS O 운체 / 알고 O 해시Lv1 / 운동 O 상체A / 임베 X
게임: 롤토체스 1판
취침: 1:30
```

## 축약 형식도 지원
```
아쉐이크 점제육 저닭볶 야X 듀오O CSO 알고O 운동O상체A 임베X 게임:롤토1 잠0130
```
```
m4 e3 아:쉐이크 점:제육 저:닭볶 듀오O CSO 알고O 운동O하체B 게임:발로1 잠0200 기0900 끌림:UART 피함:면접준비
```

## 파싱 규칙
- 아/점/저/야 → Meals ("아: 쉐이크 / 점: 제육 / 저: 닭볶음탕 / 야: X")
- 듀오/CS/알고/임베/프로젝트 + O/X → Activities 자유텍스트로 합산
- 운동 + 종목(상체A/하체B/유산소) → Exercise 상세
- 게임 + 종류+판수 → Gaming
- 잠/취침 → Sleep Time, 기/기상 → Wake Time
- m/무드/기분 + 숫자 → Mood, e/에너지 + 숫자 → Energy
- 끌림/끌린것 → Approached, 피함/피한것 → Avoided
- 혼자/같이/팀 → Social (Alone/Small/Group)
- 도전/challenge + 숫자 → Challenge (1-5)
- 나머지 → Freeform
- **빠진 필드 = null. 추가 질문 절대 금지.**
- Mood/Energy 안 적으면 null. 추론하지 않는다.

## 실행 순서

### 1. 파싱
사용자 입력을 위 규칙으로 파싱. 오늘 날짜 확인.

### 2. 오늘 엔트리 존재 확인
```
notion-search(
  query: "YYYY-MM-DD",
  data_source_url: "collection://DAILY_LOG_DS_ID",
  filters: {created_date_range: {start_date: "YYYY-MM-DD", end_date: "YYYY-MM-DD"}},
  page_size: 5, max_highlight_length: 0
)
```

### 3a. 없으면 → 생성
```
notion-create-pages(
  parent: {data_source_id: "DAILY_LOG_DS_ID"},
  pages: [{
    properties: {
      "Name": "YYYY-MM-DD",
      "date:Date:start": "YYYY-MM-DD",
      "Meals": "아: 쉐이크 / 점: 제육 / 저: 닭볶음탕 / 야: X",
      "Activities": "듀오O / CS O 운체 / 알고O 해시Lv1 / 임베X",
      "Exercise": "상체A (가슴고중량+등볼륨) + 유산소 20분",
      "Gaming": "롤토체스 1판",
      "Sleep Time": "01:30",
      "Mood": 4,
      "Energy": 3,
      "Source": "Manual"
    }
  }]
)
```

### 3b. 있으면 → 업데이트
```
notion-update-page(
  page_id: "기존_PAGE_ID",
  command: "update_properties",
  properties: {파싱된 필드만}
)
```

### 4. Calendar Gap (선택)
```
gcal_list_events(
  calendarId: "primary",
  timeMin: "YYYY-MM-DDT00:00:00",
  timeMax: "YYYY-MM-DDT23:59:59",
  timeZone: "Asia/Seoul"
)
```
→ Plan-Reality Gap 계산 → update

### 5. 응답
"✅ 기록 완료. [Gap 있으면 1줄 요약]. 🔥 N일 연속!"
