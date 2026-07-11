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
| `OAUTH_CLIENT_ID` | Public OAuth client id (PKCE, no secret). Must match `VANEP_OAUTH_MOBILE_CLIENT_ID` in `vanep-api-java`. Default: `vanep-mobile`. |
| `OAUTH_REDIRECT_URI` | Custom-scheme redirect. Must match `VANEP_OAUTH_MOBILE_REDIRECT_URIS` in the backend. Default: `com.vanep.vanepmobile://oauth2redirect`. |
| `OAUTH_SCOPES` | Space-separated scopes requested at `/oauth2/authorize`. Default: `read write`. |

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
| `VANEP_OAUTH_MOBILE_REDIRECT_URIS` | `OAUTH_REDIRECT_URI` |

### Run the app

```bash
fvm flutter run
```

---

## Authentication (OAuth2 + PKCE)

Login uses the Vanep backend (Spring Authorization Server) via the
**authorization code + PKCE** flow (public client, no secret):

1. On the welcome screen, tap **Continuar**.
2. An in-app **WebView** opens the backend login page (`/oauth2/authorize`);
   sign in with e-mail/password or Google.
3. The backend redirects to `OAUTH_REDIRECT_URI`. The WebView **intercepts** that
   custom-scheme navigation (no Android/iOS deep link needed) and extracts the
   authorization `code`.
4. The app exchanges the code at `/oauth2/token` (with the PKCE `code_verifier`),
   fetches the profile from `/api/user/profile`, and stores the session in
   **Hive** — so the user stays signed in across app launches.
5. **Sair** revokes the tokens (`/oauth2/revoke`) and clears the local session.

> Local dev uses cleartext HTTP to reach `10.0.2.2:8080`; this is allowed only in
> debug builds (`android/app/src/debug/AndroidManifest.xml`). Release builds are
> HTTPS-only. On iOS, add an ATS exception if you point `AUTH_URL` at HTTP.

---

## Available commands

Use the `Makefile` as the primary way to run Flutter tasks.

| Command | Description |
| --- | --- |
| `make install` | Clean + `flutter pub get` |
| `make clean` | `flutter clean` |
| `make pub_get` | `flutter pub get` |
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
