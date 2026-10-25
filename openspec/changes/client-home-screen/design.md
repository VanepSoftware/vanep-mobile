## Context

`ClientHomeTab` ([client_home_tab.dart](../../../lib/modules/client/presentation/pages/client_home_tab.dart)) renders a greeting and `NoLinkedVanCard`. The design defines seven Home states built from three fixed blocks. The backend has client, dependent, `client_driver`, read-only contract and conversation; it has no proposal, daily route, live trip, absence, stop change or payment endpoints. Mobile rules require spec first, one dependency layer per PR, no interface and implementation in the same PR, and no commit before manual device verification.

## Goals / Non-Goals

**Goals:**
- Ship the full Home UI for the seven states behind a domain contract.
- Let each state move from fake to real data without touching presentation.
- Keep first access and "no linked van" on real data from the first PR.

**Non-Goals:**
- Backend endpoints, live map integration, push/notifications.
- Destination screens of the shortcuts.
- The SUSPENDED-contract item (no design yet).

## Decisions

- **New module `lib/modules/client_home/`** (R02) with `domain/`, `data/`, `presentation/`. The existing widgets in `modules/client/presentation` stay and `ClientHomeTab` is moved/extended under the new module in the same PR that changes it (R29), to avoid two homes.
- **One aggregate state, not seven screens.** The repository returns `ClientHomeState` (entity) composed of: `greeting context`, `todaySection`, `needsYouItems`, `shortcuts`. Seven UI states are different values of this one entity, so presentation has a single mapping (R06a). `todaySection` is a sealed type: `FirstSteps`, `NoVanNegotiating`, `NoLinkedVan`, `VanGroups`, `NoRouteToday`, `Arrived`.
- **Prioritization lives in domain.** A `PrioritizeNeedsYouItems` use case sorts by priority and caps at 3 (the rest count feeds "See all"). Presentation never re-sorts.
- **Fake repository in `data/`, selected in `ClientHomeContainer`.** A fake can be switched by scenario through a fixture enum, which also drives widget tests and manual verification of each state. When real endpoints land, a remote datasource replaces the fake per section (composite repository: real for first steps and linked-van, fake for the rest until each endpoint exists).
- **First steps derive from existing sources.** Address from the personal address module and dependents from `DependentsCubit`'s repository, through domain contracts; no new endpoint. Alternative considered: reading cubits from the shell — rejected, it couples Home to other presentation layers (R02).
- **Shortcuts model.** A fixed list of six ids with an `availability` computed by one domain function from the home state; presentation maps id → icon/label/route in one place. Unimplemented destinations open `VanepComingSoon`.
- **Live map.** Placeholder container (no map package added); the action is disabled until a map spec exists.
- **Pull-to-refresh** reloads the repository; live ETA polling is deferred to the real-API phase.

### Dependency graph and layers

```
domain entities/value objects
  -> ClientHomeRepository contract
     -> use cases (LoadClientHome, PrioritizeNeedsYouItems, ResolveShortcutAvailability)
        -> ClientHomeCubit
           -> widgets (section widgets) -> ClientHomeTab -> shell wiring
data: fake datasource + repository impl (depends only on the contract)
```

### PR plan

The developer chose to ship the whole screen in **one PR** (branch `feat/41-client-home`), overriding the per-layer split of R16–R23 and the 600-line cap for this change. Layer order inside the PR still follows R24 (tests → domain → data → cubit → widgets → page).

| PR | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Domain, data (empty + scenario datasources), cubit, widgets for the seven states, page and shell wiring, l10n, tests | none | — |
| 2+ | Per-state real API wiring as backend lands | 1 + backend | — |

### Home snapshot as value objects

The Home is a read model with no identity and no DTO yet, so its parts live in `domain/value_objects/` as concrete `Equatable` classes instead of abstract entities. When endpoints land, DTOs map into these value objects at the data boundary (R04 still holds for anything with identity).

### Production vs. scenario data

`ClientHomeRepositoryImpl` reads a `DailyOverviewDataSource`. Until the backend exists, production registers an **empty** datasource: real users only see first access or "no linked van", both computed from real address and dependents. The seven scenarios are available for manual verification by setting `CLIENT_HOME_SCENARIO` in `.env`; an unknown or empty value falls back to the empty datasource.

## Risks / Trade-offs

- [Fake data drifts from the real API shape] → entities are defined from the Genwork task and backend models; the DTO mapping is deferred, so a mismatch only costs the datasource.
- [Seven states produce a large widget surface] → state is one sealed type with one builder per variant; golden/widget tests per variant.
- [Seven PRs is a lot of review] → PRs 2 and 3 are parallel and small; alternatively merge 4 and 5 if the reviewer prefers.
- [Shortcuts pointing to coming-soon feel broken] → disabled state with explicit label, replaced as destinations ship.
