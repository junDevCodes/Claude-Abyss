# 성능 평가 지표 + 저장 위치

## 평가 데이터는 어디에 저장되는가

**전부 Notion.** Insights DB에 Type="Trend", Tags="Meta"로 저장.
별도 DB 생성 없이 기존 Insights DB를 활용.

---

## A. 시스템 성능 지표 (기술적)

/setup, /daily 등 실행 시 Claude가 자체 기록.

| 지표 | 측정 방법 | 목표 |
|------|----------|------|
| /daily 총 소요 시간 | 입력~응답 완료 | < 30초 |
| /pulse daily 소요 시간 | 실행~완료 | < 60초 |
| /pulse weekly 소요 시간 | 실행~완료 | < 90초 |
| /review today 소요 시간 | 실행~완료 | < 30초 |
| MCP 호출 성공률 | 성공/전체 | 100% |
| Notion rate limit 에러 | 429 에러 횟수 | 0 |

### 저장: 월간 PULSE에서 기록
```
Insights DB에 생성:
  Name: "System Metrics: YYYY-MM"
  Type: "Trend"
  Tags: "Meta"
  Horizon: "Monthly"
  Content: "/daily 평균 22초, /pulse weekly 평균 75초, MCP 성공률 100%"
  Confidence: "Confirmed"
  Status: "Acknowledged"
```

---

## B. 가치 검증 지표 (4경로)

### 경로 1: 행동 예측 적중률
- **생성 시점**: /abyss 종료 시 → Insights DB에 Type="Prediction"
- **검증 시점**: 30일 후 /pulse monthly
- **저장**: 해당 Prediction 인사이트의 페이지 본문에 "결과: 적중/미적중" 추가
- **집계**: 월간 메타 메트릭에 "예측 적중률: N/M (X%)" 기록
- **기준**: 60%+ = 유효, 40% 미만 = 방법론 수정

### 경로 2: 자기 인식 변화
- **생성 시점**: /abyss 종료 시 각 인사이트에 사전인지도(1-5) 기록
- **검증 시점**: 30일 후 사용자에게 정확도(1-5) 질문
- **저장**: 해당 인사이트 페이지 본문에 "사전인지도: N, 정확도: N, 가치: X" 추가
- **집계**: 가치 = 정확도 × (1 - 사전인지도/5). 평균 가치 > 2.0 = 성공
- **기준**: 평균 가치 2.0+ = 새로운 것을 정확히 발견

### 경로 3: 의사결정 품질
- **측정 시점**: 매월 /pulse monthly에서 사용자에게 질문
  "이번 달 인사이트를 참고해서 내린 결정이 있었어? 만족도는? (1-5)"
- **저장**: 월간 메타 메트릭에 기록
  "인사이트 참고 결정: N건, 평균 만족도: X/5"
- **기준**: 만족도 3.5+ = 인사이트가 실제 도움됨

### 경로 4: 반사실적 검증
- **측정 시점**: 매월 /pulse monthly에서 사용자에게 질문
  "이번 달 시스템이 알려준 것 중, 시스템 없이도 알아챘을 게 몇 개야?"
- **저장**: 월간 메타 메트릭에 기록
  "시스템 고유 가치율: N/M (X%)"
- **기준**: 30%+ = 시스템이 고유 가치 제공. 30% 미만 = 깊이 강화 필요

---

## C. 운영 건강 지표

| 지표 | 측정 | 건강 신호 |
|------|------|----------|
| Daily Log 연속 기록 (스트릭) | Source≠Ghost 연속일 | > 5일 |
| Ghost 비율 | Ghost / 전체 (주간) | < 30% |
| 인사이트 무시율 | Status=New 14일+ 유지 비율 | < 50% |
| Hypothesis→Emerging 전환율 | 3개월 누적 | > 20% |
| Emerging→Confirmed 전환율 | 3개월 누적 | > 30% |
| 인사이트 유형 분포 | Pattern/Contradiction/Trend/Identity Signal | 어느 하나 60% 미만 |
| 태그 커버리지 | 6개 태그 중 사용된 수 | 4개+ |

---

## D. 월간 메타 메트릭 페이지 형식

매월 /pulse monthly 실행 시 자동 생성:

```
Insights DB에:
  Name: "월간 메타 메트릭: YYYY-MM"
  Type: "Trend"
  Tags: "Meta"
  Horizon: "Monthly"
  Confidence: "Confirmed"
  Status: "Acknowledged"
  Content: "요약 (500자 이내)"

페이지 본문:
  ## 운영 건강
  - 기록일: N/30 (Ghost: N일)
  - 최장 스트릭: N일
  - 인사이트 총 N개 (Pattern N, Contradiction N, Trend N, Identity Signal N)
  - 무시율: N%

  ## 가치 검증 4경로
  - 경로1 예측 적중률: N/M (X%)
  - 경로2 자기인식 가치: 평균 X.X
  - 경로3 의사결정 만족도: X.X/5 (N건)
  - 경로4 시스템 고유 가치율: X%

  ## 시스템 성능
  - /daily 평균: N초
  - /pulse weekly 평균: N초
  - MCP 성공률: N%

  ## 지난달 대비 변화
  - [개선/악화된 지표 요약]
```

---

## E. 평가 흐름 요약

```
/abyss 실행
  → 예측 3-5개 생성 (Type="Prediction")
  → 각 인사이트에 사전인지도 기록
  ↓
/daily × 30일
  → Daily Log 축적
  ↓
/pulse monthly (30일 후)
  → 경로1: Prediction vs Daily Log 대조 → 적중률
  → 경로2: 사전인지도 × 정확도 → 가치 점수
  → 경로3: 사용자에게 의사결정 질문 → 만족도
  → 경로4: 반사실적 질문 → 고유 가치율
  → 시스템 성능 집계
  → 월간 메타 메트릭 페이지 생성 → Insights DB
  ↓
/review month
  → 메타 메트릭 포함하여 표시
  ↓
3개월 후
  → 메타 메트릭 3개 비교 → 시스템 개선/정체 판단
```
