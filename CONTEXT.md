# Life Hack System — 설계 맥락

이 문서는 시스템 설계 과정의 핵심 결정과 근거를 기록합니다.
새 세션에서 이 파일을 읽으면 전체 맥락을 이어갈 수 있습니다.

## 프로젝트 목적
사용자의 삶을 관찰·분석하여 무의식적 패턴을 발견하고,
"나는 누구인가"의 답을 데이터로 도출하는 시스템.

## 사용자 프로필
- 24세, SSAFY 2학기 재학 (6월 말 종료)
- 영남이공대 로봇메카트로닉스 휴학 (4.2/4.5)
- 마이스터고 철강전기전자제어시스템과 → 아주스틸 → 군대 → 로봇메카 → SSAFY
- 진로 미확정, 진정으로 좋아하는 것을 찾는 중
- 기기: PC, 노트북, 휴대폰 (클라우드 허브 필요)
- 상세: docs/life_design.md (참고용, 맹신 금지)

## 핵심 아키텍처 결정

### 1 Brain, 2 Modes, 3 DBs
- **왜 멀티 에이전트가 아닌가**: 병렬 작업 없음, 맥락 분산이 코칭 품질 저하
- **왜 Abyss만 별도 에이전트인가**: 완전히 다른 페르소나(심리 탐정)가 필요
- **왜 Notion이 유일한 DB인가**: Anthropic 호스팅 MCP, 모바일 앱, 시각화, 연 600행 규모에 SQL 불필요

### 무의식 추론 엔진 (핵심 역할)
단순 기록이 아니라 모든 데이터에 "왜?" 분석 체인 적용:
```
현상 관찰 → 원인 가설 분기(2개+) → 데이터 검증 → 무의식 특성 추출 → 종합 반영
```
무의식 매핑 7카테고리: 동기구조, 회피패턴, 에너지구조, 자기보호, 사회적구조, 몰입구조, 정체성갈등

### life_design.md = 참고, 맹신 금지
이전 AI 대화 산출물. 틀렸을 수 있고, 얕을 수 있음.
Abyss는 이 문서를 의심하고 검증하는 것에서 시작.

### 4문서/Skills 시스템 제거
- plan/task/history/checklist는 소프트웨어 개발용. 운영 시스템에 맞지 않음.
- Skills는 모드 2개뿐이라 불필요. CLAUDE.md에서 직접 라우팅.

### Notion = 유일한 진실의 원천
Claude 메모리는 캐시. 없어도 Notion에서 복원.
System Config 페이지에 모든 ID/설정 저장.
어디서든 클론 → /setup → Notion 재연결 → 즉시 사용.

## Abyss — 첫 세션 교훈 (2026-04-06)

### 찾은 것 (가치 있음)
- 방향 부재, 존재 공포, 외부 의존(강점은 상대방이 인정해야)
- 유일한 내부 나침반("내가 만든 게 작동하는 순간")
- 미묘한 80%("밖에서만 80%로 보일 뿐, 내 안에선 100%가 아님")
- 미검증 믿음("내가 열심히 했는데 안 될 수가 있나?")
- 80% 관계("100% 털어놓는 사람 0명")

### 못 찾은 것 + 실패 원인
- 비판 공포 원점 → 직접 질문에 저항, 우회 전략 없어서 넘어감
- 성공 공포 → 아예 시도 안 함
- IFS 심화 → 1회 하고 끝남
- 관계/그림자 → 추상 질문만, 에피소드 안 끌어냄
- 총 25분 (목표 45-60분), Stage 3이 7분 (20분 필요)

### 재설계 적용
- 에피소드 퍼스트 (추상 질문 금지)
- 저항 우회 3가지 (시점전환/타인시점/가정은유)
- Stage 3 최소 20분 강제
- IFS 최소 3라운드
- Goals = 대화에서 자연 도출 (수동 세팅 아님)
- 아카이브: docs/archive/abyss/session-2026-04-06.md

