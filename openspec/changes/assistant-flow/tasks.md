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

- [ ] 3.1 Localizations in `lib/l10n/app_pt.arb` and `lib/l10n/app_en.arb` for invite entry, errors, and signup fields (R10)
- [ ] 3.2 Regenerate localizations with `fvm flutter gen-l10n`
- [ ] 3.3 State management `AssistantInviteCubit` and states with `bloc_test`
- [ ] 3.4 Update `WelcomePage` adding secondary action "Entrar como assistente"
- [ ] 3.5 Screen `AssistantInviteCodePage` with code input formatting and clear error states (invalid, expired, used)
- [ ] 3.6 Screen `AssistantLeanSignupPage` with Name, Birth Date, Email, CPF inputs (no driver-specific fields)
- [ ] 3.7 Deep link listener integration for `vanep://assistant/invite?token=...`
- [ ] 3.8 Widget tests for `AssistantInviteCodePage` and `AssistantLeanSignupPage`
- [ ] 3.9 Run `make lint` and `make test`
- [ ] 3.10 **Aguardar validação do desenvolvedor no emulador/aparelho (R27a)**; só então commitar e abrir PR

---

## 4. Phase 4 — Assistant Shell & Multi-Van Selection (branch: `feat-(N-37)/assistant-shell-van-selector`)

- [ ] 4.1 State management `AssistantVanSelectorCubit` for active van selection (N:N support)
- [ ] 4.2 Widget `AssistantVanSelectorSheet` to switch active van when linked to 2+ vans
- [ ] 4.3 Widget `AssistantBottomNav` with icons only and `Semantics` labels: Rota, Alunos, Perfil
- [ ] 4.4 Top-level `AssistantShell` hosting Rota, Alunos, and Perfil views
- [ ] 4.5 Route guard preventing navigation to driver/client restricted paths
- [ ] 4.6 Update `AuthGate` in `lib/app.dart` to branch `UserType.assistant` to `AssistantShell`
- [ ] 4.7 Widget and flow tests for `AssistantShell` and `AuthGate`
- [ ] 4.8 Run `make lint` and `make test`
- [ ] 4.9 **Aguardar validação do desenvolvedor no emulador/aparelho (R27a)**; só então commitar e abrir PR

---

## 5. Phase 5 — Daily Route & Shared Checklist (branch: `feat-(N-37)/assistant-trip-checklist`)

- [ ] 5.1 Entities and DTOs for trip stops and checklist items with `confirmed_by` attribution
- [ ] 5.2 State management `AssistantChecklistCubit` with unit tests (`bloc_test`)
- [ ] 5.3 Page `AssistantTodayRoutePage` showing stops, students, and active progress
- [ ] 5.4 Page `AssistantStudentsListPage` with search and filter
- [ ] 5.5 Widget `AssistantStudentCard` displaying student photo, name, school, and boarding badge
- [ ] 5.6 Individual check-in action ("Confirmar embarque") recording `confirmed_by = assistant`
- [ ] 5.7 Bulk drop-off action bar (`AssistantBulkActionBar`)
- [ ] 5.8 Modal `AssistantNoShowModal` with reason selection ("Não compareceu")
- [ ] 5.9 Link revocation detection: redirect to unlinked state if driver revokes access
- [ ] 5.10 Slice tests and layout verification (ensuring touch targets >= 44px)
- [ ] 5.11 Run `make lint` and `make test`
- [ ] 5.12 **Aguardar validação final do desenvolvedor no aparelho (R27a)**; só então commitar e abrir PR
