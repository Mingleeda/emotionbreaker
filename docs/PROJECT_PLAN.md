# 감정 브레이크 AI 에이전트 프로젝트 설계 및 개발 계획

## 1. 프로젝트 개요

감정 브레이크 AI 에이전트는 사용자가 화, 불안, 서운함, 억울함 등 감정이 올라왔을 때 즉시 사용할 수 있는 웹 서비스다.

사용자는 텍스트 또는 음성으로 현재 상황을 털어놓고, 서비스는 다음 흐름으로 사용자를 돕는다.

1. 현재 감정과 감정 강도를 파악한다.
2. 감정 강도가 높으면 먼저 60초 진정 루틴을 제공한다.
3. 사용자의 상황을 사실, 해석, 감정, 욕구로 분리한다.
4. 상대에게 보낼 말을 차분한 표현으로 바꿔준다.
5. 사용자가 요청한 경우에만 감정 조절에 도움이 되는 자료를 추천한다.
6. 사용자가 원할 경우 감정 세션을 저장한다.

서비스의 핵심은 상담이나 진단이 아니라, 감정이 폭발하기 직전의 순간에 개입해 충동적인 말과 행동을 줄이는 것이다.

## 2. 기술 스택

### Frontend

- Next.js
- React
- TypeScript
- Tailwind CSS

### Backend

- Next.js Route Handlers
- OpenAI API
- Supabase

### Database

- Supabase PostgreSQL

### Auth

- 초기 MVP는 비회원 사용 가능
- 저장 기록 기능 고도화 시 Supabase Auth 적용
- 비회원은 로컬 임시 세션 사용
- 회원은 감정 기록을 Supabase에 저장

### External API

- OpenAI LLM: 감정 분석, 생각 정리, 문장 변환
- OpenAI STT: 음성 텍스트 변환
- 도움 자료 추천은 초기에는 외부 검색 API 없이 사전 큐레이션 DB 기반으로 제공

## 3. 프로젝트 폴더 구조

```text
emotionbreaker/
├─ app/
│  ├─ layout.tsx
│  ├─ page.tsx
│  ├─ globals.css
│  │
│  ├─ start/
│  │  └─ page.tsx
│  ├─ input/
│  │  └─ page.tsx
│  ├─ voice/
│  │  └─ page.tsx
│  ├─ intensity/
│  │  └─ page.tsx
│  ├─ break/
│  │  └─ page.tsx
│  ├─ reassess/
│  │  └─ page.tsx
│  ├─ analysis/
│  │  └─ page.tsx
│  ├─ rewrite/
│  │  └─ page.tsx
│  ├─ resources/
│  │  └─ page.tsx
│  ├─ history/
│  │  ├─ page.tsx
│  │  └─ [sessionId]/
│  │     └─ page.tsx
│  │
│  └─ api/
│     ├─ analyze-emotion/
│     │  └─ route.ts
│     ├─ rewrite-message/
│     │  └─ route.ts
│     ├─ transcribe/
│     │  └─ route.ts
│     ├─ resources/
│     │  └─ route.ts
│     └─ sessions/
│        ├─ route.ts
│        └─ [sessionId]/
│           └─ route.ts
│
├─ components/
│  ├─ layout/
│  │  ├─ AppShell.tsx
│  │  └─ BottomActionBar.tsx
│  ├─ emotion/
│  │  ├─ EmotionQuickSelect.tsx
│  │  ├─ EmotionIntensityPicker.tsx
│  │  ├─ EmotionScoreSummary.tsx
│  │  └─ RiskNotice.tsx
│  ├─ input/
│  │  ├─ TextSituationForm.tsx
│  │  ├─ VoiceRecorder.tsx
│  │  └─ TranscriptionEditor.tsx
│  ├─ break/
│  │  ├─ BreakRoutine.tsx
│  │  ├─ BreathingTimer.tsx
│  │  └─ RoutineStepCard.tsx
│  ├─ analysis/
│  │  ├─ AnalysisResult.tsx
│  │  ├─ FactInterpretationPanel.tsx
│  │  └─ ActionSuggestion.tsx
│  ├─ rewrite/
│  │  ├─ ToneSelector.tsx
│  │  ├─ SuggestedMessageList.tsx
│  │  └─ CopyMessageButton.tsx
│  ├─ resources/
│  │  ├─ ResourceTypePicker.tsx
│  │  └─ ResourceCard.tsx
│  └─ sessions/
│     ├─ SaveSessionButton.tsx
│     ├─ SessionList.tsx
│     └─ DeleteSessionButton.tsx
│
├─ lib/
│  ├─ openai/
│  │  ├─ client.ts
│  │  ├─ prompts.ts
│  │  └─ schemas.ts
│  ├─ supabase/
│  │  ├─ client.ts
│  │  ├─ server.ts
│  │  └─ admin.ts
│  ├─ session/
│  │  ├─ flow-store.ts
│  │  └─ local-session.ts
│  ├─ safety/
│  │  └─ risk-detection.ts
│  ├─ constants/
│  │  ├─ emotions.ts
│  │  ├─ tones.ts
│  │  └─ resources.ts
│  └─ utils.ts
│
├─ types/
│  ├─ emotion.ts
│  ├─ session.ts
│  ├─ resource.ts
│  └─ api.ts
│
├─ supabase/
│  ├─ migrations/
│  └─ seed.sql
│
├─ public/
├─ docs/
│  └─ PROJECT_PLAN.md
├─ .env.local.example
├─ tailwind.config.ts
├─ tsconfig.json
└─ package.json
```

