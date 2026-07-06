# Data Model

## Enum 설계

### `input_type`

- `text`
- `voice`

### `selected_emotion`

- `anger`
- `anxiety`
- `hurt`
- `injustice`
- `pause`

### `risk_level`

- `normal`
- `caution`
- `crisis`

### `response_tone`

- `soft`
- `firm`
- `short`
- `polite`
- `warm`
- `work`
- `family`

### `resource_type`

- `video`
- `meditation`
- `book`
- `article`
- `exercise`

### `resource_feedback`

- `helpful`
- `not_helpful`

## Tables

### `profiles`

Supabase Auth 적용 시 사용한다.

| Column | Type | Constraint |
| --- | --- | --- |
| `id` | `uuid` | primary key, references `auth.users(id)` |
| `display_name` | `text` | nullable |
| `created_at` | `timestamptz` | default `now()` |

### `emotion_sessions`

| Column | Type | Constraint |
| --- | --- | --- |
| `id` | `uuid` | primary key, default `gen_random_uuid()` |
| `user_id` | `uuid` | nullable, references `auth.users(id)` |
| `anonymous_id` | `text` | nullable |
| `input_type` | `text` | not null |
| `selected_emotion` | `text` | nullable |
| `original_text` | `text` | not null |
| `stt_text` | `text` | nullable |
| `emotion_score_before` | `integer` | not null, check 0~10 |
| `emotion_score_after` | `integer` | nullable, check 0~10 |
| `primary_emotion` | `text` | nullable |
| `secondary_emotions` | `jsonb` | default `'[]'::jsonb` |
| `situation_summary` | `text` | nullable |
| `fact` | `text` | nullable |
| `interpretation` | `text` | nullable |
| `desire` | `text` | nullable |
| `not_recommended_action` | `text` | nullable |
| `recommended_action` | `text` | nullable |
| `risk_level` | `text` | default `'normal'` |
| `created_at` | `timestamptz` | default `now()` |
| `updated_at` | `timestamptz` | default `now()` |

### `suggested_responses`

| Column | Type | Constraint |
| --- | --- | --- |
| `id` | `uuid` | primary key, default `gen_random_uuid()` |
| `session_id` | `uuid` | references `emotion_sessions(id)` on delete cascade |
| `tone` | `text` | not null |
| `response_text` | `text` | not null |
| `copied` | `boolean` | default `false` |
| `created_at` | `timestamptz` | default `now()` |

### `resource_recommendations`

| Column | Type | Constraint |
| --- | --- | --- |
| `id` | `uuid` | primary key, default `gen_random_uuid()` |
| `title` | `text` | not null |
| `type` | `text` | not null |
| `emotion_tags` | `jsonb` | default `'[]'::jsonb` |
| `situation_tags` | `jsonb` | default `'[]'::jsonb` |
| `duration_minutes` | `integer` | nullable |
| `url` | `text` | nullable |
| `description` | `text` | nullable |
| `reason` | `text` | nullable |
| `source` | `text` | nullable |
| `is_curated` | `boolean` | default `true` |
| `is_active` | `boolean` | default `true` |
| `created_at` | `timestamptz` | default `now()` |

### `session_resource_logs`

| Column | Type | Constraint |
| --- | --- | --- |
| `id` | `uuid` | primary key, default `gen_random_uuid()` |
| `session_id` | `uuid` | references `emotion_sessions(id)` on delete cascade |
| `resource_id` | `uuid` | nullable, references `resource_recommendations(id)` on delete set null |
| `requested_type` | `text` | nullable |
| `clicked` | `boolean` | default `false` |
| `saved` | `boolean` | default `false` |
| `feedback` | `text` | nullable |
| `created_at` | `timestamptz` | default `now()` |

## 인덱스 설계

```sql
create index emotion_sessions_user_id_created_at_idx
  on emotion_sessions (user_id, created_at desc);

create index emotion_sessions_anonymous_id_created_at_idx
  on emotion_sessions (anonymous_id, created_at desc);

create index emotion_sessions_risk_level_idx
  on emotion_sessions (risk_level);

create index suggested_responses_session_id_idx
  on suggested_responses (session_id);

create index resource_recommendations_type_idx
  on resource_recommendations (type);

create index resource_recommendations_active_idx
  on resource_recommendations (is_active);

create index session_resource_logs_session_id_idx
  on session_resource_logs (session_id);
```

## RLS 방향

초기 MVP에서 비회원 저장을 허용할 경우, 서버 Route Handler에서 `SUPABASE_SERVICE_ROLE_KEY`로 저장과 조회를 제어한다.

Auth 적용 후:

- 사용자는 자신의 `emotion_sessions`만 조회할 수 있다.
- 사용자는 자신의 `emotion_sessions`만 삭제할 수 있다.
- `resource_recommendations`는 읽기만 허용한다.
- `session_resource_logs`는 자신의 세션에 연결된 로그만 생성할 수 있다.

## Migration 작성 원칙

- 모든 테이블은 `created_at`을 가진다.
- 수정 가능한 주요 테이블은 `updated_at`을 가진다.
- 감정 점수는 0~10 check constraint를 둔다.
- 민감 데이터 삭제를 위해 세션 하위 데이터는 cascade를 기본으로 한다.
- 추천 자료 원본은 세션 삭제와 무관하게 유지한다.
