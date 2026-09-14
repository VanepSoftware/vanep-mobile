## ADDED Requirements

### Requirement: A client reaches their dependents from the profile

The app SHALL open the dependents screen from the `Manage dependents` row in the client profile menu. That row MUST stop being disabled for `UserType.client` and MUST remain absent for every other user type, because only a client owns dependents.

The screen MUST load the list on open through `GET /api/dependent`, which returns only the signed-in client's dependents.

#### Scenario: Client opens the dependents screen

- **WHEN** a client taps `Manage dependents` in the profile menu
- **THEN** the app pushes the dependents screen
- **AND** requests `GET /api/dependent` without any client identifier, because the backend resolves the owner from the token

#### Scenario: Row stays hidden for other user types

- **WHEN** a driver or an assistant opens their profile menu
- **THEN** no `Manage dependents` row is shown

### Requirement: The list shows every dependent and which one is the default

The app SHALL render one card per dependent with the name, the age derived from `birthDate`, and a visible mark on the dependent whose `isDefault` is true. The default mark MUST be derived from the `isDefault` returned by the backend and MUST NOT be tracked separately in the app.

When `birthDate` is absent the card MUST omit the age rather than showing a placeholder age.

#### Scenario: Dependents are listed

- **WHEN** `GET /api/dependent` returns two dependents
- **THEN** the app shows two cards, each with the dependent's name
- **AND** exactly the one carrying `isDefault: true` is marked as the default

#### Scenario: Dependent without a birth date

- **WHEN** a returned dependent has a null `birthDate`
- **THEN** the card shows the name without an age

#### Scenario: No dependents yet

- **WHEN** `GET /api/dependent` returns an empty list
- **THEN** the app shows a localized empty state inviting the client to add the first dependent
- **AND** the control that adds a dependent stays available

### Requirement: A client adds a dependent

The app SHALL offer a form that creates a dependent through `POST /api/dependent` with `name`, `birthDate`, `gender` and the address. Only `name` is required; the app MUST send the optional fields only when the client filled them, and MUST NOT send empty strings in their place.

`birthDate` MUST be sent as an ISO `yyyy-MM-dd` date and MUST be displayed in the locale's format.

#### Scenario: Dependent created with every field

- **WHEN** a client submits the form with a name, a birth date, a gender and an address
- **THEN** the app sends `POST /api/dependent` with `name`, `birthDate` as `yyyy-MM-dd`, `gender` as the API value, and the address
- **AND** the new dependent appears in the list on return

#### Scenario: Dependent created with the name alone

- **WHEN** a client submits the form with only a name
- **THEN** the request body carries `name` and no `birthDate`, `gender` or `address` key

#### Scenario: Name is required

- **WHEN** a client submits the form with a blank name
- **THEN** the app shows a localized error on the name field
- **AND** sends no request

#### Scenario: Birth date cannot be in the future

- **WHEN** a client picks a birth date later than today
- **THEN** the app shows a localized error on the birth date field
- **AND** sends no request

### Requirement: A client edits a dependent

The app SHALL reuse the same form to edit an existing dependent through `PATCH /api/dependent/{token}`, sending only the fields the client changed, because the endpoint merges by presence and treats an absent key as untouched.

Clearing a previously filled optional field MUST send that field as an explicit null, so the backend erases it instead of keeping the old value.

#### Scenario: Only the changed field is sent

- **WHEN** a client opens a dependent, changes the name and saves
- **THEN** the request body carries `name` and no other field

#### Scenario: Clearing an optional field

- **WHEN** a client removes the gender of a dependent that had one and saves
- **THEN** the request body carries `gender` as null

#### Scenario: Nothing changed

- **WHEN** a client opens a dependent and saves without editing anything
- **THEN** the app sends no request and closes the form

### Requirement: The default dependent follows RN12

The app SHALL let a client choose the default dependent only when there are two or more. With exactly one dependent the backend already marks it default on create, so the app MUST show it as the default and MUST NOT offer a control that would change it.

Choosing a default MUST be sent as `PATCH /api/dependent/{token}` with `isDefault: true`. The app MUST NOT clear the previous default itself; the backend does that, and the app refreshes from the response of the following list.

#### Scenario: Single dependent is the default without a choice

- **WHEN** the client has exactly one dependent
- **THEN** that dependent is shown as the default
- **AND** no control to change the default is offered

#### Scenario: Client picks a default among several

- **WHEN** the client has three dependents and marks the second as default
- **THEN** the app sends `PATCH /api/dependent/{token}` with `isDefault: true` for that dependent only
- **AND** after reloading, exactly that dependent is marked as the default

#### Scenario: Default choice fails

- **WHEN** the request marking a new default fails
- **THEN** the app keeps the previous default marked
- **AND** shows a localized error through the shared feedback surface

### Requirement: Failures are localized and never silent

The app SHALL map every failure of the dependent endpoints to a localized message, distinguishing what the client can act on from what they cannot. Field-level validation returned by the backend MUST be shown on the matching field; anything else MUST be shown through the shared feedback surface.

A failed load MUST leave the screen in a retryable state rather than an empty list, because an empty list means "no dependents" and would be a lie.

#### Scenario: Duplicate document rejected by the backend

- **WHEN** the backend rejects a save because the document already belongs to another dependent
- **THEN** the app shows the localized message on the document field
- **AND** keeps the client's input on screen

#### Scenario: Network failure while loading

- **WHEN** `GET /api/dependent` fails
- **THEN** the app shows a localized error state with a retry control
- **AND** does not show the empty state

#### Scenario: Network failure while saving

- **WHEN** a create or update request fails
- **THEN** the app shows a localized error through the shared feedback surface
- **AND** keeps the form open with the client's input intact
