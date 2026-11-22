# QA — school-search-near-home (mobile)

Run date: 2026-11-15. Device: Android 14 emulator (AVD `vanep`), debug build of the working tree on `feat/van-76-school-search-near-home`. Backend: `vanep-api-java` branch `feat/van-76-city-coordinates` (migrations through V73, real seed) on a throwaway PostgreSQL 17 container.

## Limits of this run

- **Google was not called.** No Google Places key exists on the test machine, so the app pointed at a local stub of `places:autocomplete` (temporary endpoint override and fake key, both reverted after the run). The stub recorded every request body and returned four fixed schools, with `distanceMeters` computed from `origin` and sorted by it. This proves what the app sends and renders; it does not prove how Google ranks results. That needs one pass with a real key.
- iOS was not run.
- Saving a selected school was not exercised (the stub place ids do not exist in Google).

## Automated checks

- `flutter analyze --fatal-infos`: no issues.
- `flutter test`: 2530 passed, 1 failed. The failure, `test/core/media/image_picker_photo_picker_test.dart`, also fails on a clean `origin/main` on Windows and does not import any file of this change.

## Scenarios

Seed client `ana.souza@seed.vanep.com.br`; addresses edited directly in the throwaway database between scenarios. Query typed: `colegio`.

| # | Setup | Request body sent by the app | Screen | Result |
|---|---|---|---|---|
| 1 | Dependent address in São Paulo | `locationBias.circle` center `-23.5548, -46.578999`, radius `50000`; `origin` at the same point; no `locationRestriction`; region and school types unchanged | `7.1 km · Vila Mariana, São Paulo - SP` (English locale) | PASS |
| 2 | Dependent address in Brasília (Taguatinga), client address in São Paulo | center and `origin` `-15.7843, -47.9081` (the dependent wins over the client) | `2,8 km`, `17 km`, `874 km`, `878 km` (pt-BR) | PASS |
| 3 | Dependent without address, client address in Goiânia | center and `origin` `-16.680201, -49.2565` | `159 km`, `178 km`, `810 km`, `815 km`; location permission never requested (`granted=false`, no `USER_SET` flag) | PASS |
| 4 | No address at all, permission allowed, device location known | center and `origin` `-15.8378, -48.0586` (injected point `-15.8333, -48.0564`, coarsened by Android) | `558 m`, `20 km`, `871 km`, `874 km` | PASS |
| 5 | No address at all, permission allowed, no location available (first attempt on the emulator) | no `locationBias`, no `origin` | suggestions without distance | PASS (designed fallback) |
| 6 | No address at all, permission denied | no `locationBias`, no `origin` (same body as before this change) | suggestions without distance | PASS |

Selecting a suggestion that has a distance keeps it selected and enables Save.

## Findings

1. **Distance is measured from the city seat (known risk, confirmed).** In scenario 2 the school in Taguatinga, where the dependent lives, shows `17 km` and sorts after the Asa Norte school at `2,8 km`, because Brasília is the only IBGE municipality in the DF and its point is in the Plano Piloto. With the device location (scenario 4) the same school shows `558 m`.
2. **The permission prompt can appear twice.** After one denial, reopening the school page shows the system dialog again (Android allows a second request). Behavior after a second denial was not confirmed in this run.
3. **Low accuracy has no source on an emulator.** `LocationAccuracy.low` maps to `PRIORITY_LOW_POWER` (Wi-Fi and cell only). The emulator has neither, so without a cached location the 5 s limit expires and the search goes out unbiased (scenario 5). Scenario 4 needed a location injected with `cmd location providers set-test-provider-location`. Expected to resolve quickly on a real device; not verified on one.

Screenshots: `van-76-pr-evidence/` next to the worktrees (not committed).
