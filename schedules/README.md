# PULSE 스케줄링 가이드

## Phase 1: 수동 실행 + Calendar 리마인더 (현재)

CronCreate는 7일 만료, RemoteTrigger는 MCP 접근 버그 존재.
Phase 1에서는 사용자가 직접 `/pulse`를 실행하되, Calendar 리마인더로 잊지 않도록 합니다.

### Calendar 리마인더 설정 (/setup 시 자동 생성)
```
gcal_create_event(
  summary: "🔍 /pulse daily 실행",
  start: {dateTime: "2026-04-05T23:30:00", timeZone: "Asia/Seoul"},
  end: {dateTime: "2026-04-05T23:45:00", timeZone: "Asia/Seoul"},
  recurrence: ["RRULE:FREQ=DAILY"],
  reminders: {overrides: [{method: "popup", minutes: 0}]}
)

gcal_create_event(
  summary: "📊 /pulse weekly 실행",
  start: {dateTime: "2026-04-06T21:30:00", timeZone: "Asia/Seoul"},
  end: {dateTime: "2026-04-06T21:45:00", timeZone: "Asia/Seoul"},
  recurrence: ["RRULE:FREQ=WEEKLY;BYDAY=SU"],
  reminders: {overrides: [{method: "popup", minutes: 0}]}
)

gcal_create_event(
  summary: "🧬 /pulse monthly 실행",
  start: {dateTime: "2026-05-01T10:00:00", timeZone: "Asia/Seoul"},
  end: {dateTime: "2026-05-01T10:15:00", timeZone: "Asia/Seoul"},
  recurrence: ["RRULE:FREQ=MONTHLY;BYMONTHDAY=1"],
  reminders: {overrides: [{method: "popup", minutes: 0}]}
)
```

사용자 흐름: 폰 알림 → Claude 열기 → /pulse 입력

### /daily와 /pulse daily 통합 팁
매일 밤 `/daily` 제출 직후 `/pulse daily` 실행하면 한 세션에서 완료.
또는: `/daily` 후 자동으로 `/pulse daily` 실행 여부를 물어보도록 daily 커맨드에 추가 가능.

## Phase 2: RemoteTrigger 전환 (MCP 버그 수정 후)

RemoteTrigger가 MCP 서버(Notion, Calendar)에 접근 가능해지면:

```
RemoteTrigger create:
  name: "pulse-daily"
  schedule: "45 23 * * *"          # 매일 23:45
  prompt: "Read CLAUDE.md. Execute /pulse daily."

RemoteTrigger create:
  name: "pulse-weekly"
  schedule: "30 21 * * 0"          # 매주 일요일 21:30
  prompt: "Read CLAUDE.md. Execute /pulse weekly."

RemoteTrigger create:
  name: "pulse-monthly"
  schedule: "0 10 1 * *"           # 매월 1일 10:00
  prompt: "Read CLAUDE.md. Execute /pulse monthly."
```

장점: PC 꺼도 동작, 사용자 개입 불필요.

## Phase 3: 대안 — OS 스케줄러 (선택)

Windows Task Scheduler:
```
schtasks /create /sc daily /st 23:45 /tn "PULSE Daily" /tr "claude --print -p '/pulse daily'"
```

장점: RemoteTrigger 불안정 시 로컬 대안.
단점: PC 켜져 있어야 함.

## 누락 복구
/pulse는 실행 시 항상 마지막 처리일을 확인하고 누락분을 자동 처리합니다.
2주 안 돌려도 다음 실행 시 캐치업. 상세: pulse-runbook.md 참조.
