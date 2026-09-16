## ADDED Requirements

### Requirement: Sign-up by account type in steps

From the login screen, "Create account" SHALL open a choice between client, driver and assistant, each with a short description. The sign-up form MUST be split into steps with a progress indicator:

1. **Access**: name, e-mail, password and password confirmation (skipped for a new Google user);
2. **Personal**: CPF, optional phone, birth date and gender;
3. **Professional** (driver only): base price (required), optional years of experience and CNPJ;
4. **Confirmation**: account summary and terms acceptance.

"Continue" MUST only advance when the fields of the current step are valid. Going back MUST return to the previous step keeping what was typed. Submitting SHALL post to `/api/auth/signup/{type}`.

#### Scenario: Client sign-up

- **WHEN** a person completes every step of the client sign-up and confirms
- **THEN** the app posts to `/api/auth/signup/client` and opens code verification for that e-mail

#### Scenario: Driver without base price

- **WHEN** a driver tries to continue from the professional step without a base price
- **THEN** the base price field shows the localized required message and the step does not advance

#### Scenario: Back to the previous step

- **WHEN** the person presses back on the personal step
- **THEN** the access step is shown with the values already typed

---

### Requirement: Sign-up validates before sending and shows server errors per field

The form SHALL check locally: required name, e-mail, password and CPF; e-mail format; a password with at least 6 characters, one uppercase letter and one special character; a password confirmation equal to the password; CPF check digits; terms accepted; driver base price greater than zero. While typing the password, the app MUST show each password requirement and whether it is met. Fields rejected by a `400 validation_error` MUST be marked with a localized message and the form MUST return to the step of the first rejected field. `409 email_duplicate` and `409 document_duplicate` MUST mark the e-mail and CPF fields with their own messages.

#### Scenario: Weak password

- **WHEN** the access step is submitted with a password without an uppercase letter
- **THEN** the unmet requirement is highlighted and the step does not advance

#### Scenario: Passwords do not match

- **WHEN** the confirmation differs from the password
- **THEN** the confirmation field shows the localized mismatch message

#### Scenario: Invalid CPF

- **WHEN** the personal step is submitted with a CPF whose check digits are wrong
- **THEN** the CPF field shows the localized invalid CPF message and nothing is sent

#### Scenario: Duplicate e-mail

- **WHEN** the API answers `409 email_duplicate` on confirmation
- **THEN** the form returns to the access step and the e-mail field shows the localized "already registered" message

---

### Requirement: Verify e-mail by code and sign in automatically

The verification screen SHALL accept a 6-digit code and post it with the e-mail to `/api/auth/email/verify`. On `204`, when the password is known from the same session, the app MUST sign in with the password grant and show the user's shell. Otherwise it MUST return to the login screen with a confirmation message. `400 invalid_code` MUST show the localized invalid code message.

#### Scenario: Correct code after sign-up

- **WHEN** a person who just signed up types the correct code
- **THEN** the app authenticates without asking for the password again

#### Scenario: Wrong code

- **WHEN** the API answers `invalid_code`
- **THEN** the screen shows the localized invalid code message and keeps the code field editable

---

### Requirement: Resend code with cooldown

The verification and reset screens SHALL offer resending the code. After a code is sent the resend action MUST stay disabled for the cooldown (60 seconds by default), showing the remaining seconds. Resend posts to `/api/auth/email/verify/resend` or `/api/auth/password/forgot` and always reports that a code was sent.

#### Scenario: Resend right after sign-up

- **WHEN** the verification screen opens right after sign-up
- **THEN** resend is disabled and shows the remaining seconds

---

### Requirement: Complete Google sign-up

In Google mode the form SHALL ask for CPF, optional phone, birth date and gender, terms, and the driver fields when the type is driver, and post them with `signupTicket` and `type` to `/api/auth/signup/complete`. On `201` the app MUST repeat the Google grant and authenticate. `400 invalid_signup_ticket` MUST show the localized expired sign-up message and return to the login screen.

#### Scenario: Google client completes sign-up

- **WHEN** a new Google user submits a valid client form
- **THEN** the app posts to `/api/auth/signup/complete`, repeats the Google grant and shows the client shell

#### Scenario: Expired ticket

- **WHEN** the API answers `invalid_signup_ticket`
- **THEN** the app shows the localized expired sign-up message and returns to the login screen

---

### Requirement: Reset password by code

"Forgot password" SHALL ask for the e-mail and post it to `/api/auth/password/forgot`, then ask for the code and a new password of at least 8 characters and post them to `/api/auth/password/reset`. On `204` the app MUST return to the login screen with a success message. `400 invalid_code` MUST show the localized invalid code message.

#### Scenario: Successful reset

- **WHEN** the correct code and an 8-character password are submitted
- **THEN** the app returns to the login screen with the localized success message

#### Scenario: Short new password

- **WHEN** a 7-character password is submitted
- **THEN** the password field shows the localized minimum length message and nothing is sent
