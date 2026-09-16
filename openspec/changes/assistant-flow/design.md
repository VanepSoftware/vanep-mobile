# Design: Assistant Profile & Operations Flow in Mobile

## Context & Problem Statement

The backend already contains the core domain model and services for the assistant persona (`AssistantModel`, `AssistantInviteService`, `AssistantLinkService`, and `trip` execution with checklist records). However, the mobile application has no entry point, screens, or state management for assistants.

The assistant persona has unique constraints:
1. **No self-signup**: Assistants cannot register autonomously; registration requires a valid driver invitation code or deep link.
2. **Restricted scope**: Assistants are operational companions on the van. They must never see driver financials, contract proposals, or private documents.
3. **Shared truth**: The checklist state during a trip is shared with the driver. When an assistant checks in a student, the driver sees that update with attribution (`confirmed_by`).
4. **Multi-van assignment**: An assistant may be linked to multiple vans (N:N relationship) and must select which van they are operating on for any given shift.

## Architectural Decisions

### D1: Modular Clean Architecture (`lib/modules/assistant/`)
Following Constitution rule R01 and R02, all assistant-specific logic lives under `lib/modules/assistant/`:
```
lib/modules/assistant/
├── assistant_container.dart
├── data/
│   ├── datasources/
│   │   └── assistant_remote_datasource.dart
│   ├── dtos/
│   │   ├── assistant_invite_validation_dto.dart
│   │   ├── assistant_lean_signup_request_dto.dart
│   │   ├── assistant_van_summary_dto.dart
│   │   └── assistant_trip_checklist_dto.dart
│   ├── mappers/
│   │   └── assistant_failure_mapper.dart
│   └── repositories/
│       └── assistant_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── assistant_invite.dart
│   │   ├── assistant_van.dart
│   │   ├── assistant_trip_stop.dart
│   │   └── assistant_checklist_item.dart
│   ├── failures/
│   │   └── assistant_failure.dart
│   ├── repositories/
│   │   └── assistant_repository.dart
│   ├── usecases/
│   │   ├── validate_assistant_invite.dart
│   │   ├── register_assistant_with_invite.dart
│   │   ├── get_linked_vans.dart
│   │   ├── get_active_trip_route.dart
│   │   ├── update_checklist_status.dart
│   │   └── record_no_show.dart
│   └── value_objects/
│       └── confirmation_source.dart
└── presentation/
    ├── cubit/
    │   ├── assistant_invite_cubit.dart
    │   ├── assistant_van_selector_cubit.dart
    │   └── assistant_checklist_cubit.dart
    ├── pages/
    │   ├── assistant_invite_code_page.dart
    │   ├── assistant_lean_signup_page.dart
    │   ├── assistant_van_selector_sheet.dart
    │   ├── assistant_today_route_page.dart
    │   └── assistant_students_list_page.dart
    └── widgets/
        ├── assistant_student_card.dart
        ├── assistant_bulk_action_bar.dart
        ├── assistant_no_show_modal.dart
        └── assistant_confirmed_badge.dart
```

### D2: Dedicated Shell & Navigation (`lib/shell/`)
Rather than branching within `DriverShell`, we follow single-responsibility and create:
- `lib/shell/assistant_shell.dart`: Top-level scaffold hosting only Rota (`TodayRoutePage`), Alunos (`StudentsListPage`), and Perfil (`ProfilePage`).
- `lib/shell/assistant_bottom_nav.dart`: Icon-only bottom navigation bar compliant with the project's accessibility and visual standards.
- `AuthGate` in `lib/app.dart` maps `UserType.assistant` directly to `AssistantShell`.

### D3: Route Guard for Restricted Endpoints
Any attempt to access unauthorized paths (e.g. driver proposals, documents, client booking) triggers a guard interceptor that logs the violation, informs the user via `VanepFeedback.showError(context, l10n.unauthorizedAccess)`, and redirects to the assistant root.

### D4: Lean Registration & Pre-linked Invite Token
The signup flow passes the validated `inviteToken` along with the minimal payload (`name`, `birthDate`, `email`, `cpf`) to the backend registration endpoint, immediately establishing the link to the driver's van.

### D5: Single Source of Truth for Trip Checklist
Checklist entries mirror the driver trip state:
- Real-time or polling refresh ensures synchronization.
- Every entry maintains `confirmedBy` (driver name or assistant name) so both parties have full transparency over who completed each check-in.

### D6: Deep Link Integration
The app parses deep links conforming to `vanep://assistant/invite?token=...` or universal links matching `https://vanep.com.br/assistant/invite/*`. On cold or warm start, if an invite token is detected, navigation pushes `AssistantInviteCodePage` pre-populated with the token.

## Testing Strategy
- Unit tests for all UseCases, Repositories, and Cubits using `mocktail` and `bloc_test`.
- Fixtures and mocks isolated in `test/modules/assistant/fixtures/` and `mocks/`.
- Widget slice tests for `AssistantInviteCodePage`, `AssistantShell`, and `AssistantTodayRoutePage`.
- Strict verification with `make lint` (`flutter analyze --fatal-infos`) and `make test`.
