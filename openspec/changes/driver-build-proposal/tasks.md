## 1. Domain (branch: feat/driver-build-proposal — single PR)

- [x] 1.1 Write tests for the draft summary, price update, schedule grouping and send gates
- [x] 1.2 Add `ProposalComposeDraft`, the repository contract and `SendDriverProposal` / `LoadProposalCompose`
- [x] 1.3 Write tests for the prototype model: contract totals per installment, van seats, slot toggles, times, payment, conditions, message
- [x] 1.4 Extend `ProposalComposeDraft` with van, payment, slots, route times, conditions, message and validity

## 2. Data

- [x] 2.1 Write tests for the scenario datasource and the repository failure mapping
- [x] 2.2 Add the mocked compose datasource, `DRIVER_PROPOSAL_SCENARIO` and DI
- [x] 2.3 Update the sample family to the prototype (Família Andrade, Theo and Alice, R$ 5 commission)

## 3. Cubit and page

- [x] 3.1 Write cubit tests: load, failed reload keeps the draft, price change, send, refused send
- [x] 3.2 Write page tests: prices, schedule, summary, overdue pause, accepting-students block, send feedback
- [x] 3.3 Add localization and the compose page
- [x] 3.4 Host the page on the driver Proposals tab
- [x] 3.5 Cubit tests for van, slots, times, payment, conditions and message changes
- [x] 3.6 Rebuild the page to the prototype: header, van, price rows, summary, payment, grid, times, conditions, message, footer, edit sheets
- [x] 3.7 Extract `VanepSheetFrame` and `VanepRadioIndicator` to core; reuse in the client child filter sheet
- [x] 3.8 Run `make lint` and `make test`
- [x] 3.9 Manual verification on device before any commit (R27a)

## 4. Tooling

- [x] 4.1 Add `tool/docker/Dockerfile` and `make docker_lint`, `make docker_test`, `make preview`
- [x] 4.2 Add preview renders under `test/preview/` (skipped unless `VANEP_PREVIEW=1`)

## 5. Later

- [ ] 5.1 Replace the scenario datasource when a driver proposal endpoint exists
