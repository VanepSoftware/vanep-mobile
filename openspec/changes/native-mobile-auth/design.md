## Context

Backend contract (from `vanep-api-java`, change `native-mobile-auth`):

- `POST /oauth2/token` (form-encoded, `client_id=vanep-mobile`, no secret):
  - password grant: `grant_type=urn:vanep:params:oauth:grant-type:password`, `username`, `password`;
  - Google grant: `grant_type=urn:vanep:params:oauth:grant-type:google`, `id_token`;
  - `refresh_token` grant now returns a **rotated** refresh token.
- Token endpoint errors are `400 {"error", "error_description"}`. `registration_required` adds `signup_ticket`, `email`, `name`. Rate limiting answers `429` with a plain-text body.
- `/api/auth/**` (JSON, public, never returns tokens). Errors use `{"code", "message", "errors": [{"field", "message"}]}`:
  - `POST /signup/{client|driver|assistant}` → `201`; `400 validation_error`; `409 email_duplicate | document_duplicate`;
  - `POST /signup/complete` → `201`; `400 invalid_signup_ticket | validation_error`; `409`;
  - `POST /email/verify` → `204`; `400 invalid_code`;
  - `POST /email/verify/resend` and `POST /password/forgot` → always `202`;
  - `POST /password/reset` → `204`; `400 invalid_code | validation_error` (`newPassword` ≥ 8).

Current app: `WelcomePage` pushes `OAuthWebViewPage`; `AuthRepositoryImpl` exchanges the code with PKCE and stores the session as JSON in a Hive box; `AuthInterceptor` reads the access token **synchronously** from that box; `AuthCubit` owns the session state that `AuthGate` routes on.

Constraints: mobile constitution — Clean Architecture with `Result` (R01, R04), DI through containers (R03), test-first (R05), reuse of core UI (R10a/R10b), localized copy only (R10), no private methods (R08), no comments in source (R40a), phases ≤ ~600 productive lines and ≤ 10 new files (R23).

## Goals / Non-Goals

**Goals:**

- Every authentication flow of the app is native; no WebView, no browser.
- The session is readable only by the app (Keystore/Keychain backed).
- `AuthCubit` stays the single owner of the session; every flow ends by handing it a session.
- Each phase compiles, passes `make lint` / `make test`, and can be tried on a device.

**Non-Goals:**

- Migrating sessions from the Hive box (old sessions have no refresh token; users log in again).
- Offline sign-up, biometric unlock, account linking UI.
- Changing profile or e-mail-change screens.

## Decisions

### D1: Secure storage with an async read path

`AuthLocalDataSource` stores the session JSON under one key in `FlutterSecureStorage`. Reads become `Future<AuthSessionDto?>`, so `AuthInterceptor.readAccessToken` becomes `Future<String?> Function()` and `onRequest` awaits it. No in-memory mirror: the storage is the single source of truth (R06a). `main.dart` deletes the legacy Hive `auth` box once at start, which is why `hive_ce` stays until a later cleanup.

- **Rejected:** a memory cache hydrated at start. It would be a second copy of the session that can disagree with storage after a failed write.

### D2: Grants live in the existing OAuth datasource and repository

`OAuthRemoteDataSource` gains `requestPasswordGrant` and `requestGoogleGrant`. `AuthRepository` gains `signInWithPassword` and `signInWithGoogle`, which share one "token → profile → save" path with the refresh flow. Token endpoint `DioException`s are mapped once, in `mapTokenEndpointFailure`, to typed `AuthFailure`s:

| Response | Failure |
|---|---|
| no response | `NetworkAuthFailure` |
| `429` | `TooManyRequestsAuthFailure` |
| `invalid_grant` | `InvalidCredentialsAuthFailure` |
| `email_not_verified` | `EmailNotVerifiedAuthFailure` |
| `account_locked` | `AccountLockedAuthFailure` |
| `account_disabled` | `AccountDisabledAuthFailure` |
| `registration_required` | `RegistrationRequiredAuthFailure(GoogleSignupTicket)` |
| anything else | `UnexpectedAuthFailure` |

