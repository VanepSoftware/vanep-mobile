## Context

The Home (VAN-41) already shows proposal items and a Proposals shortcut that open a coming-soon page. The backend has dependents, `client_driver`, contracts and conversations, but no proposals or quote requests. The mobile rules require spec first, shared UI in `lib/core`, no cross-module imports outside domain contracts and mocked data marked with a TODO (R40b).

## Goals / Non-Goals

**Goals:**
- Ship the Proposals list and the child filter exactly as designed, behind a domain contract.
- Keep the children on real data (dependents API) whenever no scenario is selected.
- Swap the mocked proposals for the API without touching presentation.

**Non-Goals:**
- Proposal detail, negotiation in the chat, request cancellation on the backend.

## Decisions

- **New module `lib/modules/client_proposals/`** (R02) with `domain/`, `data/`, `presentation/`.
- **Read model as value objects.** `ProposalsBoard` holds `children`, `pending` (proposals to answer), `awaiting` (requests sent) and `closed`. It owns the derivations: `forChild(token)` filters every list, `openCount`, `summaryFor(child)`. Presentation never re-filters (R06a).
- **Two data sources behind one repository.** `ProposalsDataSource` (proposals) and `ProposalChildrenDataSource` (children). Production: an empty proposals source and the children from `FindMyDependents`. Scenario: one mocked class implements both, so the children match the mocked proposals.
- **Open-request cap.** `openRequestsLimit = 5` lives in domain; the count is account-wide (not filtered by child) because the cap is per account.
- **Cubit owns the selection.** `ClientProposalsCubit` keeps the board, the selected child and the selected tab; the visible lists are getters over the board.
- **Shared UI in core.** `VanepPersonAvatar`, `VanepAvatarStack` (now with a "+n" bubble) and `VanepSegmentedControl` live in `lib/core/ui`; `formatMoney`, `formatShift`, `calendarDaysBetween`, `findAgeInYears` and `SchoolShift` move to `lib/core`.
- **Navigation.** `app.dart` exposes `openClientProposals`; `ClientShell` passes it to the Home as `onProposalsTapped`. Actions that depend on unbuilt screens (chat negotiation, proposal detail, request detail and cancel) open the coming-soon page.

### PR plan

Single PR (branch `feat/42-client-proposals`, based on `feat/41-client-home` because it reuses the Home), following the VAN-41 decision. Layer order inside the PR follows R24.

| PR | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Core extractions, domain, data (empty + scenario), cubit, page and filter sheet, Home entry points, l10n, tests | VAN-41 (#114) | — |
| 2 | Real API wiring | 1 + api-java #30 | — |

## Risks / Trade-offs

- [Mocked shape drifts from the API] → only the data sources change when the endpoint lands.
- [Branch stacked on #114] → rebase onto `main` after #114 merges.
