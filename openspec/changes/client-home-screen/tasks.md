## 1. Domain (branch: feat/41-client-home — single PR by developer decision)

- [x] 1.1 Write tests for `PrioritizeNeedsYouItems` (tier order, deadline order, cap of 3, hidden count), `ResolveEnabledShortcuts`, `ResolveHomeHeadline`, `ResolveSectionWithoutVan` and `LoadClientHome`
- [x] 1.2 Create `ClientHomeRepository` contract and `ClientHomeFailure`
- [x] 1.3 Create value objects: `ClientHome`, sealed `TodaySection` variants, van day and live trip, sealed `NeedsYouItem`, `HomeShortcut`, `DailyOverview`
- [x] 1.4 Implement the use cases

## 2. Data

- [x] 2.1 Write tests for `ClientHomeRepositoryImpl`, the empty datasource and every scenario
- [x] 2.2 Implement `DailyOverviewDataSource` contract, empty and scenario datasources, `ClientHomeScenario`
- [x] 2.3 Implement `ClientHomeRepositoryImpl`
- [x] 2.4 Add `CLIENT_HOME_SCENARIO` to `Environment` and `.env.example`; register `ClientHomeContainer` in `main.dart`

## 3. Cubit

- [x] 3.1 Write `bloc_test` cases: loading, ready, failure, reload keeps content
- [x] 3.2 Implement `ClientHomeCubit` and `ClientHomeState`

## 4. Widgets

- [x] 4.1 Write widget tests per section: first steps, negotiating, van day (siblings, absent child, collapsed rows), live van, arrival timeline, no route today, needs-you (featured, rows, See all), shortcuts (six, disabled)
- [x] 4.2 Add localization keys (pt-BR and en) and the module label formatters
- [x] 4.3 Extend `VanepAvatar` with initials
- [x] 4.4 Implement the section widgets

## 5. Page and shell

- [x] 5.1 Update `client_home_tab_test.dart` and `client_shell_test.dart` for the new page
- [x] 5.2 Move `ClientHomeTab` into the module and render the three blocks, skeleton and error with retry
- [x] 5.3 Wire `ClientShell`: cubit provider, address form, dependents tab, reload when returning to Home
- [x] 5.4 Run `make lint` and `make test`
- [ ] 5.5 Manual verification on Android and iOS of the seven scenarios before any commit (R27a)

## 6. Later — real API wiring (one PR per state, after backend)

- [ ] 6.1 Negotiating and proposals when api-java #30 lands
- [ ] 6.2 Contract to sign when #31/#32 land
- [ ] 6.3 Route, live trip and arrival when the daily route endpoints land
- [ ] 6.4 Payments when #17 lands
