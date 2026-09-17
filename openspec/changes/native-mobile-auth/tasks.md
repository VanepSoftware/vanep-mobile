### Phased delivery (R16–R23)

Backend prerequisite: `vanep-api-java` PRs #183–#194 (change `native-mobile-auth`, phases 0a–4c).

```
0 ─▶ 1 ─▶ 2 ─▶ 3 ─▶ 4 ─▶ 5 ─▶ 6 ─▶ 7 ─▶ 8
```

| Phase | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 0 | OpenSpec change | — | — |
| 1 | Session in `flutter_secure_storage`, async token read, legacy Hive box purge (issue M5) | Phase 0 | — |
| 2 | Password grant, token endpoint failure mapping, native login screen (M5) | Phase 1; backend 2b | — |
| 3 | `AccountRepository`: sign-up and e-mail code endpoints, error envelope, sign-up validation (M7) | Phase 2; backend 4a, 4b | — |
| 4 | Account type choice and sign-up form (M7) | Phase 3 | — |
| 5 | E-mail code verification, resend cooldown, automatic login, `email_not_verified` from login (M7) | Phase 4 | — |
| 6 | Google SDK, Google grant, `registration_required` → Google sign-up completion (M6) | Phase 5; backend 3b, 4c | — |
| 7 | Forgot password and reset by code (M8) | Phase 5 | — |
| 8 | Remove the WebView flow, PKCE, redirect config and dependencies (M8) | Phases 6 and 7 | — |

Phases are stacked because each one edits `auth_container.dart`, the ARB files and the login screen.

## 0. Phase 0 — OpenSpec change (branch: `chore/N-177-native-auth-openspec`)

- [x] 0.1 Proposal, design, specs and tasks for the mobile half of N-177

## 1. Phase 1 — Secure session storage (branch: `feat/N-177-secure-session-storage`)

- [x] 1.1 Tests: `AuthLocalDataSource` saves, reads, clears the session in secure storage and returns `null` for missing or corrupt data
- [x] 1.2 Tests: `AuthInterceptor` awaits the async token reader
- [x] 1.3 Add `flutter_secure_storage`; `AuthLocalDataSource` backed by `FlutterSecureStorage` with async `readSession`
- [x] 1.4 `AuthInterceptor.readAccessToken` becomes async; repository and container await reads
- [x] 1.5 `main.dart` deletes the legacy Hive `auth` box
- [x] 1.6 Run `make lint` and `make test`

## 2. Phase 2 — Native password login (branch: `feat/N-177-native-password-login`)

- [x] 2.1 Tests: `requestPasswordGrant` form body; `mapTokenEndpointFailure` for every row of design D2; `signInWithPassword` success and failures
- [x] 2.2 Tests: `LoginCubit` (typing, submit, failure, success hands the session to `AuthCubit`); `LoginPage` widget
- [x] 2.3 New `AuthFailure` types and `mapTokenEndpointFailure`
- [x] 2.4 `OAuthRemoteDataSource.requestPasswordGrant`, `AuthRepository.signInWithPassword`, `SignInWithPassword` use case
- [x] 2.5 `AuthCubit.startSession`; `LoginCubit` + `LoginState`
- [x] 2.6 `VanepTextField` gains `obscureText`; `LoginPage` replaces `WelcomePage` in `AuthGate`
- [x] 2.7 Localized messages for every login failure
- [x] 2.8 Run `make lint` and `make test`

## 3. Phase 3 — Account API (branch: `feat/N-177-account-api`)

- [ ] 3.1 Tests: `isValidCpf`, `validateSignupForm`, `SignupField.fromApi`
- [ ] 3.2 Tests: `AccountRemoteDataSource` request bodies; `mapAccountFailure` for each envelope code, `429` and network; `AccountRepositoryImpl`
- [ ] 3.3 Domain: `SignupForm`, `SignupField`, `SignupFieldIssue`, `AccountFailure`, `AccountRepository`, use cases `SignUp`, `VerifyEmailCode`, `ResendEmailVerificationCode`
- [ ] 3.4 Data: `AuthApiErrorDto`, `AccountRemoteDataSource`, `AccountRepositoryImpl`, endpoints in `Environment`
- [ ] 3.5 Register in `auth_container.dart`
- [ ] 3.6 Run `make lint` and `make test`

