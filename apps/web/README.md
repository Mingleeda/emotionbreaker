# 보내기 전 60초 웹 앱

Next.js, TypeScript, Tailwind CSS 기반의 AI 감정 브레이크 웹 앱입니다.

보내기 전 60초는 화가 치밀거나 말이 세게 나올 것 같을 때, 먼저 60초 멈추고 상대에게 보낼 말을 차분하게 바꾸는 서비스입니다.

## 개발 실행

```bash
npm run dev
```

기본 개발 서버 주소는 [http://localhost:3000](http://localhost:3000)입니다.

## 환경변수

`.env.local.example`을 기준으로 로컬 환경변수를 설정합니다.

```env
OPENAI_API_KEY=
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
```

## 현재 상태

- Phase 1 프로젝트 세팅
- 기본 라우트 뼈대
- 홈 화면 최소 UI
- API Route 자리 구성
- 브라우저 음성 녹음 및 OpenAI STT API 연결
- PWA manifest, iOS 홈 화면 아이콘, service worker 등록

## iPhone 홈 화면 추가

1. iPhone Safari에서 서비스 URL을 엽니다.
2. 공유 버튼을 누릅니다.
3. `홈 화면에 추가`를 선택합니다.
4. 이름이 `보내기 전 60초`로 표시되는지 확인합니다.

현재 PWA는 홈 화면 앱처럼 실행되도록 manifest, 아이콘, iOS 메타 태그를 포함합니다.

## STT 실행 조건

음성 입력 기능은 브라우저 마이크 권한과 `OPENAI_API_KEY`가 필요합니다.

1. `.env.local.example`을 참고해 `.env.local`을 만듭니다.
2. `OPENAI_API_KEY`를 설정합니다.
3. 개발 서버를 다시 시작합니다.
4. `/voice`에서 녹음 후 `텍스트로 바꾸기`를 누릅니다.

AI 감정 분석과 Supabase 저장 기능은 다음 Phase에서 순차적으로 연결합니다.
