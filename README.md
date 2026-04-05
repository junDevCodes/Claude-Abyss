# Life Hack System

삶을 관찰·분석하여 무의식적 패턴을 발견하고, 방향을 제시하는 개인 코칭 시스템.

## Quick Start

```bash
git clone <repo-url>
cd "Life Hack"
claude
# 첫 실행:
/setup
# 심연 대화 (45-60분, 1회 추천):
/abyss
# 매일:
/daily m4 e3 알O CSX 임O 끌림:프로젝트 피함:이론
# 분석:
/pulse weekly
```

## 필요 사항
- [Claude Code](https://claude.com/claude-code) CLI
- Notion 계정 + Claude AI Notion MCP 연결
- Google Calendar + Claude AI Calendar MCP 연결

## 커맨드

| 커맨드 | 용도 | 빈도 |
|--------|------|------|
| `/setup` | 초기 세팅 (DB, 뷰, 리마인더) | 1회 |
| `/abyss` | 심연 탐색 (정체성 발견) | 1회+ |
| `/daily` | 일일 리포트 (30초) | 매일 |
| `/pulse [daily\|weekly\|monthly]` | 자동 분석 | 주기적 |
| `/review [today\|week\|month]` | 상태 확인 | 수시 |
| `/goals` | 목표 관리 | 수시 |

## 아키텍처

```
1 Brain (Claude) × 2 Modes (PULSE + DIALOGUE) × 3 Notion DBs

Notion: Daily Log · Insights · Goals & Direction
Google Calendar: 시간 계획의 진실 원천
Claude Memory: 정체성 요약 + DB ID + 관찰 지침
```

## 맥락 이어가기

Notion DB가 모든 런타임 상태를 저장합니다.
레포를 클론 후 같은 Notion 워크스페이스에 연결하면
이전 Abyss 대화, 인사이트, 목표, 정체성 프로필을 이어갈 수 있습니다.

상세 설계 맥락: [CONTEXT.md](CONTEXT.md)

## 라이선스
Private / Personal Use
