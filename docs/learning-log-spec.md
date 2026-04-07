# Learning Log DB — 학습 기록 + Abyss 데이터 원천

## 목적
모든 학습 활동을 기록하되, 단순 "뭘 공부했다"가 아니라
**학습 과정에서 드러나는 무의식 패턴**을 Abyss/PULSE의 데이터로 활용.

```
학습 대화에서 추출 가능한 무의식 데이터:
  - 어떤 주제를 빨리 이해하는가 → 인지 구조
  - 어떤 주제에서 막히는가 → 약점 + 회피 패턴
  - 질문 스타일 (구체적 vs 추상적) → 사고 구조
  - 어떤 설명 방식에서 "아!" 하는가 → 학습 선호
  - 학습 중 이탈 시점 (언제 딴짓 시작?) → 몰입 한계
  - 어떤 AI 도구를 선택하는가 → 도구 선호 패턴
```

## Notion DB 스키마

| Property | Type | 용도 |
|----------|------|------|
| Title | Title | 학습 주제 ("TCP 3-way handshake", "백준 1234") |
| Date | Date | 학습일 |
| Subject | Select | CS/Algorithm/Embedded/Project/Other |
| Tool | Select | Claude/ChatGPT/Gemini/Notion/Self |
| Duration | Number | 소요 시간 (분) |
| Confidence | Number (1-5) | 이해도 (학습 후 자가 평가) |
| Difficulty | Number (1-5) | 체감 난이도 |
| Flow | Select | Engaged/Neutral/Struggled/Gave-up |
| Key Insight | Rich Text | 핵심 배운 것 1-2문장 (자기 말로) |
| Reaction | Rich Text | 학습 중 반응 (재밌었다/어려웠다/지루했다 등) |
| Related | Rich Text | 연결되는 다른 주제 |
| Conversation Summary | Rich Text | 대화 요약 (원문 아닌 핵심만, 2000자 이내) |

페이지 본문: 대화 핵심 발췌 + 상세 메모 (길이 제한 없음)

## 데이터 흐름

```
학습 세션 (아무 AI 앱)
    ↓
기록 방법 (3가지 중 택 1)
    ↓
Learning Log DB (Notion)
    ↓
PULSE가 분석 → Insights DB
    ↓
Abyss가 교차 참조
```

## 기록 방법 3가지

### 방법 A: Claude 앱에서 직접 (가장 쉬움)
```
Claude 앱으로 학습 → 학습 끝에:
"이 대화 Learning Log에 기록해줘"
→ Claude가 대화 내용을 요약 + 파싱 → Notion에 자동 기록

또는 학습과 동시에:
Claude 앱에 MCP 연결 → 학습 대화 중 자동으로 주제/난이도/반응 감지
→ 대화 종료 시 자동 기록 제안
```

### 방법 B: 다른 AI 앱 → /daily에서 보고
```
ChatGPT/Gemini로 학습 → 밤에 /daily:
"ChatGPT로 TCP 공부 30분, 어려웠음, 3-way handshake 이해 못함"
→ Claude가 파싱 → Learning Log + Daily Log 동시 기록
```

### 방법 C: 다른 AI 앱 → 요약 복사 → Claude 앱
```
ChatGPT에서 학습 끝 → ChatGPT에게:
"이 대화 핵심을 3줄로 요약해줘"
→ 요약 복사 → Claude 앱에 붙여넣기:
"이거 Learning Log에 기록해줘. ChatGPT로 공부한 거야."
```

## PULSE 분석에서의 활용

### Weekly PULSE 추가 분석
```
Learning Log 7일 데이터에서:

학습 패턴 메트릭:
  - 주간 학습 시간 합계 + Subject별 분포
  - 평균 Confidence 변화 (주 단위 추이)
  - Flow 분포: Engaged N / Neutral N / Struggled N / Gave-up N
  - Subject별 Difficulty vs Confidence 교차
    → Difficulty 높은데 Confidence도 높으면 = 도전 + 성취 (몰입 존)
    → Difficulty 높은데 Confidence 낮으면 = 좌절 (회피 위험)
    → Difficulty 낮은데 Confidence 높으면 = 편안하지만 성장 없음

무의식 추론:
  - "Algorithm Gave-up 3회 연속" → 알고리즘 회피 패턴?
  - "Embedded만 Engaged" → 몰입 트리거 확인
  - "CS는 항상 Neutral" → 의무감으로 하는 것?
  - "ChatGPT 선택 빈도 증가" → Claude에서 원하는 답 못 받는다?
```

