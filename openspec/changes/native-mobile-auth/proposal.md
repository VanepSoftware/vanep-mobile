## Why

The app signs people in by opening the backend `/oauth2/authorize` page inside a **WebView**. Sign-up, login and password recovery look like a website inside the app, outside the design system, and **Google login does not work on a real device**: Google blocks OAuth inside embedded WebViews (`403 disallowed_useragent`), and RFC 8252 forbids the model. Issue #177 (N-177) decides that the Vanep app, being first-party, moves every authentication flow to native Flutter screens talking JSON to the backend.

The backend half is already implemented in `vanep-api-java` (change `native-mobile-auth`, backend phases 0a–4c): password and Google grants on `/oauth2/token`, refresh tokens with rotation for the public `vanep-mobile` client, and the public `/api/auth/**` endpoints. This change is the mobile half (issue phases M5–M8).

## What Changes

- **Session storage moves from Hive to `flutter_secure_storage`.** Sessions stored by older builds are discarded (their legacy Hive box is deleted on start); users sign in again once.
- **Native login screen** replaces the welcome screen: e-mail + password through `grant_type=urn:vanep:params:oauth:grant-type:password`, a Google button, "Forgot password" and "Create account".
- **Error handling** for `invalid_grant`, `email_not_verified`, `account_locked`, `account_disabled`, `registration_required`, `429` and field validation errors, each with its own localized message or navigation.
- **Native sign-up**: account type choice (client, driver, assistant) → form with the same fields and rules as the web forms → `POST /api/auth/signup/{type}`.
- **E-mail verification by 6-digit code** with resend cooldown, followed by **automatic login** with the password still in memory (never persisted).
- **Native Google login** with `google_sign_in` (Credential Manager on Android) requesting the `id_token` for the **Web** client ID (`serverClientId`), sent through `grant_type=urn:vanep:params:oauth:grant-type:google`. A new Google user completes sign-up in the same native form using the `signup_ticket`, then the app repeats the Google grant.
- **Native password recovery**: e-mail → code + new password → back to login.
- **Removal of the legacy flow**: `OAuthWebViewPage`, `oauth_redirect.dart`, `PkceGenerator`, `WebSessionCleaner`, `BuildAuthorizationRequest`, `ExchangeAuthorizationCode`, `webview_flutter`, `crypto`, and `OAUTH_REDIRECT_URI` / `OAUTH_SCOPES` from `.env`.
- **BREAKING (config):** new `GOOGLE_SERVER_CLIENT_ID` in `.env` (the backend `GOOGLE_CLIENT_ID`, i.e. the Web client ID); `OAUTH_REDIRECT_URI` and `OAUTH_SCOPES` are no longer read.

**Out of scope:** Sign in with Apple and iOS publishing; confirming an e-mail change by code in the profile; DPoP, MFA, passkeys; backend phase 9 (removing `authorization_code` from `vanep-mobile`), which waits for this change to be released.

## Capabilities

### New Capabilities

- `native-sign-in`: obtaining, storing, refreshing and revoking tokens without a browser — secure session storage, password grant, Google grant and their error mapping.
- `native-account-flows`: account lifecycle screens that run before the app has tokens — sign-up by type, Google sign-up completion, e-mail verification by code with automatic login, and password reset by code.

### Modified Capabilities

None. The mobile repo has no specs under `openspec/specs/`.

## Impact

- **Code:** `lib/modules/auth/**` (datasources, repositories, use cases, cubits, pages), `lib/core/network/auth_interceptor.dart` (token read becomes async), `lib/core/ui/` (password field and secondary button), `lib/core/environment/environment.dart`, `lib/app.dart`, `lib/main.dart`, `lib/l10n/*.arb`.
- **Dependencies:** adds `flutter_secure_storage` and `google_sign_in`; removes `webview_flutter` and `crypto`.
- **Config:** `.env.example` and README document `GOOGLE_SERVER_CLIENT_ID`; the Android OAuth client (package + SHA-1) must exist in the same Google Cloud project as the Web client (backend task 0.4).
- **Backend contract:** requires the backend PRs #183–#194 deployed; the mobile client must keep sending only `client_id` (no secret).
