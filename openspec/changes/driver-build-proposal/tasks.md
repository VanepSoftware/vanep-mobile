## 1. Domain (branch: feat/driver-build-proposal — single PR)

- [x] 1.1 Write tests for the draft summary, price update, schedule grouping and send gates
- [x] 1.2 Add `ProposalComposeDraft`, the repository contract and `SendDriverProposal` / `LoadProposalCompose`

## 2. Data

- [x] 2.1 Write tests for the scenario datasource and the repository failure mapping
- [x] 2.2 Add the mocked compose datasource, `DRIVER_PROPOSAL_SCENARIO` and DI

## 3. Cubit and page

- [x] 3.1 Write cubit tests: load, failed reload keeps the draft, price change, send, refused send
- [x] 3.2 Write page tests: prices, schedule, summary, overdue pause, accepting-students block, send feedback
- [x] 3.3 Add localization and the compose page
- [x] 3.4 Host the page on the driver Proposals tab
- [ ] 3.5 Run `make lint` and `make test`
- [ ] 3.6 Manual verification on device before any commit (R27a)

## 4. Later

- [ ] 4.1 Replace the scenario datasource when a driver proposal endpoint exists
