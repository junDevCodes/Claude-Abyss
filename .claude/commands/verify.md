# /verify — 시스템 자동 검증

모든 컴포넌트를 자동으로 테스트하고, 결과를 Notion "System Status" 페이지에 기록.
사용자는 Notion 앱에서 이 페이지만 확인하면 됨.

## 실행 시점
- /setup 완료 직후 자동 실행
- 사용자가 수동으로 /verify 실행
- 문제 의심 시 디버깅용

## Step 1: MCP 연결 확인

```
Test 1: Notion 연결
  notion-search(query="test", filters={}, page_size=1)
  → 응답 있음 = ✅, 에러 = ❌

Test 2: Notion 쓰기
  notion-fetch(id=SYSTEM_CONFIG_PAGE_ID)
  → 접근 가능 = ✅, 에러 = ❌

Test 3: Calendar 연결
  gcal_list_calendars()
  → 캘린더 목록 반환 = ✅, 에러 = ❌

Test 4: Calendar 읽기
  gcal_list_events(calendarId="primary", timeMin=오늘, timeMax=오늘)
  → 응답 = ✅, 에러 = ❌
```

## Step 2: DB 구조 확인

```
Test 5: Daily Log DB
  notion-fetch(id=DAILY_LOG_DB_ID)
  → 스키마에 Name, Date, Meals, Activities, Exercise, Gaming,
    Sleep Time, Mood, Energy, Approached, Avoided, Source 존재 확인
  → 전부 있음 = ✅, 누락 = ⚠️ (누락 필드 명시)

Test 6: Insights DB
  notion-fetch(id=INSIGHTS_DB_ID)
  → Type, Horizon, Content, Confidence, Status, Tags 존재 확인
  → Evidence relation → Daily Log 연결 확인

Test 7: Goals DB
  notion-fetch(id=GOALS_DB_ID)
  → Title, Type, Status, Why, Connected Insights relation 확인

Test 8: Identity Profile
  notion-fetch(id=IDENTITY_PROFILE_PAGE_ID)
  → 페이지 접근 가능 + 5개 섹션 존재
```

## Step 3: 기능 테스트

```
Test 9: Daily Log 쓰기
  notion-create-pages(DAILY_LOG_DS, [{
    "Name": "VERIFY-TEST",
    "date:Date:start": "2000-01-01",
    "Source": "Auto"
  }])
  → 생성 성공 = ✅
  → 생성된 page_id 기록 (정리용)

Test 10: Daily Log 검색
  notion-search(query="VERIFY-TEST", data_source_url=DAILY_LOG_DS)
  → 방금 만든 엔트리 찾음 = ✅

Test 11: Daily Log 수정
  notion-update-page(page_id=Test9결과, command="update_properties",
    properties={"Mood": 5})
  → 수정 성공 = ✅

Test 12: Calendar 이벤트 읽기 (기존)
  gcal_list_events(오늘) → 이벤트 수 확인
  → 반환 = ✅ (이벤트 N개)

Test 13: 테스트 데이터 정리
  notion-update-page(Test9 page, "update_properties",
    properties={"Name": "VERIFY-TEST-CLEANED"})
  → (완전 삭제 불가하므로 이름 변경으로 표시)
```

## Step 4: Notion "System Status" 페이지에 결과 기록

```
notion-search(query="Life Hack System Status")
→ 있으면 업데이트, 없으면 생성

notion-update-page 또는 notion-create-pages:
  title: "Life Hack System Status"
  content:
    "# System Status
    Last Verified: YYYY-MM-DD HH:MM

    ## MCP 연결
    | 테스트 | 결과 |
    |--------|------|
    | Notion 연결 | ✅ |
    | Notion 쓰기 | ✅ |
    | Calendar 연결 | ✅ |
    | Calendar 읽기 | ✅ |

    ## DB 구조
    | 테스트 | 결과 |
    |--------|------|
    | Daily Log 스키마 | ✅ (13개 필드) |
    | Insights 스키마 | ✅ (10개 필드) |
    | Goals 스키마 | ✅ (9개 필드) |
    | Identity Profile | ✅ |

    ## 기능
    | 테스트 | 결과 |
    |--------|------|
    | Daily Log 쓰기 | ✅ |
    | Daily Log 검색 | ✅ |
    | Daily Log 수정 | ✅ |
    | Calendar 읽기 | ✅ (N개 이벤트) |

    ## 종합: 13/13 통과 ✅
    
    ## 운영 현황 (자동 업데이트)
    | 항목 | 값 |
    |------|-----|
    | 마지막 /daily | (미실행) |
    | 마지막 /pulse | (미실행) |
    | Daily Log 총 엔트리 | 0 |
    | Insights 총 엔트리 | 0 |
    | 현재 스트릭 | 0일 |
    | Abyss 상태 | 미실행 |
    "
```

## Step 5: 사용자에게 결과 안내

```
"검증 완료. Notion 'System Status' 페이지에서 결과 확인 가능.
 총 13/13 통과. (또는 N개 실패 — 실패 항목 표시)"
```

---

## /daily, /pulse 등 실행 시 자동 업데이트

각 커맨드 실행 성공 시 System Status 페이지의 "운영 현황" 섹션 자동 업데이트:

```
/daily 성공 후:
  → "마지막 /daily: YYYY-MM-DD HH:MM ✅"
  → "Daily Log 총 엔트리: N"
  → "현재 스트릭: N일"

/pulse 성공 후:
  → "마지막 /pulse [daily|weekly|monthly]: YYYY-MM-DD ✅"
  → "Insights 총 엔트리: N"

/abyss 완료 후:
  → "Abyss 상태: 완료 (YYYY-MM-DD)"

에러 발생 시:
  → "마지막 /daily: YYYY-MM-DD ❌ (에러: Notion API timeout)"
```
