> Applies to every task: tests first (R05), fixtures in `*_fixture.dart`, copy only in ARB pt + en (R10), codegen after DTO changes (R15), no private methods (R08). R27a: no commit without developer sign-off; each phase ends with `make lint` + `make test` and a stop for device validation.

## Phase 1 (branch name: feat/76-1-places-search-center)
- [x] 1.1 Tests: the datasource sends a 50 km `locationBias` circle + `origin` when a center is given and the unchanged body otherwise; the parser reads `distanceMeters`; the controller forwards `searchCenter`.
- [x] 1.2 Add `PlaceSearchCenter` and `placeSearchBiasRadiusMeters` in `lib/core/places`.
- [x] 1.3 Add `distanceMeters` to `PlaceSuggestion`; bias/origin in `PlaceAutocompleteDataSource`; `searchCenter` in `PlaceAutocompleteController`.
- [x] 1.4 Run `make lint` and `make test`
- [ ] 1.5 Open PR

## Phase 2 (branch name: feat/76-2-address-city-coordinates)
- [x] 2.1 Tests: DTOs parse `cityLatitude` / `cityLongitude` and default to null when absent.
- [x] 2.2 Add nullable `cityLatitude` / `cityLongitude` to `DependentAddress` + `DependentAddressDto` and `PersonalAddress` + `PersonalAddressDto` + mapper; run codegen.
- [x] 2.3 Run `make lint` and `make test`
- [ ] 2.4 Open PR

## Phase 3 (branch name: feat/76-3-school-search-center)
- [x] 3.1 Tests for `FindSchoolSearchCenter`: the dependent point wins; the client point is next, without touching device location; device location is next; `null` when all fail; a personal-address failure falls through.
- [x] 3.2 Add the `DeviceLocationSource` contract in `lib/core/location`.
- [x] 3.3 Add the `FindSchoolSearchCenter` use case in `dependents/domain/usecases`.
- [x] 3.4 Run `make lint` and `make test`
- [ ] 3.5 Open PR

## Phase 4 (branch name: feat/76-4-geolocator-device-location)
- [x] 4.1 Tests for `GeolocatorDeviceLocationSource` behind a thin wrapper: denied → request once; `deniedForever`, disabled service, timeout, and exception → `null`; last known position preferred.
- [x] 4.2 Add `geolocator`; Android `ACCESS_COARSE_LOCATION`; iOS `NSLocationWhenInUseUsageDescription`; register in DI.
- [x] 4.3 Run `make lint` and `make test`
- [ ] 4.4 Open PR

## Phase 5 (branch name: feat/76-5-school-search-near-home-ui)
- [x] 5.1 Tests: the cubit sets the resolved center on the controller; the distance formatter (`850 m`, `2,4 km`, `37 km`); the school row shows the distance and omits it when null.
- [x] 5.2 Wire `FindSchoolSearchCenter` into `DependentSchoolCubit` and the container.
- [x] 5.3 Add the distance formatter and ARB strings (pt + en); show the distance in the school suggestion row.
- [ ] 5.4 Run `make lint` and `make test` (done; the only failure, `image_picker_photo_picker_test`, also fails on `main` under Windows); validate on an emulator: dependent with an address, client-only address, no address with permission allowed and denied.
- [ ] 5.5 Open PR with screenshots and video (R13a)
