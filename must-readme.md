# must-readme — 보내기 전 60초 고도화 가이드

이 문서는 코드만 봐서는 알 수 없는 것들을 모았다. 제품 정의·화면 규칙은 `CLAUDE.md`와 `docs/`를,
웹 구조는 `apps/web/CLAUDE.md`를 먼저 읽어라. 여기는 그 다음에 필요한 실전 지식이다.

## 1. 전체 그림

```
apps/ios  (SwiftUI, XcodeGen)          apps/web  (Next.js 16, Vercel)
┌───────────────────────────┐          ┌──────────────────────────────┐
│ FlowStore (플로우 상태)     │  HTTPS   │ /api/analyze-emotion         │      ┌────────────┐
│  ├─ LocalCoach (온디바이스) │ ───────► │ /api/rewrite-message         │ ───► │ OpenRouter │
│  └─ RemoteCoach (서버 AI)  │          │  lib/ai/coach.ts (프롬프트)   │      │ gemini-2.5 │
└───────────────────────────┘          └──────────────────────────────┘      └────────────┘
```

- **iOS가 원본**이다. 웹은 현재 API 서버 겸 프로토타입이고, 웹 프론트 플로우는 목업 그대로다
  (`createMockAnalysis`). 웹 화면에 AI를 붙이려면 iOS와 같은 방식으로 라우트만 호출하면 된다.
- **키는 서버에만 있다**: `apps/web/.env.local`(로컬) / Vercel 환경변수(프로덕션)의 `OPENROUTER_API_KEY`.
  iOS 앱에는 어떤 키도 없다. 이 원칙(CLAUDE.md 원칙 8)을 절대 깨지 마라.
- 프로덕션 서버: `https://emotionbreaker-web.vercel.app` (Vercel 프로젝트 `emotionbreaker-web`, 계정 hyub0216-7043).

## 2. AI 코치 동작 방식 (설계 의도)

- **로컬 우선, AI로 업그레이드**: iOS `FlowStore.prepareAnalysis()/prepareMessages()`는
  `LocalCoach`(규칙 기반) 결과를 **즉시** 화면에 놓고, `RemoteCoach`가 성공하면 교체한다.
  감정이 격해진 사용자를 네트워크 대기로 세워두지 않기 위한 의도적 설계다. 유지하라.
- **위기 감지는 항상 로컬 판정이 우선**: `LocalCoach.detectRiskLevel`(iOS)과
  `lib/safety/risk-detection.ts`(웹)가 crisis를 감지하면 **AI 호출 자체를 건너뛴다**(원칙 9).
  서버 응답의 riskLevel도 로컬 판정으로 덮어쓴다.
- 모델 교체는 코드 수정 없이 `OPENROUTER_MODEL` 환경변수로 (기본 `google/gemini-2.5-flash`, 호출당 ~$0.001).
- 응답 형식: 라우트가 `source: "ai" | "local"` 필드를 얹어준다. 디버깅할 때 이걸 봐라.

### 함정 (한 번씩 밟았던 것)
- OpenRouter 헤더 `X-Title`에 **한글을 넣으면 ByteString 오류**로 조용히 실패한다. 헤더는 ASCII만.
- 서버 라우트 실패는 `lib/ai/coach.ts`의 catch에서 `console.error`로 남는다. Vercel 로그에서 확인.
- iOS 시뮬레이터에서 로컬 서버로 테스트하려면 `project.yml`의 `EmotionCoachBaseURL`을
  `http://localhost:3000`으로 바꾸고 `npm run dev` — ATS는 `NSAllowsLocalNetworking`으로 이미 열려 있다.

## 3. iOS 빌드·배포 런북

- **XcodeGen 프로젝트다**. `EmotionBreaker.xcodeproj`는 생성물이라 gitignore됨.
  `apps/ios`에서 `xcodegen generate` 후 열어라. 설정 변경은 반드시 `project.yml`에.
- **버전은 빌드설정에 연결돼 있다**: Info의 `CFBundleVersion = $(CURRENT_PROJECT_VERSION)`.
  이 연결을 끊고 하드코딩하면 재업로드 때 "bundle version must be higher" 에러가 난다(빌드 2에서 실제 발생).
