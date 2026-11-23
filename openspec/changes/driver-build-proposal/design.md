## Context

The driver shell's Proposals tab renders a coming-soon view. The client proposals module already shows how a screen ships against a repository contract with a scenario datasource while the API is missing. Contracts on the backend are one per client-driver link, with one item per dependent and schedule slots per weekday and route leg. The Vanep commission is a fixed amount per contract per month: R$ 5.

The layout follows the prototype screen `moto-propostas-3-montar` (header, van, prices, summary, payment, days and legs, times, conditions, message, sticky footer).

## Goals / Non-Goals

**Goals:**

- Let the driver assemble one family proposal: van, price per student, payment, period, days and legs, route times, conditions and message.
- Show the contract total, the commission and the amount received, also per installment.
- Enforce the two gates in the domain so the UI cannot send around them.
- Let a developer see the screen states without an emulator, a backend or a local Flutter install.

**Non-Goals:**

- Screens 1 and 2 of driver proposals.
- A real proposal API, invoice ledger or the driver settings that own default conditions.

## Decisions

- **Module `lib/modules/driver_proposals/`.** Presentation reads a cubit. The draft, the money summary and `canSend` live on `ProposalComposeDraft`. Send gates are decided by `SendDriverProposal` before the repository is called.
- **One contract, many lines.** The draft is one family. Each student is a line with a monthly amount in cents. `commissionCents` is per month. Totals multiply the monthly amounts by `payment.installments`. Received = family total − commission total.
- **Schedule is a set of (weekday, leg) slots.** The draft keeps `requestedSlots` (from the family's request) and `slots` (what the driver offers). The grid toggles `slots`; "as requested" is `slots == requestedSlots`. Each student's legs label derives from `slots`, so there is one source.
- **Times are one value object.** `ProposalRouteTimes` holds pickup start and end, school arrival, school departure (minutes from midnight) and wait minutes. The route provides the first value; the edit sheet replaces it whole.
- **Conditions are typed.** Reservation fee and readjustment are enums; cancellation is notice days plus a penalty percent. They load from the driver's defaults and are edited per proposal through a sheet with fixed options.
- **Payment** holds installments (1–12), due day and period start and end dates. Installments and due day are picked in a sheet; the period uses the platform date range picker.
- **Gates are states of the draft, not routes.** `overdueInvoice` keeps the form and disables send. `notAcceptingStudents` hides the form and the footer. Not enough free seats is a validation, not a gate: it shows a warning and keeps send disabled.
- **Sheets share core chrome.** `VanepSheetFrame` (handle, title, close) and `VanepRadioIndicator` move to `lib/core/ui/` and the client child filter sheet uses them too.
- **Mock until the endpoint exists.** `ScenarioProposalComposeDataSource` is the only data source. `DRIVER_PROPOSAL_SCENARIO` selects `overdueInvoice`, `notAcceptingStudents` or `loadFailed`. Empty means an open sample family.
- **Tab hosts the screen.** The proposals list does not exist yet, so the Proposals tab is this page. The back arrow shows only when the page was pushed. A later list can push it.
- **Preview renders.** `test/preview/` holds widget tests that only run with `VANEP_PREVIEW=1` and write PNGs of each state to `preview/` (git-ignored) with real fonts. `make preview` runs them in `tool/docker/Dockerfile`, which pins the Flutter version of `.fvmrc`.

### PR plan

Single branch `feat/driver-build-proposal`, one screen, no commit until manual device check (R27a). Layer order inside the branch follows R24.

| PR | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Domain, scenario data, cubit, compose page and sheets, proposals tab, l10n, tests, preview tooling | — | — |
| 2 | Real proposal endpoint | 1 + backend | — |

## Risks / Trade-offs

- [Mocked family drifts from the API] → only the datasource changes when the endpoint lands.
- [PR 1 is above the R23 size cap] → accepted for one screen; the tooling can be split into its own PR if review asks.
- [Preview PNGs are rendered by the test engine] → close to the device, not identical (no platform text shaping); the device check stays mandatory.
