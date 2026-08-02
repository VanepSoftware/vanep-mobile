# Spec — Driver home screen

## Context

The driver-facing home screen is the first screen an authenticated driver sees.
It greets the driver, shows the current shift status, offers a primary action to
start/end the route, a placeholder card for the day's students, and a toggle to
share live location. Navigation between the driver's main areas is done through a
bottom navigation bar (Home, Proposals, Students, Profile).

It reuses the visual language of the client home (see `client-home-drivers.md`):
shared bottom navigation, greeting header, a light gradient background and a glass
card style, all promoted to `lib/core/ui/` so both audiences stay consistent.

## Goals

- Greet the signed-in driver by first name, with a shift subtitle.
- Show the shift status ("off shift" / "on shift").
- Provide a primary action that toggles the route (Start route / End route).
- Provide a toggle to share live location in real time.
- Reserve a card slot for "today's students" (empty for now — see Data source).
- Provide a bottom navigation bar (Home, Proposals, Students, Profile).

## Data source

**Blocked.** There is currently **no backend endpoint** for a driver's students.
`DependentModel` links a dependent to a `client`, a `school` and an `address`, but
has **no driver relationship**, and there is no `contract`/`proposal`/`route`
feature that would connect a driver to the students they transport. The only
students-like endpoint is `GET /api/dependent`, which returns the **authenticated
client's** dependents — not a driver's route.

Consequently, the students card is delivered **empty** and **no data is mocked**.
The runtime state (shift on/off, location sharing) is local UI state only; the shift
start time shown in the greeting subtitle is provided by the caller. When the backend
exposes a driver-students endpoint, a `domain` + `data` layer is added and the card is
filled with the real count ("X students today"), tappable into a full list.

## Non-goals (this change)

- Proposals, Students and Profile tabs are placeholders (Profile reuses the existing
  sign-out screen).
- Any students data (count or list) — blocked on the backend (see Data source).
- Role-based routing: the real app still routes authenticated users to `ClientShell`;
  routing a driver to `DriverShell` depends on the profile exposing an account type,
  which the backend does not return yet. A dev-only preview entrypoint
  (`lib/main_driver_preview.dart`) renders the shell for manual verification and is
  **not shipped** in any PR.

## Architecture (R01–R09)

Shared UI promoted to `lib/core/ui/`:

- `vanep_bottom_nav.dart` — floating pill bottom nav rendered from a list of items.
- `vanep_greeting_header.dart` — "Olá, {name}" with optional subtitle/emoji.
- `vanep_screen_background.dart` — light gradient background.
- `vanep_glass_card.dart` — translucent gradient card with border.

New feature module `lib/modules/driver/`:

- `driver_container.dart` — DI registration (`registerDriverHomeDependencies`).
- `presentation/cubit/driver_home_state.dart` — `DriverHomeState` (equatable).
- `presentation/cubit/driver_home_cubit.dart` — shift + location-sharing UI state.
- `presentation/pages/driver_home_tab.dart` — composes the home content.
- `presentation/widgets/driver_shift_badge.dart` — shift status pill.
- `presentation/widgets/driver_location_sharing_tile.dart` — label + `Switch`.

Shell:

- `shell/driver_shell.dart` — `IndexedStack` of the four tabs + bottom nav.
- `shell/driver_bottom_nav.dart` — driver nav items over `VanepBottomNav`.

No `domain`/`data` layer yet: there is no external data source (see Data source).
When the endpoint exists, add `domain/entities`, `domain/repositories`,
`domain/usecases`, `data/dtos`, `data/datasources`, `data/repositories` and inject the
use case into the cubit through `driver_container.dart`.

## Localization (R10)

All user-visible copy uses `AppLocalizations` (ARB files under `lib/l10n/`):
`driverShiftStartsAt`, `driverShiftOff`, `driverShiftOn`, `driverStartRoute`,
`driverEndRoute`, `driverShareLiveLocation`, `navProposals`, `navStudents`.

## Testing (R05)

- `driver_home_state_test.dart` — defaults, `onShift`, `copyWith`.
- `driver_home_cubit_test.dart` — `seedToday`, `startRoute`, `endRoute`,
  `setLocationSharing` (bloc_test).
- `driver_home_tab_test.dart` — greeting/subtitle, start-route toggles badge + button
  label, location toggle updates the cubit.
- `driver_shell_test.dart` — starts on Home, tab switches to Proposals/Students.

## Phased delivery (R16–R23)

Dependency order: shared UI → driver presentation → shell/wiring. Each phase is one PR,
under the 10-new-files cap, with its own tests. The dev-only preview entrypoint is
excluded from every PR.

| Phase | Contents | New files | Depends on | Parallel with |
|-------|----------|-----------|------------|---------------|
| 1 | Shared `core/ui` widgets (bottom nav, greeting, screen background, glass card) + color tokens; refactor `ClientBottomNav` and `drivers_home_tab` to use them; delete `client_greeting_header.dart` | 4 | — | — |
| 2 | Driver presentation module (state, cubit, tab, shift badge, location tile) + `driver_container.dart` + driver l10n strings + tests | 6 + 3 tests | Phase 1 merged | — |
| 3 | `DriverShell` + `DriverBottomNav` + `main.dart` DI wiring + shell test | 2 + 1 test | Phase 2 merged | — |
