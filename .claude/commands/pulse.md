# /pulse — PULSE 분석 실행

$ARGUMENTS: daily | weekly | monthly (기본값: daily)

PULSE = Periodic Unconscious-pattern Logging and Synthesis Engine.
docs/pulse-runbook.md를 읽고 해당 섹션을 실행하세요.

## 실행 전 복구 체크 (항상)
1. notion-search(INSIGHTS_DB, Horizon="Daily", 최근 30일)로 마지막 처리일 확인
2. Gap 계산:
   - Gap ≤ 1일: 정상 진행
   - Gap 2-7일: 누락일 순차 처리 후 오늘 실행
   - Gap 8-30일: daily 스킵, weekly 캐치업
   - Gap > 30일: monthly 요약 직행

## Daily PULSE
→ docs/pulse-runbook.md "Daily" 섹션 실행

## Weekly PULSE
→ docs/pulse-runbook.md "Weekly" 섹션 실행

## Monthly PULSE
→ docs/pulse-runbook.md "Monthly" 섹션 실행

## 에러 처리
Notion MCP 호출 실패 시:
1. 에러를 사용자에게 명확히 보고
2. 자동 재시도하지 않음 (rate limit 악화 방지)
3. "30분 후 다시 /pulse 시도해줘" 제안
4. 부분 데이터 있으면 텍스트로 분석 결과 표시 (데이터 유실 방지)
