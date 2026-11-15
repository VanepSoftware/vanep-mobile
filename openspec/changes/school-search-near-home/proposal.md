## Why

School autocomplete returns schools from all over Brazil. The request only sends `includedRegionCodes: ["br"]` and the school primary types, so Google biases by the caller's IP, which on mobile carriers usually resolves to São Paulo. People see many irrelevant schools (VAN-76).

## What Changes

- Send a soft `locationBias` circle (50 km, the Google maximum) and an `origin` with the school autocomplete request, and read `distanceMeters` from each prediction.
- Show the distance of each school suggestion.
- Choose the circle center, in order: the dependent's address city, the client's personal address city, the device location (only if the person allows it), otherwise no bias (current IP behavior).
- Read `cityLatitude` / `cityLongitude` from the dependent and personal address responses (added by the API change `school-search-near-home`).
- Add the `geolocator` package with coarse, when-in-use location permission on Android and iOS.

Non-goals: no hard restriction by radius, state, or city (a school outside the circle must still appear for an exact name); no other Places flow (driver search, service areas, personal address) changes behavior.

## Capabilities

### New Capabilities

- `school-search-near-home`: nearby-first school autocomplete with distances.

### Modified Capabilities

- Places autocomplete (`lib/core/places`): optional search center.
- Dependent and personal address entities: nullable city coordinates.

## Impact

- New dependency: `geolocator`. New permissions: Android `ACCESS_COARSE_LOCATION`; iOS `NSLocationWhenInUseUsageDescription`.
- API: consumes additive nullable fields; the app works unchanged (no bias) while the API change is not deployed.
- Tests never call Google or the real location service (rule 50): Dio and `DeviceLocationSource` are mocked.
