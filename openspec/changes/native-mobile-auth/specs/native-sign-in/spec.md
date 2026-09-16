## ADDED Requirements

### Requirement: Session is stored in secure storage

The app SHALL persist the session (access token, refresh token, expiry, profile) only in platform secure storage. The app MUST NOT write tokens to Hive or any other unencrypted store. On start, the app MUST delete the session box left by older builds.

#### Scenario: Restart with a stored session

- **WHEN** the app restarts after a successful login
- **THEN** the session is read back from secure storage and the user lands on their shell

#### Scenario: Legacy session

- **WHEN** a build with this change starts on a device that has the legacy Hive `auth` box
- **THEN** the box is deleted and the login screen is shown

---

### Requirement: Login with e-mail and password without a browser

The login screen SHALL send `grant_type=urn:vanep:params:oauth:grant-type:password`, `username`, `password` and `client_id` to `/oauth2/token`, fetch `/api/user/me` with the access token, store the session and authenticate the app. No WebView or browser MAY be opened.

#### Scenario: Successful login

- **WHEN** a verified user submits correct credentials
- **THEN** the app shows the shell for the user's type

#### Scenario: Wrong credentials

- **WHEN** the token endpoint answers `invalid_grant`
- **THEN** the app shows the localized invalid credentials message and stays on the login screen

#### Scenario: Locked account

- **WHEN** the token endpoint answers `account_locked`
- **THEN** the app shows the localized locked account message

#### Scenario: Too many requests

- **WHEN** the token endpoint answers `429`
- **THEN** the app shows the localized "try again shortly" message

---

### Requirement: Unverified account goes to code verification

When the password grant answers `email_not_verified`, the app SHALL open the e-mail code verification screen for that e-mail, keeping the typed password in memory for the automatic login.

#### Scenario: Login before verifying

- **WHEN** an unverified user submits the correct password
- **THEN** the verification screen opens for that e-mail with resend available

---

### Requirement: Login with Google natively

The Google button SHALL obtain an ID token from the native Google SDK for the configured Web client ID and send it with `grant_type=urn:vanep:params:oauth:grant-type:google` and `client_id`. Cancelling the Google chooser MUST leave the user on the login screen without an error message.

#### Scenario: Linked Google account

- **WHEN** a user with a linked or matching Vanep account picks their Google account
- **THEN** the app authenticates and shows the user's shell

#### Scenario: Chooser cancelled

- **WHEN** the user dismisses the Google account chooser
- **THEN** the app stays on the login screen and shows no error

#### Scenario: Deactivated account

- **WHEN** the token endpoint answers `account_disabled`
- **THEN** the app shows the localized deactivated account message

---

### Requirement: New Google user completes sign-up

When the Google grant answers `registration_required`, the app SHALL open the account type choice and then the sign-up form in Google mode, showing the name and e-mail from the response and carrying the `signup_ticket`.

#### Scenario: First Google login

- **WHEN** the Google grant answers `registration_required` with a ticket, e-mail and name
- **THEN** the account type choice opens and the next form shows that name and e-mail read-only

---

### Requirement: Refresh and sign-out keep working

The app SHALL refresh expired sessions with `grant_type=refresh_token` and `client_id` only, storing the rotated refresh token. Sign-out MUST revoke the refresh and access tokens, clear secure storage and sign out of the Google SDK.

#### Scenario: Rotated refresh token

- **WHEN** a refresh returns a new refresh token
- **THEN** the stored session holds the new refresh token

#### Scenario: Sign-out

- **WHEN** the user signs out
- **THEN** both tokens are revoked, the session is removed from secure storage and the login screen is shown