## 하루 사이클
```
아침: /morning → Goals + Calendar 기반 오늘 브리핑
하루: 실행
밤:  /daily → Calendar 교차 검증 + 마무리 대화(되비춤+심연터치)
```

## /daily 설계
- Calendar 자동 읽기 → 체크리스트 → 사용자는 "안 한 것"만 보고
- 형식 자유 (자연어 파싱)
- 마무리 대화 3파트: 심층 질문 → 되비춤(무의식 추론 포함) → 내일 한 줄
- 심연 터치: 3일+ 패턴 반복, 감정 표현, 모순, Abyss 연결 시에만

## 외부 데이터 스캔 (PULSE 통합)
- Weekly: Layer 1 마이크로 스캔 (기술+채용, WebSearch 2-3회)
- Monthly: Layer 1+2 풀스캔 (WebSearch 8-10회)
- Quarterly: Layer 3 구조적 (경제+규제+인구, WebSearch 3-5회)
- Identity Profile 키워드가 검색 필터 역할

## 검증 프레임워크 (4경로)
1. 행동 예측 적중률 (30일, 60%+ = 유효)
2. 자기 인식 가치 = 정확도 × (1-사전인지도/5) (평균 2.0+)
3. 의사결정 품질 (90일, 만족도 3.5+/5)
4. 시스템 고유 가치율 (월간, 30%+ = 고유 가치)
상세: docs/metrics.md

## 라이프 해킹 기법 (Phase C)
- 도입: Time Boxing, Atomic Habits, Pareto 80/20, Spaced Repetition
- 제외: GTD, Deep Work(엄격), Eat the Frog, PARA(풀)
- 근거: 마감 드리븐 + 도파민 구조에 맞는 기법만

## 지식 관리 (Phase C)
- 지금: Learning Log DB (5열, 경량)
- 나중 (노트 500+개): 임베딩/지식 그래프 검토
- 상세: docs/plan.md

## 기술적 제한사항

### Notion MCP
- created_date_range = 페이지 생성일 기준. 소급 검색은 제목 검색 우회.
- Date = 확장 형식 "date:Date:start"
- DB 생성 = SQL DDL, Relation = create-pages에서 직접 가능 (["url"] 형식)
- Multi-select = JSON 배열 (["A", "B"])
- page_size 최대 25, 3 req/sec

### 스케줄링
- CronCreate 7일 만료, RemoteTrigger MCP 버그
- Phase 1: Calendar 리마인더 + 수동 실행

### Hook
- command 타입 = MCP 호출 불가, 텍스트 리마인더만

## 실행 계획 (Phase A/B/C)
- Phase A: CLI 검증 (setup→abyss→daily→pulse) ← 현재
- Phase B: Telegram 모바일화
- Phase C: 라이프 해킹 기법 + 지식 관리 통합
- 상세: docs/plan.md

## 파일 구조
```
CLAUDE.md                     — 시스템 뇌 + 무의식 추론 엔진
CONTEXT.md                    — 설계 맥락 (이 파일)
life_design.md                — 사용자 자기분석 (참고용)
.claude/
  agents/abyss.md             — 심연 에이전트
  commands/                   — 8개: setup, verify, abyss, morning, daily, pulse, review, goals
  hooks/context-loader/       — 세션 시작 리마인더
  settings.json               — 훅 + 권한
docs/
  schema.md                   — DB 스키마 + MCP 패턴
  pulse-runbook.md            — PULSE 매뉴얼 (무의식 추론 + 외부 스캔)
  dialogue-runbook.md         — DIALOGUE 매뉴얼
  metrics.md                  — 평가 지표 + 4경로 검증
  plan.md                     — 실행 계획 + 기법 선정
  life_design.md              — 사용자 자기분석 사본
  archive/abyss/              — Abyss 세션 기록
schedules/
  README.md                   — 스케줄 가이드
```