### D3: Account endpoints get their own repository

`/api/auth/**` is not a session concern, so it gets `AccountRepository` + `AccountRemoteDataSource`, using the unauthenticated Dio (a stale bearer must never reach these routes). Failures are `AccountFailure`s mapped from the `{code, message, errors}` envelope. Server messages are **not** shown: copy comes from l10n (R10). Field errors map the API field name to `AccountField` (`driverFieldsComplete` → `basePrice`, `newPassword` → `password`).

### D4: Sign-up validation runs in the domain first

`SignupForm.validate` (pure Dart) mirrors the backend rules — required name/e-mail/password/CPF, e-mail format, password ≥ 6, CPF check digits, terms accepted, driver base price > 0 — and returns `Map<AccountField, AccountFieldIssue>`. The server stays authoritative: a `validation_error` it returns marks the listed fields as `AccountFieldIssue.rejected`, shown with a generic localized message.

### D5: One sign-up form for both entry points

`SignupState` carries an optional `GoogleSignupTicket`: absent for the password flow, present for a new Google user. Both flows go through `AccountTypePage` → `SignupPage`, and the account type lives only in `SignupForm`. The page renders name/e-mail/password only without a ticket; with a ticket it shows the ticket's name and e-mail read-only. `SignupCubit` submits to `SignUp` or `CompleteGoogleSignup` accordingly. After a Google completion the cubit repeats the Google grant to obtain tokens.

### D6: Screens push above `AuthGate`; authentication pops them

`LoginPage` is what `AuthGate` shows when unauthenticated. Sign-up, verification and reset pages are pushed on the root navigator. When `AuthCubit` emits `AuthAuthenticated`, a single `BlocListener` in `AuthGate` pops to the first route. No page decides navigation after login on its own.

Flows hand sessions to `AuthCubit.startSession(session)` through a `StartSession` callback injected with `registerFactoryParam`, the pattern `PersonalDataCubit` already uses for `SyncProfile`.

### D7: Automatic login after verification keeps the password only in cubit state

The password typed at sign-up (or at a login that returned `email_not_verified`) is passed to `EmailCodeVerificationPage` as a constructor argument and lives only in `EmailCodeVerificationCubit` state. After `204` the cubit calls `signInWithPassword`. If the app was closed, the user signs in normally.

### D8: Resend cooldown is a reusable ticker

`CodeResendCooldown` (presentation) counts down from the configured duration (default 60 s, matching the backend) and is used by the verification and reset cubits. The duration is injected so tests run in milliseconds. The backend enforces the real limit; the ticker only avoids useless requests.

### D9: Google ID token source behind an interface

`GoogleIdTokenSource` (data) wraps `GoogleSignIn.instance`: `initialize(serverClientId)` once, `authenticate()` for the interactive sign-in, `GoogleSignInExceptionCode.canceled` → `null` (cancelled). `signOut` on app sign-out, so the account chooser shows again. `GOOGLE_SERVER_CLIENT_ID` must be the backend `GOOGLE_CLIENT_ID`; without it the backend rejects every token as `invalid_grant` (backend risk list).

## Risks / Trade-offs

- **Missing Android OAuth client / wrong SHA-1** → `clientConfigurationError` from the SDK; surfaced as a generic Google error. Acceptance requires a real device test (backend task 0.4).
- **Async token read on every request** → one Keystore read per call; acceptable for the request volume, avoids a mirrored session.
- **Users of older builds are logged out once** → accepted in the issue (D8).
- **Client-side rules drift from the backend** → the server still validates; drift degrades to the generic "check this field" message, never to a wrong account.

## Migration Plan

1. Backend PRs #183–#194 merged and deployed (with `GOOGLE_CLIENT_ID` set).
2. Mobile phases 1–8 merged in order; release sets `GOOGLE_SERVER_CLIENT_ID`.
3. Backend phase 9 only after no active build uses the WebView flow.
