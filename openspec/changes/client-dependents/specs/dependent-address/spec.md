## ADDED Requirements

### Requirement: A dependent's address is chosen from Google Places

The app SHALL collect the dependent's address through Google Places autocomplete, reusing the shared `lib/core/places/` client and `VanepPlaceAutocompleteField`. The app MUST send only `placeId` and `sessionToken`, plus the `number` and `complement` the client typed, and MUST NOT send city, state, district, zip code or street.

The backend re-resolves the place and owns the geography tree, so any component the app produced would be a second source of truth for data the server already holds.

#### Scenario: Address selected from a suggestion

- **WHEN** a client picks an address suggestion in the dependent form and saves
- **THEN** the request body's `address` carries the `placeId` and the `sessionToken` of that autocomplete session
- **AND** carries no city, state, district, zip code or street field

#### Scenario: Number and complement travel with the place

- **WHEN** a client picks a suggestion and types a number and a complement
- **THEN** `number` and `complement` are sent alongside `placeId`

#### Scenario: One session token per search

- **WHEN** a client types, sees suggestions and selects one
- **THEN** every autocomplete request of that search and the save that closes it carry the same `sessionToken`

### Requirement: The address is displayed from what the backend resolved

The app SHALL render the dependent's address from the `AddressResponseDTO` the backend returns — street, number, complement, district, city and state — and MUST NOT rebuild it from the autocomplete suggestion text, which is a display string and not the resolved address.

A dependent without an address MUST be shown as having none, not as an empty address.

#### Scenario: Saved address is shown as resolved

- **WHEN** the backend returns an address after a save
- **THEN** the form and the card show the street, number, district, city and state from that response

#### Scenario: Dependent without an address

- **WHEN** a returned dependent has a null `address`
- **THEN** the app shows a localized "no address" state and offers to add one

### Requirement: The address is optional and can be replaced

The app SHALL let a client save a dependent with no address, because RN01 requires a dependent for a contract but neither UC13 nor the backend requires an address to create one.

Picking a new place for a dependent that already has an address MUST replace it, since the backend keeps one address per dependent.

#### Scenario: Dependent saved without an address

- **WHEN** a client submits the form without selecting an address
- **THEN** the request carries no `address` key
- **AND** the dependent is created

#### Scenario: Address replaced

- **WHEN** a client picks a different place for a dependent that already has an address
- **THEN** the app sends the new `placeId` in `address`
- **AND** the dependent afterwards carries only the new address

#### Scenario: Number amended without reselecting the place

- **WHEN** a client changes only the number or complement of an address the dependent already has
- **THEN** the app sends `address` carrying the new `number` and `complement` and no `placeId`
- **AND** the street the backend already resolved is kept

#### Scenario: Number survives picking a different place

- **WHEN** a client has typed a number and then picks a different suggestion
- **THEN** the typed number is kept alongside the new `placeId`

### Requirement: Place resolution failures are surfaced, not swallowed

The app SHALL show a localized message when the backend cannot resolve the selected place, and MUST keep the client on the form with their other input intact so the address can be reselected without retyping the rest.

Autocomplete failures MUST be distinguished from save failures: a failing autocomplete MUST NOT block saving a dependent without an address.

#### Scenario: Backend cannot resolve the place

- **WHEN** a save fails because the backend could not resolve the `placeId`
- **THEN** the app shows a localized message on the address field
- **AND** keeps the name, birth date and gender the client already filled

#### Scenario: Autocomplete unavailable

- **WHEN** the Places autocomplete request fails
- **THEN** the app shows a localized message in the suggestion area with a retry control
- **AND** the form can still be saved without an address
