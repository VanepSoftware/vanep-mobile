# Specification: Assistant Profile & Operations Flow

## Feature: Assistant Authentication & Invitation Acceptance

### Scenario: Entering as assistant from welcome screen
  Given the user is on the welcome screen (S01)
  When the user taps "Entrar como assistente"
  Then the app navigates to the invitation code screen

### Scenario: Submitting a valid invitation code
  Given the user is on the invitation code screen
  When the user enters a valid, active 6-character or tokenized invitation code
  And submits the code
  Then the app validates the code with the backend
  And navigates to the lean registration form with the driver's van pre-linked

### Scenario: Submitting an invalid, expired, or revoked invitation code
  Given the user is on the invitation code screen
  When the user enters an invalid, expired, or already used invitation code
  And submits the code
  Then the app displays a clear error message in Portuguese explaining why the code cannot be used
  And remains on the invitation code screen

### Scenario: Receiving deep link invitation from email
  Given the user receives an invitation email with deep link `vanep://assistant/invite?token=ABC123XYZ`
  When the user taps the link
  Then the app opens directly to the invitation confirmation screen showing the inviting driver and vehicle details
  And provides actions to accept or decline the invite

---

## Feature: Lean Assistant Registration

### Scenario: Completing lean registration
  Given the assistant has validated an invitation code
  When the assistant fills in the registration form with:
    | Field      | Value               |
    | Name       | "Carlos Santos"     |
    | Birth Date | "1995-04-12"        |
    | Email      | "carlos@gmail.com"  |
    | CPF        | "123.456.789-00"    |
  And submits the form
  Then the account is created with `UserType.assistant`
  And the assistant is immediately linked to the inviting driver's vehicle
  And the app navigates to the Assistant Shell

### Scenario: Validating mandatory lean registration fields
  Given the assistant is on the lean registration screen
  When any mandatory field is omitted or invalid (e.g. invalid CPF format)
  Then inline error messages appear
  And submission is prevented

---

## Feature: Van Selection (N:N Relationship)

### Scenario: Assistant linked to a single van
  Given the assistant is linked to only one van
  When the assistant logs in and enters the app
  Then that van is automatically selected as the active van
  And no selector modal is forced

### Scenario: Assistant linked to multiple vans
  Given the assistant is linked to multiple vans/drivers
  When the assistant opens the app or views the today's route
  Then a van selection sheet is presented displaying the available drivers, vans, and shifts
  When the assistant selects an active van
  Then the route and student list update to reflect that specific van's trip for the day

---

## Feature: Assistant Shell & Restricted Navigation

### Scenario: Assistant shell structure
  Given an authenticated user with `UserType.assistant`
  When the `AuthGate` evaluates the user's session
  Then the app renders `AssistantShell` with bottom navigation items:
    | Tab     | Icon           | Accessibility Label |
    | Rota    | Route icon     | "Rota do dia"       |
    | Alunos  | Students icon  | "Lista de alunos"   |
    | Perfil  | Profile icon   | "Meu perfil"        |
  And the navigation does NOT contain Proposals, Financial, or Vehicle Document tabs

### Scenario: Route guard blocking restricted paths
  Given an assistant is logged in
  When an attempt is made to navigate to a driver or client route (e.g. `/proposals`, `/documents`, `/search`) via deep link or manual route
  Then the route guard intercepts the navigation
  And displays an unauthorized feedback message
  And keeps the user within the `AssistantShell`

---

## Feature: Route Operation & Shared Checklist

### Scenario: Viewing today's route and student list
  Given the assistant is operating an active van with a scheduled trip
  When the assistant views the "Rota" tab
  Then the list of stops and assigned students is displayed in chronological order
  With student photos, names, school names, and current boarding status

### Scenario: Individual student check-in
  Given a student is listed at the current stop
  When the assistant marks the student as boarded ("Confirmar embarque")
  Then the status is updated locally and sent to the backend
  And the checklist entry records `confirmed_by = assistant`
  And the driver's synchronized view immediately shows that the assistant confirmed the boarding

### Scenario: Bulk check-in at a school stop
  Given multiple students are scheduled for drop-off at a school
  When the assistant taps "Dar baixa em lote" (Bulk check-in)
  Then all selected students are updated at once
  With attribution to the assistant

### Scenario: Marking student no-show
  Given a student is absent at their scheduled pick-up location
  When the assistant taps "Não compareceu"
  And selects a reason (e.g. "Avisado pelo responsável", "Não estava no local")
  Then the no-show event is recorded with the selected reason
  And the status reflects "Não compareceu" in the shared checklist

---

## Feature: Link Revocation Handling

### Scenario: Driver revokes assistant link
  Given a driver has revoked the assistant's link in the backend
  When the assistant makes an API request or resumes the app session
  Then the API returns the unlinked status
  And the app informs the assistant that access to the van has been removed
  And directs the assistant to the unlinked/idle assistant screen
