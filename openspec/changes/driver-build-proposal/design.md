## Context

The driver shell's Proposals tab renders a coming-soon view. The client proposals module already shows how a screen ships against a repository contract with a scenario datasource while the API is missing. Contracts on the backend are one per client-driver link, with one item per dependent and schedule slots per weekday and route leg. Vanep commission is a per-contract amount (R$ 1 to R$ 5), not a percentage.

The compose prototype lives behind a signed-in Claude artifact. This change follows the written screen rules and the app's existing cards, fields, buttons and typography.

## Goals / Non-Goals

**Goals:**

- Let the driver assemble one family proposal: price per student, route schedule, standard conditions, commission versus amount received.
- Enforce the two gates in the domain so the UI cannot send around them.
- Keep the proposals list, invoice screen and "accepting students" switch out of this change.

**Non-Goals:**

- Screens 1 and 2 of driver proposals.
- A real proposal API, invoice ledger or driver settings.

## Decisions

- **Module `lib/modules/driver_proposals/`.** Presentation reads a cubit. The draft, the money summary and `canSend` live on `ProposalComposeDraft`. Send gates are decided by `SendDriverProposal` before the repository is called.
- **One contract, many lines.** The draft is one family. Each student is a line with a monthly amount in cents. The commission is a single amount on the draft. Received amount is family total minus commission. Sending requires every line above zero, a positive amount received and no active gate.
- **Schedule is not edited.** Slots carry weekday, leg (outbound or return) and minutes from midnight. The page groups them with `groupProposalSchedule`. Times are display-only.
- **Conditions are the driver's defaults.** Due day and notes are read-only on this screen. Changing the defaults belongs to a later settings screen.
- **Gates are states of the draft, not routes.** `overdueInvoice` keeps the form and disables send. `notAcceptingStudents` hides the form and the send button.
- **Mock until the endpoint exists.** `ScenarioProposalComposeDataSource` is the only data source. `DRIVER_PROPOSAL_SCENARIO` selects `overdueInvoice`, `notAcceptingStudents` or `loadFailed`. Empty means an open sample family.
- **Tab hosts the screen.** The proposals list does not exist yet, so the Proposals tab is this page. A later list can push it.

### PR plan

Single branch `feat/driver-build-proposal`, one screen, no commit until manual device check (R27a). Layer order inside the branch follows R24.

| PR | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Domain, scenario data, cubit, compose page, proposals tab, l10n, tests | — | — |
| 2 | Real proposal endpoint | 1 + backend | — |

## Risks / Trade-offs

- [Mocked family drifts from the API] → only the datasource changes when the endpoint lands.
- [The prototype layout could not be opened without a Claude sign-in] → the screen uses the existing design-system cards, read-only fields and primary button, and the behaviours named in the request.
