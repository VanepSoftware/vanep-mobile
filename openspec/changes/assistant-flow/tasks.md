# Tasks & Phased Delivery: Assistant Profile & Operations Flow

### Phased delivery (R16–R23)

| Phase | Contents | Depends on | Parallel with |
|---|---|---|---|
| **Phase 1** | Domain Layer & Contracts: Entities, Failures, Value Objects, Repository Interfaces & UseCases for Invite and Lean Signup | — | — |
| **Phase 2** | Data Layer & Network: DTOs (Freezed), Datasources, Repository Implementations, and DI Container Registration | Phase 1 merged | — |
| **Phase 3** | Invite & Lean Registration UI: "Entrar como assistente" on Welcome, Invite Code Screen, Lean Signup Page, and Deeplink Receiver | Phase 2 merged | — |
| **Phase 4** | Assistant Shell & Multi-Van Selection: `AssistantShell`, `AssistantBottomNav`, Route Guard, and Active Van Selector Sheet | Phase 3 merged | — |
| **Phase 5** | Daily Route & Shared Checklist: Today's Route Page, Students List, Individual/Bulk Check-in, No-Show Modal, and `confirmed_by` Attribution | Phase 4 merged | — |

> ⚠️ **R27a: Nenhum commit sem a sua aprovação explícita.** Ao final de cada fase, `make lint` e `make test` passando não bastam — eu paro e espero você validar no emulador ou aparelho real antes de commitar ou abrir PR.

---

## 1. Phase 1 — Domain Layer & Contracts (branch: `feat-(N-37)/assistant-domain-contracts`)

- [x] 1.1 Test fixtures for assistant domain objects (`test/modules/assistant/fixtures/assistant_fixtures.dart`)
- [x] 1.2 Entity `AssistantInvite` (`token`, `driverName`, `vehicleDescription`, `expiresAt`, `status`) with value equality (R04)
- [x] 1.3 Entity `AssistantVan` (`token`, `driverToken`, `driverName`, `plate`, `model`, `shift`)
- [x] 1.4 Value Object `ConfirmationSource` (`driver`, `assistant`)
- [x] 1.5 Domain Failure classes (`AssistantFailure`, `InvalidInviteCodeFailure`, `ExpiredInviteFailure`, `AlreadyUsedInviteFailure`)
- [x] 1.6 Contract `AssistantRepository` interface with methods for validation, signup, van listing, and trip checklist
- [x] 1.7 UseCase `ValidateAssistantInvite` with unit tests (`mocktail`)
- [x] 1.8 UseCase `RegisterAssistantWithInvite` with unit tests (`mocktail`)
- [x] 1.9 UseCase `GetLinkedVans` with unit tests (`mocktail`)
- [x] 1.10 Run `make lint` and `make test`
- [x] 1.11 **Aguardar validação do desenvolvedor (R27a)**; só então commitar e abrir PR

---

## 2. Phase 2 — Data Layer & Network (branch: `feat-(N-37)/assistant-data-network`)

- [x] 2.1 Remote datasource contract `AssistantRemoteDataSource` and implementation calling `/api/assistants/**`
- [x] 2.2 DTO `AssistantInviteDto` with `fromJson` and `toJson` (R04)
- [x] 2.3 DTO `AssistantLeanSignupRequestDto` with `toJson`
- [x] 2.4 DTO `AssistantVanDto` with `fromJson` and `toJson`
- [x] 2.5 DTOs and mappers implemented adhering to R04
- [x] 2.6 Repository implementation `AssistantRepositoryImpl` mapping DTOs to Domain Entities
- [x] 2.7 Unit tests for `AssistantRemoteDataSource` and `AssistantRepositoryImpl` using `mocktail`
- [x] 2.8 Dependency Injection registration in `assistant_container.dart` (R03)
- [x] 2.9 Run `make lint` and `make test`
- [x] 2.10 **Aguardar validação do desenvolvedor (R27a)**; só então commitar e abrir PR

---

## 3. Phase 3 — Invite & Lean Registration UI (branch: `feat-(N-37)/assistant-invite-registration-ui`)

- [x] 3.1 Localizations in `lib/l10n/app_pt.arb` and `lib/l10n/app_en.arb` for invite entry, errors, and signup fields (R10)
- [x] 3.2 Regenerate localizations with `fvm flutter gen-l10n`
- [x] 3.3 State management `AssistantInviteCubit` and states with `bloc_test`
- [x] 3.4 Update entry points adding secondary action "Entrar como assistente" (LoginPage / AccountTypePage)
- [x] 3.5 Screen `AssistantInviteCodePage` with code input formatting and clear error states (invalid, expired, used)
- [x] 3.6 Screen `AssistantLeanSignupPage` with Name, Birth Date, Email, CPF, Password, Terms inputs (no driver-specific fields)
- [x] 3.7 Deep link listener integration for `vanep://assistant/invite?token=...`
- [x] 3.8 Widget tests for `AssistantInviteCodePage` and `AssistantLeanSignupPage`
- [x] 3.9 Run `make lint` and `make test`
- [x] 3.10 **Aguardar validação do desenvolvedor no emulador/aparelho (R27a)**; só então commitar e abrir PR

