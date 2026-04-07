# Life Hack System — 실행 계획

## 실행 순서

### Phase A: 시스템 검증 (CLI) + 학습 DB
1. `/setup` 실행 — Notion DB 생성, 뷰, Calendar 리마인더, ID 저장
2. `/abyss` 실행 — life_design.md 검증 + 심층 탐색 (45-60분)
3. `/daily` 3-5일 운영 — 파싱, Gap 계산, Notion 기록 안정성 확인
4. `/pulse weekly` 1회 — 분석 품질 + 4경로 검증 기반 확보
5. Abyss 신뢰도 판정 — 행동 예측 + 사전인지도 기록 확인
6. ✅ Learning Log DB 추가 (Notion) — 학습 세션 상세 기록
7. ✅ Curriculum DB 추가 (Notion) — 3-Tier 커리큘럼 + 알고리즘 숙련도 추적

### Phase B: 모바일화 (검증 완료 후)
6. Telegram 봇 설계 + 개발 (2-3일)
7. 일상 운영을 Telegram으로 전환 (daily, pulse, review, 대화)
8. CLI = 깊은 작업 (Abyss, 시스템 수정), Telegram = 일상 운영

### Phase C: 기법 통합 (안정화 후)
9. PULSE에 Pareto 분석 + 학습 연결 분석 추가
10. Time Boxing + Atomic Habits 적용
11. Spaced Repetition 도입 (선택)

---

## 라이프 해킹 기법 선정

사용자 특성: 마감 드리븐, 80% 패턴, 적응형, 도파민 추구.

### 도입할 기법 (4개)

**Time Boxing**
- 이미 Calendar에 시간블록 존재. 각 블록 완료 = 미니 마감 = 도파민.
- 구현: 기존 Calendar 구조 유지. PULSE가 블록 이행률 추적.

**Atomic Habits (습관 스태킹)**
- 기존 루틴에 새 행동을 연결. "커피 후 → Anki 5장" 식.
- 구현: Goals DB에 Type="Habit"으로 스택 정의. PULSE가 이행 추적.

**80/20 Pareto**
- 80% 패턴을 역이용. 전부가 아니라 임팩트 큰 20%에 집중.
- 구현: PULSE weekly에서 "이번 주 시간 대비 효과 높은/낮은 활동" 분석.

**Spaced Repetition**
- CS/임베디드 기술 지식 고착. "맞추는 쾌감" = 도파민 루프.
- 구현: Learning Log에서 Confidence < 3인 항목 → 복습 제안.

### 도입하지 않을 기법

| 기법 | 이유 |
|------|------|
| GTD | 인박스/컨텍스트/주간리뷰 오버헤드. 2주 후 버릴 것 |
| Deep Work (엄격) | 3-4시간 블록은 도파민 구조와 충돌. 60-90분이 한계 |
| Eat the Frog | 아침 어려운 것부터 → 시작 자체를 미룸. 워밍업 필요한 타입 |
| PARA (풀) | 유지 못함. "Archive" 개념만 차용 |
| Pomodoro | Time Boxing이 커버. 중복 |
| Eisenhower | 멘탈 모델로는 유용. 시스템으로 만들 필요 없음 |

---

## 지식 관리 전략

### 지금: Learning Log (경량)

Notion DB 1개, 5열:

| 필드 | 타입 | 용도 |
|------|------|------|
| Date | Date | 학습일 |
| Topic | Text | 주제 (캐시, TCP/IP, UART 등) |
| Key Insight | Rich Text | 핵심 1문장 (자기 말로) |
| Confidence | Number (1-5) | 이해도 |
| Related | Rich Text | 연결되는 다른 주제 |

- /daily 입력 시 공부 내용이 있으면 자동 기록
- PULSE weekly에서 자동 분석:
  "이번 주 네트워크와 OS 공부 → 둘 다 소켓에서 만남.
   소켓 Confidence 2. 다음 주 집중 제안."
- 사실상 자동화된 경량 지식 그래프

### 나중: 본격 지식 그래프 (취업 후, 노트 500+개)

지금 하지 않는 이유:
- 6월까지 3개월. 시스템 구축 시간 = 공부 못하는 시간.
- 500+ 노트 전에는 그래프의 교차 가치가 없음.
- 임베딩/벡터DB는 현재 규모에서 과잉 엔지니어링.

이행 조건: Learning Log 500행+ 도달 시 Obsidian 또는 임베딩 검색 도입 검토.

---

## 외부 데이터 스캔 (PULSE 통합)

### Weekly (Layer 1, WebSearch 2-3회)
- Identity Profile 키워드 기반 기술/채용 마이크로 스캔
- 이번 주 접근/회피와 교차 분석

### Monthly (Layer 1+2, WebSearch 8-10회)
- 기술 트렌드 + 채용 시장 + AI 영향 + 교육 경로 풀스캔
- 산업 전망 + 투자 동향

### Quarterly (Layer 3, WebSearch 3-5회 추가)
- 경제 지표 + 인구 수급 + 지정학 + 규제 + 과학 돌파구

필터 원칙: Identity Profile이 검색 키워드 결정. 교차점 없으면 무시.

---

## 검증 프레임워크 (4경로)

| 경로 | 측정 | 시점 | 기준 |
|------|------|------|------|
| 행동 예측 적중률 | Abyss 예측 vs Daily Log | 30일 | 60%+ |
| 자기 인식 가치 | 정확도 × (1-사전인지도/5) | 30일 | 평균 2.0+ |
| 의사결정 품질 | 인사이트 참고 결정 만족도 | 90일 | 3.5+/5 |
| 시스템 고유 가치율 | "시스템 없이 알았을 것" 비율 | 월간 | 30%+ |

상세: docs/metrics.md 참조.

---

## 시스템 구조 (최종)

```
CLI (깊은 작업)          Telegram (일상 운영, Phase B)
├── /setup               ├── 매일 23:30 자동 질문
├── /abyss               ├── /daily 응답 처리
├── 시스템 수정           ├── /pulse 자동 실행 + 결과 전송
└── 디버깅               ├── /review 조회
                         ├── 대화 코칭
                         └── 2주 심층 체크인

         ↕ 동일 Notion DB ↕

Notion (데이터 허브, 모바일 확인)
├── Daily Log DB
├── Insights DB (+ Prediction, Trend, Meta)
├── Goals & Direction DB
├── Learning Log DB
├── Curriculum DB
├── Identity Profile 페이지
└── System Config 페이지
```

---

## 하지 않을 것 목록

| 항목 | 이유 |
|------|------|
| PARA 풀 시스템 | 유지 불가. Archive 개념만 차용 |
| 벡터 임베딩 + 지식 그래프 | 현재 규모 과잉. 500+ 노트 후 재검토 |
| GTD 인박스 | 오버헤드. 2주 후 버릴 것 |
| Obsidian 추가 | 도구 추가 금지. Notion으로 통일 |
| 별도 시간 추적 앱 | Calendar + Daily Log로 충분 |
| 모바일 네이티브 앱 | Telegram 봇이 90%의 가치를 10%의 비용으로 |
