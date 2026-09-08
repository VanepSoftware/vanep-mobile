## ADDED Requirements

### Requirement: One box, one place

The app SHALL offer the client a single search box that accepts any place — a street address or a school — chosen from Google Places autocomplete. The app MUST send the `placeId` and `sessionToken` to the backend and MUST NOT send address components.

There is no separate origin and destination input.

#### Scenario: Searching an address

- **WHEN** a client picks an address suggestion and searches
- **THEN** the app requests drivers for that single `placeId`

#### Scenario: Searching a school

- **WHEN** a client picks a school suggestion in the same box
- **THEN** the app performs the same search with no different handling

### Requirement: A driver matches when the searched point is inside their area

The results SHALL contain every driver whose registered region contains the searched point, where "contains" means the driver's region is the point's own node or any of its ancestors up to the city.

#### Scenario: Exact region

- **WHEN** a driver registered "QNL 5" and the client searches a place resolving to "QNL 5"
- **THEN** that driver is in the results

#### Scenario: Ancestor region

- **WHEN** a driver registered "Taguatinga" and the client searches "QNL 5 Conjunto J", which sits under Taguatinga
- **THEN** that driver is in the results

#### Scenario: Whole-city region

- **WHEN** a driver registered the whole city "Brasília" and the client searches any place in Brasília
- **THEN** that driver is in the results

#### Scenario: Sibling region excluded

- **WHEN** a driver registered only "Águas Claras" and the client searches a place in Taguatinga
- **THEN** that driver is absent from the results

#### Scenario: Other city excluded

- **WHEN** a driver registered a region in Campinas and the client searches a place in Brasília
- **THEN** that driver is absent from the results

### Requirement: Results are ordered by how specific the match is

The results MUST be ordered so that the closer a driver's region is to the searched point, the earlier they appear. A driver whose region is the point itself comes first; each level further up the tree ranks lower; a driver covering the whole city comes last.

A broad match MUST still be returned — it is de-prioritised, not filtered out — because a driver covering the whole city genuinely serves the point.

#### Scenario: Ordering across levels

- **WHEN** the client searches a place whose chain is `Brasília → Taguatinga → QNL 5 → Conjunto J`
- **AND** four drivers registered, respectively, "Conjunto J", "QNL 5", "Taguatinga" and the whole city "Brasília"
- **THEN** they appear in exactly that order

#### Scenario: Whole-city driver is last but present

- **WHEN** the only matching driver registered the whole city
- **THEN** that driver is returned, at the end of the list

#### Scenario: Stable order within a level

- **WHEN** two drivers registered the same region
- **THEN** their relative order is deterministic across identical requests

### Requirement: Searching never changes the geographic tree

The search MUST NOT create any geographic node. A place more specific than anything registered MUST resolve to the deepest node that already exists.

#### Scenario: Place deeper than the tree

- **WHEN** the client searches a place whose components go deeper than any registered region
- **THEN** the results are computed from the deepest existing node
- **AND** no new state, city or district is created

### Requirement: Empty and failed searches are distinguishable

The app MUST show different states for "no driver covers this place" and "the search could not be performed", and MUST surface the backend's localized message when a place cannot be resolved.

#### Scenario: No driver covers the place

- **WHEN** the search succeeds and matches nobody
- **THEN** the app shows a localized empty state

#### Scenario: Place cannot be resolved

- **WHEN** the backend rejects the `placeId`
- **THEN** the app shows the backend's localized message

#### Scenario: Rate limit reached

- **WHEN** the backend refuses the search because the caller exceeded the rate limit
- **THEN** the app shows a localized message asking the user to wait, distinct from an empty result

#### Scenario: Unauthenticated

- **WHEN** an unauthenticated user reaches the search
- **THEN** the app routes to authentication instead of issuing the search