## 4. 라우팅 구조

| Route | 역할 |
| --- | --- |
| `/` | 홈 화면 |
| `/start` | 감정 빠른 선택 |
| `/input` | 텍스트 입력 |
| `/voice` | 음성 녹음 및 STT 결과 수정 |
| `/intensity` | 감정 강도 선택 |
| `/break` | 60초 감정 브레이크 루틴 |
| `/reassess` | 감정 재평가 |
| `/analysis` | AI 감정 분석 결과 |
| `/rewrite` | 상대에게 보낼 문장 추천 |
| `/resources` | 요청 시 도움 자료 추천 |
| `/history` | 저장된 감정 세션 목록 |
| `/history/[sessionId]` | 감정 세션 상세 |

## 5. 사용자 플로우

```text
홈 화면
↓
빠른 감정 선택
↓
텍스트 입력 또는 음성 입력
↓
감정 강도 0~10점 선택
↓
감정 강도 기반 분기

0~3점: 생각 정리 모드
4~6점: 짧은 안정 루틴 후 생각 정리
7~10점: 60초 감정 브레이크 모드 우선 실행

↓
감정 재평가
↓
AI 감정 분석
↓
사실 / 해석 / 감정 / 욕구 분리
↓
대응 문장 추천
↓
도움 자료 추천 여부 확인
↓
사용자가 요청하면 자료 추천
↓
저장 여부 선택
```

## 6. 플로우 상태 모델

초기 MVP에서는 진행 중 데이터를 `client state`와 `localStorage`로 관리한다. 사용자가 명시적으로 저장을 선택할 때만 Supabase에 저장한다.

```ts
type EmotionFlowState = {
  inputType: "text" | "voice";
  selectedEmotion?: "anger" | "anxiety" | "hurt" | "injustice" | "pause";
  originalText: string;
  sttText?: string;
  emotionScoreBefore?: number;
  emotionScoreAfter?: number;
  analysis?: EmotionAnalysisResult;
  rewrittenMessages?: SuggestedMessages;
  requestedResourceType?: ResourceType;
};
```

## 7. 주요 컴포넌트

