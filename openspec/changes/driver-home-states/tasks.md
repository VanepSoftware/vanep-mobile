# Driver Home states — VAN-66 / imported VAN-120

The delivery direction (domain → data → presentation) and the tested Home behavior were approved by the developer. This change extracts the existing reviewed implementation into smaller PRs; the original PR #146 remains available until replacement is complete.

## Dependencies and layer assignment

Domain contracts/rules → API adapters → localized UI primitives → cards/shortcuts → controller and shell integration → acceptance evidence.

| PR | Contents | Depends on | Parallel with |
| --- | --- | --- | --- |
| 1 | Domain entities, value objects, repository contract, rules and tests | — | — |
| 2 | DTOs, remote datasource, repository implementation, endpoints and adapter tests | PR 1 merged | — |
| 3 | ARB messages, shared card style, slide control, fixtures and component tests | PR 2 merged | — |
| 4 | Main card and fixed shortcuts, callback-based actions and widget tests | PR 3 merged | — |
| 5 | Cubit/state, Home composition, DI, shell integration and focused tests | PR 4 merged | — |
| 6 | Remaining acceptance tests and isolated preview with simulated data | PR 5 merged | — |

Presentation boundaries are provisional until measured against each predecessor. Split a phase further if it exceeds 600 productive lines or 10 new files. Each phase must compile and pass its relevant tests independently. Preserve existing main features during integration; do not replace main files wholesale from #146.

## Phase 1 — Domain (`feat/VAN-66-home-domain`)

- [x] 1.1 Extract the unchanged domain tests first from the validated branch.
- [x] 1.2 Extract registration/trip/shortcut/stop value objects and Home entities.
- [x] 1.3 Extract the repository contract and Home rules without data/presentation dependencies.
- [x] 1.4 Generate existing project DTO code, run static analysis and domain tests on current main (12 tests passed; analyze with fatal infos passed).
- [ ] 1.5 Open the domain PR and wait for review/merge before preparing phase 2.

## Phase 2 — Data (`feat/VAN-66-home-data`)

- [ ] 2.1 Extract adapter tests, then DTOs, datasource and repository implementation.
- [ ] 2.2 Preserve main endpoint definitions and reject unresolved trip shifts.
- [ ] 2.3 Keep stop confirmation unsupported until its backend contract exists.
- [ ] 2.4 Run code generation, analysis and adapter tests; measure diff and open PR.

## Phase 3 — Presentation primitives (`feat/VAN-66-home-primitives`)

- [ ] 3.1 Extract localization, shared card error styling and slide control with tests.
- [ ] 3.2 Extract test fixtures and verify full-drag-only confirmation.
- [ ] 3.3 Run analysis/component tests, measure diff and open PR.

## Phase 4 — Cards and shortcuts (`feat/VAN-66-home-cards`)

- [ ] 4.1 Decouple main-card actions from the concrete Cubit through callbacks.
- [ ] 4.2 Deliver main-card states and six fixed shortcuts with widget tests.
- [ ] 4.3 Run analysis/widget tests, measure diff and open PR.

## Phase 5 — Home integration (`feat/VAN-66-home-integration`)

- [ ] 5.1 Integrate Cubit/state, Home and DI without removing current main navigation.
- [ ] 5.2 Update existing Home/shell tests in the same phase; keep all phases compilable.
- [ ] 5.3 Verify RN-02, block banner during active trips and outside-hours advisory.
- [ ] 5.4 Run analysis/integration tests, measure diff and open PR.

## Phase 6 — Acceptance (`feat/VAN-66-home-acceptance`)

- [ ] 6.1 Add complete nine-state acceptance coverage and localized simulated preview.
- [ ] 6.2 Repeat device validation if integration changes affect behavior.
- [ ] 6.3 Attach the developer video with its simulated-data context and retain separate real API evidence.
- [ ] 6.4 Run analysis/tests, measure diff and open PR; close #146 only after all replacements are accounted for.

## API limitations

Next stop/contact, stop confirmation, real driver-student count and family app membership remain backend dependencies. Unknown family membership stays null; known values include 100% (D12). Full destination screens are separate features. The simulated preview must never become the production entrypoint.
