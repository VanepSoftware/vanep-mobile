## Why

The client has no way to see the proposals drivers sent, nor the quote requests still waiting for a driver. The approved design (Genwork VAN-42 / Linear VAN-97, pages "Responsável → Propostas · 1. Lista" and "4. Filtrar por filho") defines an internal Proposals screen opened from the Home shortcut, from "Needs you", from push and from the chat. The backend has no proposal or quote-request endpoints yet (api-java #30), so the screen is built against a domain contract with mocked data, like the Home (VAN-41).

## What Changes

- New internal **Proposals** page with:
  - a child filter button ("All children ▾", stacked avatars) that opens a bottom sheet with one radio per child and their open counts; hidden when the client has a single child;
  - an Open / Closed segmented control with the counts of each tab;
  - an "n of 5 open requests" line (the account-wide cap of open requests);
  - **Open** tab grouped by what the client must do: "Pending" (proposals to answer: driver, rating or "new on Vanep", vehicle, child, school and shift, weekdays and start date, monthly fee, previous fee when the driver lowered it, expiry, "Chat" and "See proposal") and "Awaiting reply" (requests sent to drivers: child, when it was sent, hours left, "Cancel request" and "See request");
  - **Closed** tab listing finished proposals with their outcome;
  - empty, loading (skeleton) and error-with-retry states.
- Entry points: Home "Proposals" shortcut, "Needs you" proposal items and the "See proposals" action of the negotiating card.
- Shared pieces move to `lib/core` so both modules use them without importing each other: person avatar and avatar stack, money formatter, calendar-day difference, school shift and its label, age from birth date.
- Mocked data selected by `CLIENT_PROPOSALS_SCENARIO`; with it empty, the page shows the real dependents and no proposals.
- Not in scope: proposal detail (VAN-43), negotiation in the chat (VAN-44), cancelling a request on the backend, push.

## Capabilities

### New Capabilities
- `client-proposals`: the client Proposals list — grouping, tabs, child filter, open-request cap and the repository contract feeding it.

### Modified Capabilities

## Impact

- Code: new `lib/modules/client_proposals/`, `lib/shell/client_shell.dart` and `lib/app.dart` (navigation), `lib/modules/client_home/presentation` (entry points, shared pieces moved to core), `lib/core/{ui,formatters,domain}`, `lib/l10n/*.arb`, `Environment`, `.env.example`, DI.
- Backend dependency for the real wiring: proposals and quote requests (api-java #30).