| Component | 역할 |
| --- | --- |
| `AppShell` | 전체 앱 레이아웃 |
| `BottomActionBar` | 주요 CTA 고정 영역 |
| `EmotionQuickSelect` | 홈/시작 화면의 빠른 감정 선택 |
| `TextSituationForm` | 사용자 상황 텍스트 입력 |
| `VoiceRecorder` | 브라우저 음성 녹음 |
| `TranscriptionEditor` | STT 결과 확인 및 수정 |
| `EmotionIntensityPicker` | 0~10 감정 점수 선택 |
| `EmotionScoreSummary` | 전후 감정 점수 요약 |
| `BreakRoutine` | 60초 감정 브레이크 컨테이너 |
| `BreathingTimer` | 60초 타이머 및 호흡 안내 |
| `RoutineStepCard` | 루틴 단계 표시 |
| `AnalysisResult` | AI 감정 분석 결과 표시 |
| `FactInterpretationPanel` | 사실/해석/감정/욕구 분리 표시 |
| `ActionSuggestion` | 추천 행동 및 비추천 행동 표시 |
| `ToneSelector` | 문장 톤 선택 |
| `SuggestedMessageList` | 추천 문장 목록 |
| `CopyMessageButton` | 추천 문장 복사 |
| `ResourceTypePicker` | 도움 자료 유형 선택 |
| `ResourceCard` | 추천 자료 카드 |
| `SaveSessionButton` | 감정 세션 저장 |
| `SessionList` | 저장된 세션 목록 |
| `DeleteSessionButton` | 감정 세션 삭제 |
| `RiskNotice` | 위기 상황 안내 |

## 8. API Route 목록

### `POST /api/analyze-emotion`

사용자 입력을 분석한다.

- 감정 유형 분류
- 감정 강도 반영
- 사실 / 해석 / 감정 / 욕구 분리
- 위험 표현 감지
- `riskLevel` 반환
- `crisis`면 일반 분석 대신 위기 안내 반환

### `POST /api/rewrite-message`

상대에게 보낼 문장을 차분한 표현으로 변환한다.

- 기본 톤: `soft`, `firm`, `short`
- 추가 톤: `polite`, `warm`, `work`, `family`

### `POST /api/transcribe`

음성 파일을 받아 STT로 변환한다.

- Request: `multipart/form-data`
- Response: `{ text: string }`

### `GET /api/resources`

사용자가 요청한 경우에만 도움 자료를 추천한다.

- Query: `emotion`, `situation`, `type`
- 큐레이션된 DB 자료만 반환

### `POST /api/sessions`

감정 세션을 저장한다.

### `GET /api/sessions`

사용자의 감정 기록 목록을 조회한다.

### `GET /api/sessions/[sessionId]`

특정 감정 세션 상세를 조회한다.

### `DELETE /api/sessions/[sessionId]`

특정 감정 세션을 삭제한다.

### `POST /api/sessions/[sessionId]/resources`

추천 자료 노출, 클릭, 저장, 피드백 로그를 기록한다.

## 9. Supabase 테이블 설계

### `emotion_sessions`

| Column | Type | Description |
| --- | --- | --- |
| `id` | `uuid` | 세션 ID |
| `user_id` | `uuid nullable` | Supabase Auth 사용자 ID |
| `anonymous_id` | `text nullable` | 비회원 로컬 사용자 식별자 |
| `input_type` | `text` | `text` / `voice` |
| `selected_emotion` | `text nullable` | 빠른 감정 선택값 |
| `original_text` | `text` | 사용자 원문 |
| `stt_text` | `text nullable` | STT 변환 텍스트 |
| `emotion_score_before` | `integer` | 최초 감정 점수 |
| `emotion_score_after` | `integer nullable` | 진정 후 감정 점수 |
| `primary_emotion` | `text nullable` | 대표 감정 |
| `secondary_emotions` | `jsonb` | 보조 감정 목록 |
| `situation_summary` | `text nullable` | 상황 요약 |
| `fact` | `text nullable` | 사실 |
| `interpretation` | `text nullable` | 해석 |
| `desire` | `text nullable` | 욕구 |
| `not_recommended_action` | `text nullable` | 하지 않는 게 좋은 행동 |
| `recommended_action` | `text nullable` | 추천 행동 |
| `risk_level` | `text` | `normal` / `caution` / `crisis` |
| `created_at` | `timestamptz` | 생성일 |
| `updated_at` | `timestamptz` | 수정일 |

### `suggested_responses`