### Abyss 교차 분석
```
Abyss 인사이트와 학습 데이터 교차:

"즉각 피드백 선호" × 학습 데이터
  → Algorithm(지연 피드백) Confidence 낮음 + Struggled 많음
  → Embedded(즉각 피드백) Confidence 높음 + Engaged
  → 교차 확인: 인사이트 Confirmed

"하고 싶다 차단" × 학습 선택
  → 자발적 학습(Tool=Self, 주말) 주제가 뭔지
  → 의무 학습(Calendar에 있는 것) 주제와 다른지
  → 다르면: 차단된 "하고 싶다"가 여기서 새어나오고 있음

"몰입 공동화" × AI 도구 사용
  → AI로 코드 짤 때 Flow=Neutral/Gave-up → 공동화 확인
  → 직접 짤 때 Flow=Engaged → 공동화 반증
```

## 일관성 유지 — 별도 레거시 DB 필요 없음

```
기존 구조:
  Daily Log  — 하루 전체 요약 (행동/감정/계획Gap)
  Insights   — 패턴/인사이트/예측
  Goals      — 목표/방향

추가:
  Learning Log — 학습 세션별 기록

관계:
  Learning Log의 Date → Daily Log의 Date와 교차 (같은 날)
  Learning Log의 패턴 → Insights에 학습 인사이트로
  Learning Log의 방향 → Goals의 Exploring/Active에 반영

레거시 DB 불필요. Notion의 Relation으로 연결하면
PULSE가 Daily Log + Learning Log + Goals + Insights 전부 교차 분석.
```

## Curriculum DB — 학습 순서 + 진행 추적

### 목적
Claude가 "다음에 뭘 공부할지" 자동으로 파악하게 하는 구조화된 커리큘럼.
Learning Log = "뭘 했는지", Curriculum = "뭘 해야 하는지".

### 스키마
| Property | Type | 용도 |
|----------|------|------|
| Topic | Title | 학습 주제 ("TCP/IP 3-way handshake") |
| Subject | Select | CS/Algorithm/Embedded/Project |
| Week | Number | 몇 주차 |
| Order | Number | 과목 내 순서 (1,2,3...) |
| Status | Select | Not Started / In Progress / Completed / Skipped |
| Difficulty | Number (1-5) | 예상 난이도 (사전 설정) |
| Est Minutes | Number | 예상 소요 시간 |
| Completed Date | Date | 완료일 (자동) |
| Learning Log | Relation → Learning Log | 해당 학습 기록 연결 |
| Notes | Rich Text | 메모/참고 자료 |

### 초기 데이터 (life_design.md 기반)

**CS 커리큘럼 (7.5주):**
| Topic | Week | Order |
|-------|------|-------|
| 컴퓨터 구조 — CPU, 메모리, 캐시 | 1 | 1 |
| 운영체제 — 프로세스, 스레드, 데드락 | 2 | 2 |
| 네트워크 — TCP/IP, HTTP, DNS | 3 | 3 |
| 데이터베이스 — 인덱스, 정규화, 트랜잭션 | 4 | 4 |
| 자료구조 — 배열, 링크드리스트, 트리, 해시 | 5 | 5 |
| 웹 동작 원리 — URL→화면 전체 흐름 | 6 | 6 |
| 디자인 패턴 — MVC, 싱글톤, REST API | 7 | 7 |
| 복습 + 면접 빈출 정리 | 7.5 | 8 |

**알고리즘 커리큘럼 (7.5주):**
| Topic | Week | Order |
|-------|------|-------|
| 배열/문자열 기초 | 1-2 | 1 |
| 해시맵/딕셔너리 | 3-4 | 2 |
| 스택/큐 | 5-6 | 3 |
| 이진탐색, 투포인터 | 7-7.5 | 4 |

### Claude 앱에서의 자동 흐름
```
"공부하자"
  ↓
Curriculum DB 읽기 (notion-search)
  → Subject별 Status="Not Started" OR "In Progress" 중 Order 최소
  ↓
Learning Log 읽기
  → 해당 Topic의 세부 완료 상황
  ↓
"오늘 할 건 [Topic]이야. 시작할까?"
  ↓
학습 진행
  ↓
완료 시 자동:
  → Learning Log에 기록 (notion-create-pages)
  → Curriculum Status 업데이트 (notion-update-page)
  → "다음은 [다음 Topic]. 계속할래?"
```

## /setup에서 생성

Learning Log DB + Curriculum DB를 /setup 시 자동 생성.
Curriculum 초기 데이터는 life_design.md 기반으로 자동 시드.
사용자가 커리큘럼 수정 가능 (Notion에서 직접 또는 대화로).
