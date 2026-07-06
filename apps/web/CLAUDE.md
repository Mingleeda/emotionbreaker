# Web App Guide

## 앱 구조

이 웹 앱은 Next.js App Router 기반으로 구현한다.

권장 구조:

```text
apps/web/
├─ app/
│  ├─ layout.tsx
│  ├─ page.tsx
│  ├─ globals.css
│  ├─ start/page.tsx
│  ├─ input/page.tsx
│  ├─ voice/page.tsx
│  ├─ intensity/page.tsx
│  ├─ break/page.tsx
│  ├─ reassess/page.tsx
│  ├─ analysis/page.tsx
│  ├─ rewrite/page.tsx
│  ├─ resources/page.tsx
│  ├─ history/page.tsx
│  ├─ history/[sessionId]/page.tsx
│  └─ api/
├─ components/
├─ lib/
├─ types/
└─ public/
```

## 페이지 라우트

| Route | 역할 |
| --- | --- |
| `/` | 홈 |
| `/start` | 빠른 감정 선택 |
| `/input` | 텍스트 입력 |
| `/voice` | 음성 녹음 |
| `/intensity` | 감정 강도 선택 |
| `/break` | 60초 감정 브레이크 |
| `/reassess` | 감정 재평가 |
| `/analysis` | 분석 결과 |
| `/rewrite` | 문장 추천 |
| `/resources` | 도움 자료 |
| `/history` | 기록 목록 |
| `/history/[sessionId]` | 기록 상세 |

## API Routes

| Method | Route | 역할 |
| --- | --- | --- |
| `POST` | `/api/analyze-emotion` | 감정 분석 |
| `POST` | `/api/rewrite-message` | 문장 변환 |
| `POST` | `/api/transcribe` | STT |
| `GET` | `/api/resources` | 추천 자료 조회 |
| `POST` | `/api/sessions` | 세션 저장 |
| `GET` | `/api/sessions` | 세션 목록 조회 |
| `GET` | `/api/sessions/[sessionId]` | 세션 상세 조회 |
| `DELETE` | `/api/sessions/[sessionId]` | 세션 삭제 |
| `POST` | `/api/sessions/[sessionId]/resources` | 자료 로그 기록 |

## 개발 규칙

- API 키는 서버 코드에서만 사용한다.
- `OPENAI_API_KEY`는 클라이언트 번들에 노출하지 않는다.
- `SUPABASE_SERVICE_ROLE_KEY`는 Route Handler에서만 사용한다.
- 초기 플로우 상태는 localStorage로 관리한다.
- 세션 저장은 사용자의 명시적 선택이 있을 때만 수행한다.
- 위험 표현이 감지되면 일반 분석과 문장 추천을 중단한다.
- 도움 자료는 사용자가 요청한 경우에만 조회한다.
- 모바일 우선으로 화면을 설계한다.
- 문장은 짧게 쓰고 CTA는 크게 만든다.

## 주요 컴포넌트

- `AppShell`
- `BottomActionBar`
- `EmotionQuickSelect`
- `TextSituationForm`
- `VoiceRecorder`
- `TranscriptionEditor`
- `EmotionIntensityPicker`
- `BreakRoutine`
- `BreathingTimer`
- `AnalysisResult`
- `ToneSelector`
- `SuggestedMessageList`
- `ResourceTypePicker`
- `ResourceCard`
- `SaveSessionButton`
- `SessionList`
- `DeleteSessionButton`
- `RiskNotice`

## UI 원칙

1. 사용자가 감정적으로 격해진 상태라고 가정한다.
2. 화면당 주요 행동은 1개로 제한한다.
3. 설명보다 행동을 우선한다.
4. 사용자를 판단하지 않는다.
5. 자동 저장하지 않는다.
6. 도움 자료를 강제로 보여주지 않는다.
7. 위기 상황에서는 일반 UX보다 안전 안내를 우선한다.