| Column | Type | Description |
| --- | --- | --- |
| `id` | `uuid` | 추천 문장 ID |
| `session_id` | `uuid` | 감정 세션 ID |
| `tone` | `text` | `soft` / `firm` / `short` / `polite` / `warm` |
| `response_text` | `text` | 추천 문장 |
| `copied` | `boolean` | 복사 여부 |
| `created_at` | `timestamptz` | 생성일 |

### `resource_recommendations`

| Column | Type | Description |
| --- | --- | --- |
| `id` | `uuid` | 자료 ID |
| `title` | `text` | 자료 제목 |
| `type` | `text` | `video` / `book` / `meditation` / `article` / `exercise` |
| `emotion_tags` | `jsonb` | 감정 태그 |
| `situation_tags` | `jsonb` | 상황 태그 |
| `duration_minutes` | `integer nullable` | 예상 소요 시간 |
| `url` | `text nullable` | 외부 링크 |
| `description` | `text nullable` | 자료 설명 |
| `reason` | `text nullable` | 추천 이유 |
| `source` | `text nullable` | 출처 |
| `is_curated` | `boolean` | 큐레이션 여부 |
| `is_active` | `boolean` | 노출 여부 |
| `created_at` | `timestamptz` | 생성일 |

### `session_resource_logs`

| Column | Type | Description |
| --- | --- | --- |
| `id` | `uuid` | 로그 ID |
| `session_id` | `uuid` | 감정 세션 ID |
| `resource_id` | `uuid nullable` | 추천 자료 ID |
| `requested_type` | `text nullable` | 사용자가 요청한 자료 유형 |
| `clicked` | `boolean` | 클릭 여부 |
| `saved` | `boolean` | 저장 여부 |
| `feedback` | `text nullable` | `helpful` / `not_helpful` |
| `created_at` | `timestamptz` | 생성일 |

### `profiles`

Auth 적용 시 추가한다.

| Column | Type | Description |
| --- | --- | --- |
| `id` | `uuid` | `auth.users.id` 참조 |
| `display_name` | `text nullable` | 표시 이름 |
| `created_at` | `timestamptz` | 생성일 |

## 10. 위험 표현 처리 정책

위험 표현 감지는 `/api/analyze-emotion`에서 최우선으로 처리한다.

위험 유형:

- 자해 위험
- 타해 위험
- 즉각적 위험

`riskLevel`이 `crisis`인 경우:

1. 일반 감정 분석 결과를 제공하지 않는다.
2. 문장 추천 화면으로 이동하지 않는다.
3. 즉시 도움 요청 안내를 보여준다.

기본 안내 문구:

```text
지금은 혼자 버티기보다 즉시 도움을 받는 게 중요해 보여요.
가까운 사람에게 바로 연락하거나, 긴급 상황이라면 112 또는 119에 연락해 주세요.
```

## 11. UX 원칙

이 서비스는 감정이 격해진 사용자가 쓰는 서비스이므로 모든 화면은 아래 원칙을 따른다.

1. 문장은 짧게 쓴다.
2. 버튼은 크게 만든다.
3. 선택지는 너무 많이 주지 않는다.
4. 사용자를 판단하지 않는다.
5. 훈계하지 않는다.
6. 분석보다 진정을 먼저 둔다.
7. 사용자가 바로 보낼 문장을 실수하지 않게 돕는다.
8. 도움 자료는 요청 시에만 보여준다.
9. 저장은 사용자의 명시적 선택으로만 한다.
10. 민감한 감정 기록은 언제든 삭제할 수 있어야 한다.

## 12. 개발 계획

### Phase 1. 프로젝트 세팅

- Next.js 프로젝트 생성
- TypeScript 적용
- Tailwind CSS 적용
- ESLint 및 기본 포맷팅 설정
- `.env.local.example` 작성
- 기본 App Router 구조 생성

완료 기준:

- 로컬 개발 서버 실행 가능
- `/` 기본 페이지 접근 가능
- Tailwind 스타일 적용 확인

### Phase 2. 기본 화면 플로우 구현

- 홈 화면 구현
- 텍스트 입력 화면 구현
- 감정 온도계 화면 구현
- 60초 감정 브레이크 화면 구현
- 감정 재평가 화면 구현
- 분석 결과 목업 화면 구현
- 문장 추천 목업 화면 구현
- 도움 자료 요청 화면 구현

