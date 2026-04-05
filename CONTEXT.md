# Life Hack System — 설계 맥락

이 문서는 시스템 설계 과정의 핵심 결정과 근거를 기록합니다.
새 세션에서 이 파일을 읽으면 전체 맥락을 이어갈 수 있습니다.

## 프로젝트 목적
사용자의 삶을 관찰·분석하여 무의식적 패턴을 발견하고,
"나는 누구인가"의 답을 데이터로 도출하는 시스템.

## 사용자 프로필
- 개발 공부 중인 학생, 진로 미확정
- 진정으로 좋아하는 것을 아직 모름
- 기기: PC, 노트북, 휴대폰 (클라우드 허브 필요)
- 무의식적 패턴까지 추적·인사이트 도출 원함
- 시스템 톤: 상황에 따라 유연하게 조절

## 핵심 아키텍처 결정

### 1 Brain, 2 Modes, 3 DBs
- **왜 멀티 에이전트가 아닌가**: 병렬 작업 없음, 맥락 분산이 코칭 품질 저하
- **왜 Abyss만 별도 에이전트인가**: 완전히 다른 페르소나(심리 탐정)가 필요
- **왜 Notion이 유일한 DB인가**: 모바일 접근, 클라우드 동기화, 구조화 쿼리

### 4문서 시스템 제거
- plan/task/history/checklist는 소프트웨어 개발용
- Life Hack은 반복 운영 시스템 → 문서 교체 사이클 없음
- 대안: Notion Insights DB가 history 역할

### Skills 제거
- 24개 코딩 가이드라인 중 선택하는 문제가 없음
- 모드 2개뿐 → CLAUDE.md에서 직접 라우팅

### 메모리 이중 구조
- Claude 메모리: 정체성 요약, DB ID, 관찰 지침 (세션 시작 시 자동 로드)
- Notion: 모든 구조화 데이터 (진실의 원천)
- 월간 PULSE에서 동기화. 충돌 시 Notion 우선.

## 기술적 제한사항 발견

### Notion MCP
- notion-search의 created_date_range는 페이지 생성일 기준 (Date 속성값 아님)
- Date 속성은 확장 형식: "date:Date:start": "YYYY-MM-DD"
- DB 생성은 SQL DDL 문법: CREATE TABLE (...)
- Relation은 create 후 update로 분리 필요할 수 있음
- Multi-select 형식: 쉼마 구분 문자열 (런타임 테스트 필요)
- page_size 최대 25, 3 req/sec

### 스케줄링
- CronCreate: 세션 종료 시 소멸, durable도 7일 만료
- RemoteTrigger: MCP 접근 버그 존재 (GitHub #35899, #36327)
- Phase 1 전략: Calendar 리마인더 + 수동 /pulse 실행

### Hook
- command 타입 훅은 MCP 호출 불가 — 텍스트 리마인더만
- python3 의존성 제거 → grep/cut으로 JSON 파싱

## 운영 흐름
```
최초 1회: /setup → Notion DB 생성 + Calendar 리마인더
최초 1회: /abyss → 45-60분 심연 대화 → 정체성 시드
매일 밤:  /daily → 30초 자유입력 기록
주 1-2회: /pulse → 자동 분석 (daily/weekly/monthly)
수시:     대화 → DIALOGUE 모드 코칭
확인:     /review → 상태 확인 + 회고
```

## Notion이 유일한 진실의 원천
모든 런타임 상태, DB ID, 설정, 정체성 프로필이 Notion에 저장됩니다.
Claude 메모리는 속도 최적화용 캐시일 뿐, 없어도 시스템이 동작합니다.

### 어떤 기기에서든 이어가기:
1. 레포 클론 → `claude` → `/setup`
2. /setup이 Notion에서 "Life Hack System Config" 검색
3. 찾으면 → 자동 재연결 (DB 생성 스킵)
4. /review today로 현재 상태 확인 → 바로 사용

### 핵심 Notion 페이지:
- **System Config**: 모든 DB ID, Calendar ID, PULSE 관찰 지침, 사용자 설정
- **Identity Profile**: Abyss + 월간 PULSE가 업데이트하는 정체성 문서
- **Daily Log / Insights / Goals**: 3개 DB에 모든 구조화 데이터

## 파일 구조 (최종)
```
CLAUDE.md              — 시스템 뇌 (113줄)
CONTEXT.md             — 설계 맥락 (이 파일)
.claude/
  agents/abyss.md      — 심연 에이전트 (프론트매터 포함)
  commands/             — 6개 커맨드 (/setup /abyss /daily /pulse /review /goals)
  hooks/                — 세션 시작 컨텍스트 로더
  settings.json         — 훅 + 권한
docs/
  schema.md             — DB 스키마 + MCP 호출 패턴
  pulse-runbook.md      — PULSE 실행 매뉴얼
  dialogue-runbook.md   — DIALOGUE 실행 매뉴얼
schedules/
  README.md             — 스케줄 설정 가이드
```
