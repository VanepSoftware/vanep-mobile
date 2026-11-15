## Why

The client (guardian) Home tab only shows a greeting and a "no linked van" card. The approved design (Genwork VAN-41 / Linear VAN-96) defines a day-oriented Home with three fixed blocks and seven states. Most data for those states (daily route, live van, proposals, installments) has no backend yet, so the UI must be built now against a domain contract with a fake data source and wired to the API state by state as endpoints land.

## What Changes

- Replace the body of `ClientHomeTab` with three fixed blocks, always in this order:
  1. **Today** — grouped by van (not by child); siblings on the same van share one card; the first/live van is expanded, others collapse to a row.
  2. **Needs you** — at most 3 items ordered by priority (short deadline > new proposal > payment > renewal/rating/document); beyond 3, a "See all" action.
  3. **Shortcuts** — always the same six (report absence, see on map, adjust stop, payments, proposals, contracts); unusable ones are disabled or open the existing coming-soon surface.
- Implement the seven Home states: first access, negotiating without a van, everything at once, before route (multi-van), van on the way (live), arrived at school, no route today.
- Introduce a `client_home` module with a domain `ClientHomeRepository` contract and a fake implementation used until real endpoints exist.
- Real data from day one only for: greeting, first-access steps (profile/address/dependents) and the existing "no linked van" state.
- All copy through ARB localization (pt-BR and en).
- Not in scope: new backend endpoints, screens behind the shortcuts, push/notifications, the SUSPENDED-contract red item (design not available yet).

## Capabilities

### New Capabilities
- `client-home`: the client Home tab — fixed blocks, the seven states, "Needs you" prioritization and cap, shortcut availability rules, and the repository contract feeding them.

### Modified Capabilities

## Impact

- Code: `lib/modules/client/` (home tab and widgets), new `lib/modules/client_home/`, `lib/shell/client_shell.dart` (wiring), `lib/l10n/*.arb`, DI registration.
- Reuses `VanepCard`, `VanepPrimaryButton`, `VanepAvatar`, `VanepComingSoon`, `NoLinkedVanCard`, `VanepGreetingHeader`.
- Backend dependencies for later PRs (not blockers for the first two): proposals (api-java #30), contract generation/signing (#31/#32), daily route and live trip, payments (#17).
- No new packages expected; live map block is rendered as a placeholder.
