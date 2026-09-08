## Context

The backend delivered the geographic tree, `driver_service_area`, and `onboarding.pendingSteps`. None of it is reachable from the app.

Current app state that this change builds on:

- `lib/modules/` holds `auth`, `driver`, `drivers`, `home`, `profile`. `drivers` is the client-facing list, with a `DriversSearchField` that filters an already-loaded list of recent drivers — it is not a geographic search.
- `lib/shell/` already splits `ClientShell` from `DriverShell`, and `app.dart` routes by `session.profile.type`. This split, plus the icons-only bottom nav, exists **uncommitted** in the working tree.
- `Environment` reads four `AUTH_URL`/OAuth variables from `.env`. It does not know about Places keys, and `.env.example` does not document them even though `.env` already holds `GOOGLE_PLACES_API_KEY_ANDROID` and `GOOGLE_PLACES_API_KEY_IOS`.
- No `openspec/specs/` exist yet in this repo.

Constraints: the mobile constitution — Clean Architecture with `Result<E, T>` and no exceptions as control flow (R01, R04), feature-first modules with shared code only in `lib/core/` (R02), constructor DI through containers (R03), test-first (R05, R36), core UI widgets are mandatory (R10b), **all** user-visible copy localized (R10), **no comments in source** (R40a), phased delivery capped at ~600 lines and 10 new files per PR (R23), and no commit without human sign-off on device (R27a).

## Goals / Non-Goals

**Goals:**

- A driver can declare up to 10 regions, resolved from Google Places, and edit them later.
- A client can search one place and get drivers ranked by how specific the match is.
- Autocomplete costs one billed session per search box, not one per keystroke.
- The driver flow ships without waiting on any backend change.

**Non-Goals:**

- Map, radius, distance, route drawing. The match is tree containment, not geometry.
- Web frontend. The user stated the web needs nothing here.
- Editing the client's own residential address (that is `PUT /api/user/me/address`, a separate flow).
- Offline autocomplete or caching of suggestions across sessions.

## Decisions

### D1 — The client search needs a backend change first, and it is not small

The product rule is: **one** place in, results **ranked** by specificity. The endpoint that exists is:

```
GET /api/drivers/search?originPlaceId=…&destinationPlaceId=…   → unordered Page
```

It requires two places and orders by nothing. Neither half fits. Two things must change server-side:

1. Accept a single `placeId` (+ optional `sessionToken`).
2. Order by distance from the point up the tree.

The ranking is computable without new data. The resolver already produces the point's ancestor chain, deepest first:

```
busca "QNL 5 Conjunto J"  →  ancestors = [Conjunto J, QNL 5, Taguatinga],  city = Brasília

driver registered Conjunto J  → index 0   → rank 0
driver registered QNL 5       → index 1   → rank 1
driver registered Taguatinga  → index 2   → rank 2
driver registered whole city  → no index  → rank = ancestors.length (last)
```

So rank is the position of the driver's `district_id` in the ancestor list, and city-wide areas sort after every district. A driver with several matching areas takes their **best** rank.

