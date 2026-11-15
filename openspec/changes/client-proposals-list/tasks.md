## 1. Core extractions (branch: feat/42-client-proposals — single PR)

- [x] 1.1 Move `VanepPersonAvatar`, `VanepAvatarStack`, `initialsOf`, `formatMoney`, `calendarDaysBetween`, `SchoolShift`, `formatShift` and `findAgeInYears` to `lib/core`
- [x] 1.2 Add `VanepSegmentedControl` to `lib/core/ui`

## 2. Domain

- [x] 2.1 Write tests for `ProposalsBoard` (filter by child, counts, child summary) and `LoadClientProposals`
- [x] 2.2 Create `ClientProposalsRepository` contract and `ClientProposalsFailure`
- [x] 2.3 Create value objects: `ProposalChild`, `PendingProposal`, `SentRequest`, `ClosedProposal`, `ProposalsBoard`
- [x] 2.4 Implement `LoadClientProposals`

## 3. Data

- [x] 3.1 Write tests for the repository, the dependents-based children source and the scenarios
- [x] 3.2 Implement the empty and scenario data sources, the children source and the repository
- [x] 3.3 Add `CLIENT_PROPOSALS_SCENARIO` to `Environment` and `.env.example`; register `ClientProposalsContainer`

## 4. Cubit

- [x] 4.1 Write `bloc_test` cases: loading, ready, failure, reload keeps content, select child, select tab
- [x] 4.2 Implement `ClientProposalsCubit` and `ClientProposalsState`

## 5. Page

- [x] 5.1 Write widget tests: pending and awaiting cards, closed tab, cap line, filter hidden with one child, filter sheet, empty and error states
- [x] 5.2 Add localization keys (pt-BR and en)
- [x] 5.3 Implement the page, cards and filter sheet
- [x] 5.4 Wire the Home entry points and `ClientShell`
- [x] 5.5 Run `make lint` and `make test`
- [ ] 5.6 Manual verification on device before any commit (R27a)

## 6. Later

- [ ] 6.1 Real API wiring when api-java #30 lands
