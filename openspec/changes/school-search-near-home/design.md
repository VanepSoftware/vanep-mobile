## Context

`PlaceAutocompleteDataSource` posts to `places:autocomplete` with `includedRegionCodes` and optional `includedPrimaryTypes`. `DependentSchoolCubit` owns a `PlaceAutocompleteController` configured with `schoolPlacePrimaryTypes`. The Places API has no state or city filter; it accepts a country list, or a circle/rectangle as `locationBias` (soft) or `locationRestriction` (hard). When `origin` is sent, each prediction carries `distanceMeters`.

The API change `school-search-near-home` (vanep-api-java) adds `cityLatitude` / `cityLongitude` (IBGE 2022 municipal-seat point) to city, address, and personal address responses.

## Goals / Non-Goals

Goals: nearby schools first, every suggestion with its distance, no school hidden, permission prompt only when it can help.

Non-goals: storing the device position, precise per-address geocoding, changing driver search or service-area autocomplete.

## Decisions

### D1 — Soft bias, never restriction

`locationBias.circle` with radius `50000` (Google maximum). A hard filter by UF would drop schools across state lines (Águas Lindas, Valparaíso, Novo Gama → Brasília) and still show schools 500 km away in large states.

### D2 — `PlaceSearchCenter` value object in `lib/core/places`

Pure Dart (`latitude`, `longitude`, value equality). `PlaceAutocompleteController` gets a mutable `searchCenter` (null by default); the datasource adds `locationBias` and `origin` only when a center is set. Other flows never set it and send the same body as today.

### D3 — `PlaceSuggestion.distanceMeters`

Nullable `int`, parsed from the prediction. Absent when no `origin` was sent.

### D4 — Center resolution as a dependents use case

`FindSchoolSearchCenter` (dependents domain) returns `PlaceSearchCenter?`, trying in order:

1. the dependent's address city coordinates;
2. the client's personal address city coordinates (`FindMyPersonalAddress`, an auth domain contract — an allowed cross-module dependency);
3. `DeviceLocationSource.findApproximateLocation()`;
4. `null` (no bias, current behavior).

Each step that fails or returns nothing falls through. Steps 1–2 never prompt; step 3 is reached only when no address supplies a point, so people with an address never see the permission dialog.

### D5 — `DeviceLocationSource` contract in `lib/core/location`, `geolocator` implementation in data

The contract returns `Future<PlaceSearchCenter?>` and never throws. Implementation: check that the service is enabled → check permission → request once if `denied` → `getLastKnownPosition()` → else `getCurrentPosition(accuracy: low, timeLimit: 5 s)`. `deniedForever`, disabled service, timeout, and platform errors return `null`. Only coarse permission is requested; a 50 km circle does not need GPS precision.

### D6 — Resolve once when the cubit is created

`DependentSchoolCubit` resolves the center at creation and sets it on the controller. Searches typed before resolution finishes go out without bias; later ones use it. No new UI state is needed.

### D7 — Distance display

One formatter maps meters to copy: `< 1000` → `850 m`; `< 10 km` → one decimal (`2,4 km`); otherwise whole kilometers (`37 km`), locale-aware via ARB placeholders. The school suggestion row shows it next to the secondary text.

## Risks / Trade-offs

- **The point is the city seat, not the home.** In large municipalities the distance is measured from the city center. Brasília is the only IBGE municipality in the DF, so for someone in Taguatinga the distance is measured from the Plano Piloto (about 20 km). Ranking still favors the DF over São Paulo, but nearby schools in Taguatinga may show about 20 km. Follow-up candidate: store the address point when the address comes from a Google place (API change `dependent-address-by-place`) and prefer it over the city point.
- A new native dependency and permission text must be reviewed against store policies.
- Prompting on page open may surprise; mitigated by prompting only when no address is known.

## Phased delivery (R16–R23)

| Phase | Contents | Branch | Depends on | Parallel with |
|----|----------|--------|------------|---------------|
| 1 | `PlaceSearchCenter`, bias/origin in datasource + controller, `distanceMeters` | `feat/76-1-places-search-center` | — | 2 |
| 2 | City coordinates on dependent and personal address entities + DTOs | `feat/76-2-address-city-coordinates` | — | 1 |
| 3 | `DeviceLocationSource` contract + `FindSchoolSearchCenter` use case | `feat/76-3-school-search-center` | 1, 2 | — |
| 4 | `geolocator` implementation, permissions, DI | `feat/76-4-geolocator-device-location` | 3 | 5 |
| 5 | Cubit wiring, distance formatter, l10n, school row | `feat/76-5-school-search-near-home-ui` | 3 (4 for DI at runtime) | 4 |

Declared exception to R19 in phase 2: adding a nullable field to an entity and its DTO is one compile unit (the DTO implements the entity).