Alternatives rejected: ranking in the app (would need every driver's full area set shipped to the client, and breaks pagination — you cannot order page 2 by something computed after paging); adding a `depth` column to `district` (denormalisation that the ancestor list already gives for free).

**Consequence for sequencing:** the driver flow (phases 1–3) depends on none of this. The client search (phases 4–5) is blocked until the backend change merges. That is why the phases are ordered this way and not by screen.

### D2 — `lib/core/places/`, not a module

Autocomplete is needed by the driver screen **and** the client search. R02 says shared code lives in `lib/core/`, and R06a says one canonical owner. Putting it in either module would force a cross-module import, which R02 forbids.

`lib/core/places/` owns: the HTTP call to Places Autocomplete (New), session-token lifecycle, platform key selection, debounce, and the `PlaceSuggestion` value object. It exposes a contract; both modules depend on the contract, not the implementation (R07).

### D3 — Raw HTTP against Places API (New), no SDK package

The pub packages for Places autocomplete overwhelmingly target the **legacy** API, whose response shape and billing differ from the New API the backend was built against. The keys we created are restricted to **Places API (New)** specifically, so a legacy-targeting package would get `403` and the cause would be hard to see.

We already have the exact contract from the backend spike:

```
POST https://places.googleapis.com/v1/places:autocomplete
  X-Goog-Api-Key: <platform key>
  { "input": "...", "sessionToken": "...", "includedRegionCodes": ["br"] }
```

One `dio`/`http` call against a documented contract is less code than adapting an SDK, and keeps the session-token rule visible instead of buried in a package's internals.

### D4 — Session token lives with the search box, not the screen

A session begins when a box gains focus and ends when the backend calls Place Details with that token. Two boxes on one screen are two sessions. Tying the token to the screen would merge them and break the billing unit.

```
box focado        → gera token
digita, digita    → autocomplete(token)   ×N
escolhe sugestão  → placeId + token vão para o backend
backend           → Place Details(token)  ← encerra a sessão
volta a digitar   → token NOVO
```

Getting this wrong is not a crash — it is a bill. Every keystroke becomes a separately charged `Autocomplete Request` instead of a free session. That is exactly the open **Q1** in the backend design, which can only be answered once this ships and real autocomplete traffic reaches the billing report.

### D5 — District is guided, never hard-blocked by the app

The stated rule is "state + city + something deeper, always". Taken literally as a client-side block it breaks: our own backend fixtures show **Formosa** and **Itapetininga** return no level below the city, and the classifier drops the `administrative_area_level_4` that merely repeats the city name. A driver there could never satisfy the rule and would be locked out of registering anything.

The backend already owns this decision through `COALESCE(city.requires_district, state.requires_district)` — curated, `true` for DF and SP. So:

- The app **guides**: prefers and highlights sub-city suggestions, marks a city-level pick as less precise.
- The app **does not block**: it lets the request go and renders the backend's pt-BR rejection if the rule applies.

The backend stays the single source of truth for the rule (R06a). The app duplicating it would be a second source that drifts the moment a state flag changes.

### D6 — The 10-region cap is enforced in both places, for different reasons

The app disables adding at 10 so the user learns the limit before losing work. The backend gets `@Size(max = 10)` because a client-side cap is not a limit — anyone calling the API directly ignores it, and each region is a row in a shared table.

This is not a duplicated rule in the R06a sense: the backend is the authority, and the app's cap is a UX affordance derived from the same number. The number itself must be stated once in the app (a constant in the module) and once in the backend annotation, and the design records that they must move together.

### D7 — Onboarding reads `pendingSteps`, it does not infer

`GET /api/user/me` returns `onboarding.pendingSteps`. The app checks whether `SERVICE_AREA` is present. It must not infer the step from "the driver has no areas" by calling the areas endpoint — that would be a second source of truth for the same fact, and it is exactly what `pendingSteps` exists to avoid.

The offer is skippable and may reappear next session while the step is pending. It is never a route guard: blocking the app on onboarding turns a nudge into a wall.

### D8 — Adopt the uncommitted nav work rather than redo it

The icons-only `VanepBottomNav` and the `DriverShell`/`ClientShell` split already exist in the working tree, uncommitted, with `label` correctly moved to `Semantics` (so screen readers keep the name). Redoing it would be wasted work and would risk losing the accessibility detail.

Phase 1 adopts it, adds the widget test that was missing, and commits it as its own PR — small, reviewable, and independent of everything else.

## Risks / Trade-offs

**R1 — The client search is blocked on another repo (HIGH for scheduling, not for design).**
Phases 4–5 cannot start until the backend accepts a single `placeId` and ranks results.
*Mitigation:* the phase plan puts every driver-side phase first, so work never stalls. The backend change is small and well-specified (D1); it should be proposed in `vanep-api-java` as soon as this plan is approved, and it can be built in parallel with phases 1–3.

**R2 — Session-token handling is invisible when wrong (MEDIUM).**
Nothing crashes and no test fails if the token is regenerated per keystroke or shared between boxes. The only symptom is a bill.
*Mitigation:* the token lifecycle is a domain concern with its own unit tests asserting identity across a search and change after handover — not something verified only through the widget. Q1 in the backend design stays open until a real billing report confirms `Autocomplete Session Usage` appears.

**R3 — Places keys ship inside the app binary (accepted).**
An Android or iOS key can be extracted from a distributed app. This is inherent to client-side autocomplete and is why the keys are restricted by package + SHA-1 and bundle id, and why the server key is never shipped.
*Mitigation:* already verified — without the platform headers Google answers `403 API_KEY_ANDROID_APP_BLOCKED` / `API_KEY_IOS_APP_BLOCKED`. Residual exposure is capped by the daily quota.

**R4 — The release SHA-1 does not exist yet (MEDIUM, bites at publish time).**
`android/app/build.gradle.kts` still signs with the debug config. The Android key authorises only the debug SHA-1, so autocomplete works in development and fails in a published build with a `403` that does not name the cause.
*Mitigation:* recorded here and in the backend change's phase-0 notes. Adding the release SHA-1 to the key is a release-checklist item, not a code change.

**R5 — Ranking is invisible with a shallow tree (LOW).**
Early on, most drivers will have registered at the same level, so the ordering will look like no ordering, and a regression could pass unnoticed.
*Mitigation:* the backend test for ranking must build all four levels explicitly, and the app test asserts it renders the order the API returned rather than re-sorting locally.

**R6 — Adopting uncommitted work means adopting its bugs (LOW).**
The `DriverShell` split in the tree has never been reviewed or tested.
*Mitigation:* phase 1 treats it as new code — read it, test it, and fix what the tests expose before committing.

## Migration Plan

No data migration; the app holds no persisted geography. Rollout is the phase order itself, and each phase is independently revertable because each ships as its own PR.

The one ordering constraint that is not internal: phases 4–5 must merge **after** the backend's single-place ranked search is deployed, otherwise the search screen calls an endpoint that rejects it.

## Open Questions

| # | Question | Blocks | Notes |
|---|---|---|---|
| **Q1** | Does a Places session survive the app calling autocomplete with the platform key while the backend closes it with the server key? | Nothing — cost only | Inherited from the backend design. Answerable only once this ships and real autocomplete traffic reaches billing. Look for `Autocomplete Session Usage` at US$ 0; if only `Autocomplete Requests` appears, the session broke at the key boundary |
| **Q2** | Should the driver's registered regions be shown anywhere the client can see, e.g. on the driver card in search results? | Nothing in this change | The region is public data by design (`driver_service_area` has no street columns), so it is safe to show. Left out of scope until asked |
| **Q3** | What minimum character count should trigger autocomplete? | Nothing | Starts at 3, tunable; lower means more requests against the free tier, higher means the user types more before seeing anything |
