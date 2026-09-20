# Vanep Mobile

Vanep Flutter mobile application.

---

## Requirements

- Flutter (pinned via `.fvmrc`)
- FVM (Flutter Version Manager)
- Android SDK + Android Studio (for Android)

---

## How to install

### Install fvm

```bash
dart pub global activate fvm
fvm install
```

`fvm install` uses the Flutter version pinned in `.fvmrc`.

---

### Setup the application

```bash
make install
```

### Configure environment (`.env`)

The app reads its OAuth configuration from a `.env` file (loaded at runtime by
`flutter_dotenv`). It is **git-ignored** — create it from the template:

```bash
cp .env.example .env
```

| Variable | Description |
| --- | --- |
| `AUTH_URL` | Base URL of the Vanep backend (Spring Authorization Server), **without** `/api`. Android emulator: `http://10.0.2.2:8080` (host's `localhost`). Physical device: your machine's LAN IP (e.g. `http://192.168.0.10:8080`). |
| `OAUTH_CLIENT_ID` | Public OAuth client id (no secret). Must match `VANEP_OAUTH_MOBILE_CLIENT_ID` in `vanep-api-java`. Default: `vanep-mobile`. |
| `GOOGLE_SERVER_CLIENT_ID` | Google **Web** client ID used as `serverClientId` by native Google sign-in. Must be the same value as `GOOGLE_CLIENT_ID` in `vanep-api-java`; the Android OAuth client (package + SHA-1) must also exist in the same Google Cloud project. |

#### Where the OAuth values come from (backend)

The mobile client is registered in `vanep-api-java`. Its defaults already match
`.env.example`, so for local dev you only need to start the backend:

```bash
# in the vanep-api-java repo
make env   # creates .env from .env.example (includes the mobile client)
make dev   # starts Postgres + Mailpit + the API on :8080
```

To change them, set these in the backend `.env` (see its `.env.example`) and keep
the mobile `.env` in sync:

| Backend (`vanep-api-java`) | Mobile (`vanep-mobile`) |
| --- | --- |
| `VANEP_OAUTH_MOBILE_CLIENT_ID` | `OAUTH_CLIENT_ID` |
| `GOOGLE_CLIENT_ID` (Web client) | `GOOGLE_SERVER_CLIENT_ID` |

### Run the app

```bash
fvm flutter run
```

---

## Authentication (native)

Every authentication screen is native Flutter; no WebView or browser is used.
The backend (Spring Authorization Server) still checks credentials and issues
the JWTs.

1. **Login** posts `grant_type=urn:vanep:params:oauth:grant-type:password` to
   `/oauth2/token` with `client_id` only (public client).
2. **Google** uses `google_sign_in` to get an ID token for
   `GOOGLE_SERVER_CLIENT_ID` and posts
   `grant_type=urn:vanep:params:oauth:grant-type:google`. A new Google user gets
   `registration_required` with a `signup_ticket` and completes sign-up in the
   native form (`/api/auth/signup/complete`).
3. **Sign-up** posts to `/api/auth/signup/{client|driver|assistant}`, then the
   user types the 6-digit code from the e-mail (`/api/auth/email/verify`) and is
   signed in automatically.
4. **Forgot password** posts to `/api/auth/password/forgot` and
   `/api/auth/password/reset` with the e-mailed code.
5. The session (access + rotating refresh token + profile) is stored in
   **flutter_secure_storage**. `AuthInterceptor` refreshes it with
   `grant_type=refresh_token`; **Sair** revokes both tokens and clears it.

> Local dev uses cleartext HTTP to reach `10.0.2.2:8080`; this is allowed only in
> debug builds (`android/app/src/debug/AndroidManifest.xml`). Release builds are
> HTTPS-only. On iOS, add an ATS exception if you point `AUTH_URL` at HTTP.

---

## Available commands

Use the `Makefile` as the primary way to run Flutter tasks.

| Command | Description |
| --- | --- |
| `make install` | Clean + `pub_get` + `translate` + `build` (full post-clone setup) |
| `make clean` | `flutter clean` |
| `make pub_get` | `flutter pub get` |
| `make translate` | `flutter gen-l10n` (regenerate localizations from ARBs) |
| `make build` | `dart run build_runner build` (regenerate freezed / json_serializable code) |
| `make lint` | `flutter analyze --fatal-infos` |
| `make lint_fix` | `dart fix --apply` |
| `make test` | `flutter test` |
| `make coverage` | Test with coverage + enforce >= 85% threshold |
| `make coverage_open` | `make coverage` + open HTML report |

---

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs on every PR and push to `main`:

1. `flutter pub get`
2. `flutter analyze --fatal-infos`
3. `flutter test --coverage`
4. Enforce minimum coverage of 85%
