## Why

The driver proposals tab is still a coming-soon placeholder. The approved flow (Motorista → Propostas · 3. Montar proposta, `moto-propostas-3-montar`) is where the driver answers one family's request: picks the van, prices each student, sets payment and period, confirms days and legs, adjusts route times and conditions, and sees the Vanep commission next to the amount they receive. There is no proposal endpoint yet, and two gates have no screen of their own: an overdue invoice pauses sending, and turning off "Accepting new students" blocks building a proposal.

## What Changes

- The driver Proposals tab opens **Nova proposta** for one family: one contract, one price line per student.
- Van picker with the shift's free seats and capacity.
- Summary for the whole contract: family total, Vanep commission (R$ 5 per month) and amount received, each with its per-installment value.
- Payment (installments and due day) and contract period are editable.
- Days and legs grid (Mon–Fri × outbound/return) starts from the family's request and can be toggled.
- Route times (pickup window, school arrival, school departure, wait at the stop) come from the route and can be edited.
- Conditions (reservation fee, readjustment, cancellation) start from the driver's defaults and can be edited for this proposal.
- Optional message to the family, validity note and a sticky footer with the total and the send button.
- Sending is refused while an invoice is overdue. The form stays visible and the send action stays disabled.
- The form is replaced by a block message when the driver is not accepting new students.
- Mocked compose data, selected by `DRIVER_PROPOSAL_SCENARIO`, until a proposal endpoint exists.
- Dev tooling: a Docker image with the pinned Flutter and `make preview`, which renders the screen states to PNG without an emulator or backend.

## Capabilities

### New Capabilities

- `driver-build-proposal`: the driver compose screen, its contract summary, schedule, times, conditions and the two send gates.

### Modified Capabilities

## Impact

- Code: `lib/modules/driver_proposals/`, `DriverShell` proposals tab, `app.dart` and `main.dart` wiring, `Environment`, `.env.example`, localization, shared sheet chrome and weekday short names in `lib/core/`.
- Tooling: `tool/docker/Dockerfile`, `Makefile` targets, `test/preview/`.
- Backend: none yet. api-java has contracts (one contract, items per dependent, schedule slots) but no proposal compose endpoint. The screen depends on a domain contract so the data source can be swapped later.
- Not in this change: the proposals list (screens 1 and 2), negotiation, or the settings screens that toggle "Accepting new students", the driver's default conditions and invoices. Those arrive as data on the compose draft.