## 4. Phase 4 — Sign-up screens (branch: `feat/N-177-native-signup-screens`)

- [ ] 4.1 Tests: `SignupCubit` (field updates clear issues, local validation blocks submit, server field errors, duplicates, success outcome)
- [ ] 4.2 Tests: `AccountTypePage` and `SignupPage` widgets (driver fields only for driver)
- [ ] 4.3 `SignupCubit` + `SignupState`, `AccountTypePage`, `SignupPage`, "Create account" on the login screen
- [ ] 4.4 Localized labels and field issue messages
- [ ] 4.5 Run `make lint` and `make test`

## 5. Phase 5 — E-mail code verification (branch: `feat/N-177-email-code-verification`)

- [ ] 5.1 Tests: `CodeResendCooldown`; `EmailCodeVerificationCubit` (invalid code, success with and without password, resend starts cooldown)
- [ ] 5.2 Tests: verification page widget; login `email_not_verified` opens verification; `AuthGate` pops pushed pages on authentication
- [ ] 5.3 `CodeResendCooldown`, `EmailCodeVerificationCubit`, `EmailCodeVerificationPage`, shared `VerificationCodeField`
- [ ] 5.4 Sign-up success and login `email_not_verified` open the verification screen
- [ ] 5.5 Run `make lint` and `make test`

## 6. Phase 6 — Native Google login (branch: `feat/N-177-native-google-login`)

- [ ] 6.1 Tests: `requestGoogleGrant`; `registration_required` parsing; `signInWithGoogle` (cancel, success, registration required); sign-out signs out of Google
- [ ] 6.2 Tests: `completeGoogleSignup` request body and failures; `SignupCubit` Google flow repeats the grant; login Google button
- [ ] 6.3 Add `google_sign_in`; `GOOGLE_SERVER_CLIENT_ID` in `Environment`, `.env.example` and README
- [ ] 6.4 `GoogleIdTokenSource`, `requestGoogleGrant`, `signInWithGoogle`, `SignInWithGoogle`, `CompleteGoogleSignup`
- [ ] 6.5 `VanepSecondaryButton` in core UI; Google button on login; Google mode in `AccountTypePage` / `SignupPage`
- [ ] 6.6 Run `make lint` and `make test`
- [ ] 6.7 Test Google login on a real Android device (acceptance of issue M6)

## 7. Phase 7 — Password reset by code (branch: `feat/N-177-native-password-reset`)

- [ ] 7.1 Tests: `requestPasswordReset` / `resetPassword` bodies and failures; `PasswordResetCubit` (email step, code step, short password, invalid code, success)
- [ ] 7.2 Tests: `PasswordResetPage` widget
- [ ] 7.3 Use cases `RequestPasswordReset`, `ResetPasswordWithCode`; `PasswordResetCubit`; `PasswordResetPage`; "Forgot password" on login
- [ ] 7.4 Run `make lint` and `make test`

## 8. Phase 8 — Remove the WebView flow (branch: `chore/N-177-remove-webview-oauth`)

- [ ] 8.1 Delete `OAuthWebViewPage`, `oauth_redirect.dart`, `PkceGenerator`, `WebSessionCleaner`, `BuildAuthorizationRequest`, `ExchangeAuthorizationCode`, `AuthorizationRequest` and their tests
- [ ] 8.2 Remove `AuthAuthenticating`, `AuthExchanging`, `InvalidStateAuthFailure`, `startLogin`, `submitAuthorizationCode`, `cancelLogin`
- [ ] 8.3 Remove `webview_flutter` and `crypto`; `OAUTH_REDIRECT_URI` / `OAUTH_SCOPES` from `Environment`, `.env.example`, README and the Makefile coverage filter
- [ ] 8.4 Run `make lint`, `make test` and `make coverage`
- [ ] 8.5 Manual test of every flow on a device (R27a)
