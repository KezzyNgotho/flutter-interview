# Papers App – Appcentric Africa Interview

A full-stack demo with Laravel backend (JWT via Sanctum) and Flutter frontend. Features:
- Login and token auth
- Papers list with search and filters (year, subject)
- Paper details with questions and multiple answers
- Offline cache of previously viewed papers
- Studied bookmark toggle (persisted)

## Tech
- Backend: Laravel 12, Sanctum, SQLite
- Frontend: Flutter 3, Dio, Provider, Hive, Secure Storage

---

## 1) Local Setup

### Prerequisites
- Flutter SDK 3.x
- PHP 8.2+, Composer

### Clone/Project Layout
```
flutter Interview/
  ├─ backend/        # Laravel API
  └─ papers_app/     # Flutter app
```

---

## 2) Backend (Laravel)

From `backend/`:

1. Install deps and ensure .env and SQLite are ready (done by create-project):
```
composer install
php artisan key:generate
```

2. Run migrations and seed demo data (creates demo user and sample papers/questions/answers):
```
php artisan migrate:fresh --seed
```

3. Serve API:
```
php artisan serve --host=127.0.0.1 --port=8000
```

### Routes
- POST `/api/login` → `{ token }` (demo@example.com / password)
- GET `/api/subjects`
- GET `/api/papers?subject_id=&year=&q=` (paginated)
- GET `/api/papers/{id}` (includes `subject`, `questions`, `answers`)

### Rate Limiting
- 100 req/min per user/IP, configured in `AppServiceProvider`.

---

## 3) Frontend (Flutter)

From `papers_app/`:

1. Install packages:
```
flutter pub get
```

2. Run (Web/Windows/macOS):
```
flutter run -d chrome --dart-define=API_BASE=http://127.0.0.1:8000/api
# or
flutter run -d windows  --dart-define=API_BASE=http://127.0.0.1:8000/api
```

3. Login with:
```
Email:    demo@example.com
Password: password
```

### Features
- Search with live filtering; server-side query via `q`
- Year and Subject dropdown filters
- Papers detail with show/hide-all-answers toggle and per-question expand/collapse
- Offline cache: previously viewed papers load from Hive when offline/unavailable (badge shown)
- Studied toggle with green check badge in the list

---

## 4) Testing & QA

### Backend
- Basic sanity checks:
```
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"password"}'
```
- Verify papers:
```
curl -H "Authorization: Bearer <TOKEN>" http://127.0.0.1:8000/api/papers
curl -H "Authorization: Bearer <TOKEN>" http://127.0.0.1:8000/api/papers/1
```

### Frontend
- Start on Chrome and validate:
  - Login success (401 indicates wrong creds)
  - List renders titles and year avatars
  - Filters alter results
  - Detail shows questions and answer options; expand/collapse works
  - Toggle Show Answers (eye icon) reveals all
  - Disconnect API → Previously viewed paper shows offline banner and still loads

---

## 5) Troubleshooting

- 401 on login: ensure credentials; confirm `/api/login` exists (see `bootstrap/app.php` includes `api.php`).
- CORS errors: `backend/config/cors.php` allows `api/*` with `*`. Clear config: `php artisan optimize:clear`.
- Flutter cannot reach API:
  - Ensure `--dart-define=API_BASE=http://127.0.0.1:8000/api`.
  - Use device-appropriate base (Android emulator: `http://10.0.2.2:8000/api`).
- No questions/answers: confirm seeder created answers and `/api/papers/{id}` loads `questions.answers`.

---

## 6) Production Notes (Fast Follow)
- Add JWT refresh/logout endpoints and revocation.
- Proper subjects API (dynamic dropdowns) and pagination UI.
- CI/CD: `flutter test`, format, static analysis; Laravel `phpunit` suite.
- App icon/splash via `flutter_launcher_icons` and `flutter_native_splash`.
- Security: tighten CORS, rate limits, request validation.