- TestFlight 배포는 이 맥의 `testflight-deploy` 스킬 런북(팀 S9F62N3WJA, ASC 키 FPN58J7V2Q)이 처리:
  아카이브 → 수동 inside-out 서명 → IPA → altool(애플 500 자동 재시도). **빌드번호는 매번 +1**.
- App Store Connect: appId `6787987393`, 스토어명 "보내기전60초". 문구·스크린샷·빌드연결·연령등급은
  전부 ASC API로 넣었다(`~/.claude/skills/ios-release/scripts/asc_api.py` 참고). 심사 제출 취소/재제출도
  `reviewSubmissions` API로 가능하다 — 빌드 교체 시 기존 제출을 cancel해야 연결이 풀린다(409의 원인).

## 4. 마스코트 "두리" 에셋 시스템

- 캐릭터: 느긋한 수달, 1990년대 띠부씰 스타일(굵은 검은 윤곽선 + 셀 채색).
- **그림체를 유지하며 새 포즈를 만들려면**: `apps/ios/Design/mascot/duri-character-anchor.png`를
  참조 이미지로 넣고 nano_banana_pro(higgsfield)로 생성 → `remove_background` → 트리밍 → imageset.
- **AI는 한글 텍스트를 자주 틀린다**("보내ㄱ기" 사건). 워드마크가 필요하면 이미지에는 글자를 빼고
  ImageMagick + `/System/Library/Fonts/AppleSDGothicNeo.ttc`로 합성하라(스플래시가 그렇게 만들어졌다).
- 스플래시는 2단 구성: ① `UILaunchScreen`(정적, LaunchDuri+LaunchBackground) ② 앱 시작 직후 동일한
  `SplashView`가 1.2초 이어받아 페이드아웃(`EmotionBreakerApp.swift`). 런치 스크린만으로는 0.3초 만에
  지나가 버려서 이렇게 했다. **시뮬레이터에서 런치 스크린이 안 바뀌어 보이면 SplashBoard 캐시다** —
  깨끗한 시뮬레이터에 새로 설치해서 확인하라(기기에서는 문제없음).

## 5. 시뮬레이터 자동화 팁 (스크린샷·QA)

- 화면 조작: `idb ui tap/swipe --udid <id> x y`. 좌표는 `idb ui describe-all`의 frame에서.
- **idb는 한글을 못 친다**(HID 키코드 없음). 한글 입력은
  `printf '한글' | xcrun simctl pbcopy <udid>` → 입력창 롱프레스 → Paste 메뉴 탭.
- 스토어 스크린샷은 기기 네이티브 해상도가 필요하다: `xcrun simctl io <udid> screenshot`(6.9" = 1320×2868).
  기존 7장은 `apps/ios/store/screenshots/`, 문구는 `apps/ios/store/app-store-listing.md`.

## 6. 법적 페이지·개인정보

- 공개 URL: `https://skax-hyub.github.io/app-legal-pages/emotionbreaker/{privacy,support}.html`
  (repo `skax-hyub/app-legal-pages`, GitHub Pages legacy 빌드 — 가끔 멈추면
  `gh api -X POST repos/skax-hyub/app-legal-pages/pages/builds`로 재빌드).
- privacy.html은 이 앱의 실제 데이터 흐름을 서술한다: **기기 내 저장, AI 분석용 일시 전송(서버 미보관),
  마이크는 변환에만**. 데이터 흐름을 바꾸면(예: 서버 저장 도입) 이 문서와 App Privacy 설문을 같이 바꿔야 한다.

## 7. 다음 고도화 후보 (우선순위 제안)

1. **Supabase 세션 동기화**(docs/DATA_MODEL.md에 스키마 설계 있음) — 지금은 UserDefaults뿐이라 기기 바꾸면 소실.
2. **웹 프론트에 실제 AI 연결** — 라우트는 이미 살아 있고 프론트만 목업.
3. **브레이크 화면 호흡 애니메이션** — 두리 4초 확대·6초 축소(호흡 리듬과 동기화).
4. **STT 개선** — 현재 iOS 온디바이스 음성인식만. 웹 `/api/transcribe`는 목업.
5. OpenRouter 키 로테이션 — 키가 개발 중 채팅에 노출된 적 있어 여유 있을 때 재발급 권장.
