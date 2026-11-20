## ADDED Requirements

### Requirement: School autocomplete is biased toward the person's area

The school autocomplete MUST send `locationBias.circle` with radius `50000` meters and `origin` at the same center whenever a search center is known. It MUST NOT send `locationRestriction`. The center MUST be chosen in this order: the dependent's address city coordinates, the client's personal address city coordinates, the device location if permitted. With no center, the request MUST be identical to the current one.

#### Scenario: Dependent in Brasília searches "colégio"

- **WHEN** the dependent's address city has coordinates `-15.7843, -47.9081` and the person types "colégio"
- **THEN** the request carries a 50 km `locationBias` circle and `origin` at that point

#### Scenario: Exact name outside the circle

- **WHEN** the person types the exact name of a school outside the circle
- **THEN** the request has no `locationRestriction`, so Google can still return it

#### Scenario: Fallback to the client's address

- **WHEN** the dependent has no address coordinates and the client's personal address city has coordinates
- **THEN** the client's city point is the center and the device location is not requested

#### Scenario: No address and location denied

- **WHEN** no address supplies coordinates and the person denies location permission
- **THEN** the request is sent without `locationBias` and `origin`

### Requirement: Device location is requested only when needed

The app MUST request only coarse, when-in-use location, and MUST request it only when no address supplies a center. Failure, denial, a disabled service, or a 5 s timeout MUST fall back silently to no bias.

#### Scenario: Address known

- **WHEN** the dependent's or the client's address has coordinates
- **THEN** the location permission dialog is never shown

### Requirement: Suggestions show their distance

Each school suggestion with `distanceMeters` MUST show the localized distance. Suggestions without it MUST render as today.

#### Scenario: Distance formatting

- **WHEN** suggestions return `850`, `2400`, and `37000` meters
- **THEN** they show `850 m`, `2,4 km`, and `37 km` in pt-BR

### Requirement: No test reaches Google or the device location service

Automated tests MUST mock the HTTP client and `DeviceLocationSource`.

#### Scenario: Test suite runs offline

- **WHEN** `make test` runs
- **THEN** no request reaches Google and no platform location API is called