---

## 4. Phase 4 — Assistant Shell & Multi-Van Selection (branch: `feat-(N-37)/assistant-shell-van-selector`)

- [x] 4.1 State management `AssistantVanSelectorCubit` for active van selection (N:N support)
- [x] 4.2 Widget `AssistantVanSelectorSheet` to switch active van when linked to 2+ vans
- [x] 4.3 Widget `AssistantBottomNav` with icons only and `Semantics` labels: Rota, Alunos, Perfil
- [x] 4.4 Top-level `AssistantShell` hosting Rota, Alunos, and Perfil views
- [x] 4.5 Route guard preventing navigation to driver/client restricted paths
- [x] 4.6 Update `AuthGate` in `lib/app.dart` to branch `UserType.assistant` to `AssistantShell`
- [x] 4.7 Widget and flow tests for `AssistantShell` and `AuthGate`
- [x] 4.8 Run `make lint` and `make test`
- [x] 4.9 **Aguardar validação do desenvolvedor no emulador/aparelho (R27a)**; só então commitar e abrir PR

---

## 5. Phase 5 — Daily Route & Shared Checklist (branch: `feat-(N-37)/assistant-trip-checklist`)

- [x] 5.1 Entities and DTOs for trip stops and checklist items with `confirmed_by` attribution
- [x] 5.2 State management `AssistantChecklistCubit` with unit tests (`bloc_test`)
- [x] 5.3 Page `AssistantTodayRoutePage` showing stops, students, and active progress
- [x] 5.4 Page `AssistantStudentsListPage` with search and filter
- [x] 5.5 Widget `AssistantStudentCard` displaying student photo, name, school, and boarding badge
- [x] 5.6 Individual check-in action ("Confirmar embarque") recording `confirmed_by = assistant`
- [x] 5.7 Bulk drop-off action bar (`AssistantBulkActionBar`)
- [x] 5.8 Modal `AssistantNoShowModal` with reason selection ("Não compareceu")
- [x] 5.9 Link revocation detection: redirect to unlinked state if driver revokes access
- [x] 5.10 Slice tests and layout verification (ensuring touch targets >= 44px)
- [ ] 5.11 Run `make lint` and `make test`
- [ ] 5.12 **Aguardar validação final do desenvolvedor no aparelho (R27a)**; só então commitar e abrir PR

### Phase 4 — PR #103 review follow-up

- [x] Reconcile app composition, localization, and AuthGate tests with main (`1fdd977`).
- [x] Register the assistant navigation observer and name role-specific application routes; prevent restricted page construction and match nested paths.
- [x] Show van loading failures with a retry action instead of the unlinked state.
- [x] Reuse the shared school shift formatter, consolidate van selector opening, and use the same route tab/title label.
- [x] Adapt assistant UI to the current theme palette and typography API.
- [x] Add regression coverage for failed van loading, retry, restricted nested routes, and real application navigation.
- [x] Record latest developer test results via FVM: full suite **2,416 passed / zero failed** in 16m18s; negotiation route regression tests also passed independently.
- [x] Inspect updated full-suite coverage: **17,932 / 19,377 relevant lines (92.54%)**, above the 85% threshold.
- [x] Complete FVM code generation, lint (no issues), and full tests/coverage, per developer reports.
- [x] Include the FVM-resolved dependency lockfile used by the successful lint and full test run.
- [ ] Validate the review fixes on device/emulator and capture updated video/screenshots. Developer explicitly authorized early commit/push; manual validation remains pending.


### Phase 5 — PR #104 review follow-up

- [x] Merge main with Phase 4 fixes, preserving van load errors, shared shift labels, route guards, and regression tests.
- [x] Treat only `revokedInvite` as revocation; preserve route state on authentication errors.
- [x] Allow bulk drop-off selection and requests only for boarded students.
- [x] Ignore duplicate mutation requests while updating; freeze selection during the request and use its captured token set.
- [x] Discard stale route and mutation responses after switching or clearing the active van.
- [x] Replace private helper methods and adapt Phase 5 widgets to the main theme API.
- [x] Show route failures with retry instead of empty-route/empty-student states.
- [x] Add regression tests for review fixes, concurrent requests, van changes, and error/retry UI.
- [x] Check API contract against backend main: route/checklist endpoints are absent; record this as an unresolved integration dependency in `phase5-validation.md`.
- [x] Inspect VAN-68 (#121) and VAN-73 overlap; document composition and student-list ownership for dependent work.
- [x] Run static analysis with pinned Flutter 3.47.2: **No issues found** (15.8s).
- [x] Run focused tests outside the sandbox: developer reported **105 passed / zero failures** in **2m04s**.
- [ ] Confirm full CI tests and coverage with the updated branch.
- [ ] Publish the branch updates and obtain review before merging. Developer explicitly authorized publishing the mobile base with the backend dependency documented; device testing is deferred and focused tests have passed.
