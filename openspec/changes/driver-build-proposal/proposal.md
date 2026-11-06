## Why

The driver proposals tab is still a coming-soon placeholder. The approved flow (Motorista → Propostas · 3. Montar proposta) is where the driver prices each student, reviews the route schedule and the driver's standard conditions, and sees the Vanep commission next to the amount they receive. There is no proposal endpoint yet, and two gates have no screen of their own: an overdue invoice pauses sending, and turning off "Accepting new students" blocks building a proposal.

## What Changes

- The driver Proposals tab opens **Montar proposta** for one family: one contract, one price line per student.
- The schedule is read-only, grouped by weekday and route leg, with times that come from the route.
- Standard conditions (due day and notes) are shown as the driver's defaults.
- A summary shows what the family pays, the Vanep commission and what the driver receives.
- Sending is refused while an invoice is overdue. The form stays visible and the send action stays disabled.
- The form is replaced by a block message when the driver is not accepting new students.
- Mocked compose data, selected by `DRIVER_PROPOSAL_SCENARIO`, until a proposal endpoint exists.

## Capabilities

### New Capabilities

- `driver-build-proposal`: the driver compose screen, its money summary, the route schedule and the two send gates.

### Modified Capabilities

## Impact

- Code: new `lib/modules/driver_proposals/`, `DriverShell` proposals tab, `app.dart` and `main.dart` wiring, `Environment`, `.env.example`, localization.
- Backend: none yet. api-java has contracts (one contract, items per dependent, schedule slots) but no proposal compose endpoint. The screen depends on a domain contract so the data source can be swapped later.
- Not in this change: the proposals list (screens 1 and 2), negotiation, or the settings screens that toggle "Accepting new students" and invoices. Those gates arrive as data on the compose draft.
