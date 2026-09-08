## ADDED Requirements

### Requirement: Driver declares where they operate

The app SHALL offer a screen where an authenticated driver registers the regions they serve. Each region MUST be chosen from Google Places autocomplete; the app MUST send only the `placeId` and the `sessionToken` to the backend and MUST NOT send address components, because the backend re-resolves the place and the tree is shared by every user.

The screen MUST save the whole set at once through `PUT /api/drivers/me/service-areas`, which replaces the previous set.

#### Scenario: Driver registers a region

- **WHEN** a driver picks "QNL 5" from the autocomplete and saves
- **THEN** the app sends the `placeId` and `sessionToken` for that suggestion
- **AND** the saved region appears in the list with the name returned by the backend

#### Scenario: Client-supplied components are never sent

- **WHEN** the app builds the save request
- **THEN** the body contains only `placeId` and optional `sessionToken` per item
- **AND** carries no city, state, district or street field

#### Scenario: Saving replaces the previous set

- **WHEN** a driver removes a region from the list and saves
- **THEN** the request contains only the remaining regions
- **AND** the removed region is no longer returned by `GET /api/drivers/me/service-areas`

### Requirement: At most ten regions

The app MUST NOT allow more than **10** regions in the set. When the limit is reached the app MUST disable adding and explain why, instead of failing at save time.

#### Scenario: Limit reached

- **WHEN** the list already holds 10 regions
- **THEN** the control that adds a region is disabled
- **AND** a localized message explains that 10 is the maximum

#### Scenario: Backend rejects an oversized set

- **WHEN** the backend rejects the request because the set exceeds the server-side maximum
- **THEN** the app shows the message returned by the backend and keeps the user's edits on screen

### Requirement: A region must be more specific than a city when the backend demands it

The app SHALL guide the driver toward a region below city level, because a whole-city area in the launch market covers thousands of square kilometres and makes the search useless.

The app MUST NOT hard-block a city-level selection on its own, because Google returns no level below the city for some places, and blocking would leave those drivers unable to register anything. The backend is the authority: it accepts or rejects through its curated rule.

#### Scenario: Deeper level available

- **WHEN** the autocomplete offers suggestions below the city for the typed text
- **THEN** the app presents them and marks a city-level choice as less precise

#### Scenario: Backend refuses a city-level region

- **WHEN** the driver saves a region resolving to a whole city and the backend rejects it
- **THEN** the app shows the backend's localized message
- **AND** keeps the driver on the screen with the selection intact so it can be replaced

#### Scenario: No deeper level exists

- **WHEN** the chosen place has no level below the city and the backend accepts it
- **THEN** the region is saved as the whole city without the app blocking it

### Requirement: Two entry points, never a hard gate

The app SHALL offer the screen after a driver's first login, using `onboarding.pendingSteps` from `GET /api/user/me` to decide, and SHALL always expose it from the driver profile so the set can be completed or edited at any later time.

Skipping MUST leave the driver with full access to the rest of the app.

#### Scenario: First login with the step pending

- **WHEN** an authenticated driver's `pendingSteps` contains `SERVICE_AREA`
- **THEN** the app offers the service-area screen

#### Scenario: Driver skips

- **WHEN** the driver dismisses the offer
- **THEN** the app proceeds to the driver home
- **AND** the offer may appear again on a later session while the step stays pending

#### Scenario: Editing later from the profile

- **WHEN** a driver opens the service-area screen from the profile
- **THEN** the screen loads the current set from `GET /api/drivers/me/service-areas` and allows adding and removing

#### Scenario: Step disappears once satisfied

- **WHEN** the driver saves at least one region
- **THEN** a later `GET /api/user/me` no longer lists `SERVICE_AREA` in `pendingSteps`
