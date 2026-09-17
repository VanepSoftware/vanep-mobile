## Why

The backend already supports the assistant role (#72: `AssistantModel`, `AssistantInviteService`, `AssistantLinkService`, and database tables `assistant` and `assistant_invite`). However, the mobile app currently lacks any support for assistants: there is no "Enter as assistant" option on the welcome screen (S01), no invitation code/deeplink acceptance flow, no lean registration screen for assistants, no dedicated shell/navigation, and no checklist operations for this profile.

In daily van transportation operations, the assistant (board monitor/helper) is the person who performs the vast majority of boarding/drop-off checklist updates while the driver is focused on driving safely. Without the assistant workflow in the app, this critical operational persona cannot participate in the trip lifecycle.

## What Changes

- **Welcome / Auth Entry (S01)**:
  - Add "Entrar como assistente" (Enter as assistant) action on `WelcomePage`, alongside client/driver login.
  - Dedicated invite code input screen with validation and friendly error messages for invalid, expired, already-used, or revoked codes.
  - Support receiving and handling deep links from email invitations (`vanep://assistant/invite?token=...` / universal links).
- **Lean Assistant Registration**:
  - Streamlined signup capturing only: Full Name, Age/Birth Date, Email, and CPF (omitting driver-specific fields like CNH, vehicle documents, and bank details).
  - Newly created account is automatically linked to the inviting driver's van/service.
- **Multi-Van Selection (N:N)**:
  - For assistants linked to multiple drivers/vans, provide an active van selector to choose which vehicle/route they are operating on for the day/shift.
- **Restricted Assistant Navigation & Shell**:
  - Dedicated `AssistantShell` with restricted bottom navigation (`AssistantBottomNav`), exposing only: Today's Route (`Rota`), Student List (`Alunos`), and Profile (`Perfil`).
  - Strict absence of driver-only sections: Proposals, Financials, and Vehicle/Driver Documents.
  - Navigation guards preventing access to restricted client/driver routes, including deep links.
- **Route Operation & Shared Checklist**:
  - Today's route overview displaying stops, students, and boarding status.
  - Checklist operation with individual check-in/drop-off, bulk check-in/check-out, and no-show ("marcar não comparecimento") with reasons.
  - Shared truth with the driver: checklist entries clearly display `confirmed_by` attribution (indicating whether the driver or the assistant recorded the event).
- **Revocation Handling**:
  - Immediate reflection of driver link revocations upon the next session check or API call, gracefully returning the assistant to an unlinked state.
- **Design & Usability**:
  - Consistent design system tokens (`VanepColors`, `VanepTypography`, `VanepTheme`).
  - Full internationalization in `lib/l10n/app_pt.arb` and `lib/l10n/app_en.arb`.
  - Minimum touch target >= 44px, loading/empty/error states for all views.

## Capabilities

### New Capabilities

- `assistant-auth-invite`: Entry point for assistants via invite code or deeplink, code validation, and lean registration linked to the inviting driver.
- `assistant-shell-navigation`: Dedicated shell, bottom navigation, and route guards enforcing role boundaries.
- `assistant-van-selection`: Selection and switching between linked vans/drivers for multi-van assistants.
- `assistant-trip-checklist`: Daily route view and shared boarding checklist operation with attribution (`confirmed_by`) and no-show recording.

### Modified Capabilities

- `auth`: Extend `WelcomePage` and session resolution in `AuthGate` to route authenticated assistants to `AssistantShell`.
- `l10n`: Add all assistant-related user-facing copy to Portuguese (`app_pt.arb`) and English (`app_en.arb`).

## Impact

- **New module**: `lib/modules/assistant/` following Clean Architecture (`data/`, `domain/`, `presentation/`, `assistant_container.dart`).
- **New shell**: `lib/shell/assistant_shell.dart` and `lib/shell/assistant_bottom_nav.dart`.
- **Existing files modified**:
  - `lib/modules/auth/presentation/pages/welcome_page.dart`: Add assistant entry button.
  - `lib/app.dart`: `AuthGate` branching for `UserType.assistant` into `AssistantShell`.
  - `lib/l10n/app_pt.arb` and `app_en.arb`: New strings for invite code, validation errors, van selection, and checklist.
- **Backend alignment**:
  - Consumes `/api/assistants/me`, `/api/assistants/me/invite/**`, and trip checklist endpoints.
