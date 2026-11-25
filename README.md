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
| `GOOGLE_IOS_CLIENT_ID` | Google **iOS** client ID (bundle `com.vanep.vanepMobile`). Also set `GOOGLE_IOS_CLIENT_ID` and `GOOGLE_IOS_REVERSED_CLIENT_ID` in `ios/Flutter/GoogleSignIn.xcconfig`. |

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

### Configure Firebase (`google-services.json`)

Android builds apply the `com.google.gms.google-services` and
`com.google.firebase.crashlytics` Gradle plugins, so they need
`android/app/google-services.json`. The file is **git-ignored**: download it
from the Firebase console (Project settings → Your apps → Android app
`com.vanep.vanep_mobile`) and save it at `android/app/google-services.json`.
Without it, `flutter run` / `flutter build` on Android fails. CI writes it from
the `GOOGLE_SERVICES_JSON` secret (see [Repository secrets](#repository-secrets)).

Firebase is only initialized on Android; iOS has no `GoogleService-Info.plist`
or APNs key yet.

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

## Push notifications and Crashlytics (Android)

- **Crashlytics** records `FlutterError.onError` and
  `PlatformDispatcher.instance.onError`. Collection is off in debug builds.
- **Permission**: after sign-in (or when a saved session is restored) the app asks
  for the notification permission (runtime prompt on Android 13+,
  `POST_NOTIFICATIONS`).
- **Device registration**: if allowed, the FCM token is sent to
  `POST /api/devices` with `{"token": "...", "platform": "android"}`, and sent
  again on every token refresh. **Sair** calls `DELETE /api/devices/{token}`
  before the session tokens are revoked.
- **Messages**: in the foreground they are shown as a local notification on the
  `vanep_default` channel. In the background the system shows messages that have a
  `notification` block; data-only messages are shown when `data` has a `title`
  or `body`.
- **Tap**: the app opens the screen for `data.type`:

| `data.type` | Extra `data` keys | Client | Driver |
| --- | --- | --- | --- |
| `chat` | `conversationToken` (required), `counterpartName` | Chat | Chat |
| `proposal` / `proposta` | — | Proposals list | Propostas tab |
| `contract` / `contrato` | — | Vans tab | Propostas tab (contracts section) |

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

---

## Deploy

Android releases go to Google Play through [fastlane](https://fastlane.tools)
(`android/fastlane/Fastfile`), run by GitHub Actions on `ubuntu-latest`:

| Trigger | Workflow | Play track | `.env` from |
| --- | --- | --- | --- |
| Push to `main` | `.github/workflows/cd-internal.yml` | `internal` (internal testing), then the same build is promoted to the closed testing track (`alpha` by default) | `TESTING_ENV_FILE` |
| Manual (`workflow_dispatch`) | `.github/workflows/cd-internal.yml` | depends on the `tracks` input (below) | `TESTING_ENV_FILE` |
| GitHub release published | `.github/workflows/cd-production.yml` | `production` | `PRODUCTION_ENV_FILE` |

- Pushes whose head commit has `[skip ci]`, or that only touch docs (`*.md`,
  `docs/**`, `openspec/**`), are not deployed.
- **versionCode** is computed: fastlane reads the version codes on the
  `internal`, `alpha`, `beta` and `production` tracks, takes the highest and adds 1.
  The `+N` in `pubspec.yaml` is not used by the deploy.
- **versionName** for production comes from the release tag (`v1.2.3` → `1.2.3`);
  the tag must be `vX.Y.Z`. Pre-releases are not deployed.
- Production currently uploads as a **draft** (`PLAY_RELEASE_STATUS: draft` in
  `cd-production.yml`), because Play rejects `completed` releases for an app that
  was never published. Remove it after the first reviewed release.
- **Closed testing**: after uploading to `internal`, the same versionCode N (same
  AAB, not re-uploaded) is promoted with `upload_to_play_store(track_promote_to: ...)`
  using the same `PLAY_SERVICE_ACCOUNT_JSON`. Configure with environment variables:
  - `PLAY_CLOSED_TRACK` (default `alpha`, the default closed testing track). If Play
    reports an unknown track, list the tracks (`edits.tracks.list`) and set this.
  - `PLAY_CLOSED_RELEASE_STATUS` (default `completed`). If Play refuses `completed`
    (app never published/reviewed) run with `draft` and send it to review manually.
    An existing draft on the closed track makes the promote fail with a clear
    `play_api` error.
- **Manual run** (Actions > "CD — teste interno" > Run workflow), input `tracks`:
  - `internal+closed` (default, also the push behavior): build, publish N to
    `internal`, promote N to the closed track.
  - `internal`: build and publish to `internal` only.
  - `promote-closed`: no build and no new versionCode; promotes the current highest
    versionCode on `internal` to the closed track. Use it to retry a failed promote.
- Only one deploy runs at a time (concurrency group `play-android-deploy`).
- On failure the job prints a `[failure_category:config|build|play_api]` line and
  an error annotation with that category.

The contents of `.env` are packaged into the app bundle as an asset, so they
must never hold real secrets.

### Repository secrets

| Secret | Content |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Upload keystore (`.jks`), base64-encoded (`base64 -i upload.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias (`upload`) |
| `ANDROID_KEY_PASSWORD` | Key password |
| `PLAY_SERVICE_ACCOUNT_JSON` | JSON key of the Google Play service account with release permission for `com.vanep.vanep_mobile` |
| `TESTING_ENV_FILE` | Full `.env` contents for the internal testing build |
| `PRODUCTION_ENV_FILE` | Full `.env` contents for the production build |
| `GOOGLE_SERVICES_JSON` | Full contents of the Firebase `google-services.json` for `com.vanep.vanep_mobile` (FCM + Crashlytics) |

`scripts/ci-prepare-play-deploy.sh` turns these into `android/app/upload.jks`,
`android/key.properties`, `.env`, `android/app/google-services.json` and a
service account file outside the repo. It only runs in CI, because it overwrites
`.env`, `android/key.properties` and `android/app/google-services.json`.

### Run a deploy locally

This publishes to Google Play for real.

1. Install Ruby 3.3 and the gems: `bundle install`.
2. Put the `.env` you want to ship at the repo root, the Firebase
   `google-services.json` at `android/app/`, and create
   `android/key.properties` pointing at the upload keystore:

   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/absolute/path/to/upload.jks
   ```

3. Make sure `flutter` on your `PATH` is the `.fvmrc` version
   (e.g. `export PATH="$PWD/.fvm/flutter_sdk/bin:$PATH"`).
4. Point fastlane at the service account JSON (keep it outside the repo) and run
   the lane from `android/`:

   ```bash
   export PLAY_SERVICE_ACCOUNT_JSON_PATH=/path/outside/repo/play-service-account.json
   cd android
   bundle exec fastlane android deploy_internal
   ```

   Lanes: `deploy_internal` (internal only), `deploy_internal_and_closed`,
   `promote_internal_to_closed` (no build; optional `PLAY_CLOSED_TRACK` /
   `PLAY_CLOSED_RELEASE_STATUS`).

   For production, also set `PLAY_VERSION_NAME=1.2.3` (and `PLAY_RELEASE_STATUS=draft`
   while the app is still a draft) and run `bundle exec fastlane android deploy_production`.