완료 기준:

- AI와 DB 없이도 전체 사용자 플로우 이동 가능
- 감정 점수 7점 이상이면 `/break`로 분기
- 도움 자료는 사용자가 요청한 경우에만 화면 전환

### Phase 3. 클라이언트 상태 관리

- `EmotionFlowState` 타입 정의
- localStorage 기반 임시 플로우 저장소 구현
- 새로고침 시 진행 중 데이터 복원
- 플로우 초기화 기능 구현

완료 기준:

- 사용자가 입력한 텍스트와 감정 점수가 화면 간 유지됨
- 분석 완료 후 저장 또는 초기화 가능

### Phase 4. AI 분석 API 연동

- OpenAI 클라이언트 구성
- 감정 분석 프롬프트 작성
- JSON 응답 스키마 정의
- `/api/analyze-emotion` 구현
- 위험 표현 1차 로컬 감지 구현
- `crisis` 응답 UI 연결

완료 기준:

- 실제 사용자 입력으로 감정 분석 결과 생성
- 사실 / 해석 / 감정 / 욕구가 분리되어 표시됨
- 위기 표현 입력 시 일반 코칭 중단

### Phase 5. 문장 변환 API 연동

- 문장 변환 프롬프트 작성
- `/api/rewrite-message` 구현
- 기본 3가지 톤 응답 연결
- 추가 톤 요청 기능 구현
- 복사 버튼 구현

완료 기준:

- 원문 메시지가 부드럽게 / 단호하게 / 짧게 변환됨
- 추천 문장을 클립보드에 복사 가능

### Phase 6. Supabase 연동

- Supabase 클라이언트 구성
- DB migration 작성
- `emotion_sessions` 저장 구현
- `suggested_responses` 저장 구현
- 저장 기록 목록 조회 구현
- 저장 기록 상세 조회 구현
- 저장 기록 삭제 구현

완료 기준:

- 사용자가 명시적으로 저장한 세션만 DB에 저장됨
- 저장된 세션을 목록에서 확인 가능
- 세션 삭제 가능

### Phase 7. 도움 자료 추천

- `resource_recommendations` seed 데이터 작성
- `/api/resources` 구현
- 감정, 상황, 자료 유형 기준 필터링
- `session_resource_logs` 기록 구현

완료 기준:

- 사용자가 요청한 자료 유형만 추천됨
- 초기 추천은 큐레이션 DB 데이터에서만 제공됨

### Phase 8. STT 기능

- 브라우저 음성 녹음 구현
- 최대 3분 녹음 제한
- `/api/transcribe` 구현
- OpenAI STT 연동
- STT 결과 수정 화면 구현

완료 기준:

- 사용자가 음성으로 입력 가능
- 변환된 텍스트를 수정한 뒤 분석 가능

### Phase 9. 품질 점검 및 MVP 마감

- 주요 플로우 수동 테스트
- 모바일 화면 점검
- 위험 표현 테스트
- API 키 프론트 노출 여부 점검
- 저장/삭제 테스트
- 빈 상태 및 오류 상태 UI 보강

완료 기준:

- MVP 완료 기준 10개 항목 충족
- 로컬에서 전체 플로우 재현 가능
- 배포 전 환경변수 목록 정리 완료

## 13. 우선순위

### P0

- Next.js 프로젝트 세팅
- 텍스트 기반 전체 플로우
- 감정 강도 분기
- 60초 브레이크 루틴
- AI 감정 분석
- 문장 변환
- 위험 표현 대응

### P1

- Supabase 세션 저장/삭제
- 큐레이션 자료 추천
- 저장 기록 조회

### P2

- 음성 녹음
- STT
- Supabase Auth
- 추천 자료 로그 및 피드백

## 14. 다음 작업 제안

다음 단계에서는 Phase 1부터 시작한다.

작업 범위:

1. Next.js + TypeScript + Tailwind 프로젝트 생성
2. 기본 폴더 구조 생성
3. `.env.local.example` 작성
4. 홈 화면의 최소 UI 구현
5. 로컬 개발 서버 실행 확인
