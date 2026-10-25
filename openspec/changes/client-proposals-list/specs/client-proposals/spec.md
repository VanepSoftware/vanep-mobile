## ADDED Requirements

### Requirement: Open proposals grouped by what the client must do
The Open tab SHALL show a "Pending" section with the proposals the client must answer and an "Awaiting reply" section with the requests waiting for a driver. A section without items SHALL NOT be rendered.

#### Scenario: Both groups
- **WHEN** the client has two proposals to answer and one request sent
- **THEN** "Pending" lists two proposal cards and "Awaiting reply" lists one request card

#### Scenario: Lowered price
- **WHEN** a proposal has a previous monthly fee
- **THEN** the card shows "before R$ <previous fee>" under the price

#### Scenario: Driver without rating
- **WHEN** the driver has no rating
- **THEN** the card shows "New on Vanep" with the vehicle

### Requirement: Open and Closed tabs
The page SHALL show an Open / Closed control with the number of items in each tab for the current filter. The Closed tab SHALL list finished proposals with their outcome (accepted, declined, expired, cancelled).

#### Scenario: Switching tabs
- **WHEN** the client taps "Closed"
- **THEN** the closed proposals are listed and the open sections are hidden

### Requirement: Open-request cap
The page SHALL show "<n> of 5 open requests", where n counts proposals to answer plus requests sent across all children.

#### Scenario: Count ignores the filter
- **WHEN** a child filter is applied
- **THEN** the cap line keeps the account-wide count

### Requirement: Filter by child
When the client has more than one child, the page SHALL show a filter button that opens a sheet titled "See proposals of" with "All children" and one option per child, each with its age and open counts. Choosing an option SHALL filter both tabs. With one child or none, the button SHALL NOT be shown.

#### Scenario: Child summary
- **WHEN** Pedro has two proposals to answer and one request sent
- **THEN** his option reads "2 to answer · 1 awaiting"

#### Scenario: Child without open items
- **WHEN** Lucas has nothing open
- **THEN** his option reads "None open"

### Requirement: Entry points
The Home "Proposals" shortcut, the proposal items of "Needs you" and the "See proposals" action of the negotiating card SHALL open the Proposals page.

#### Scenario: Shortcut
- **WHEN** the client taps the Proposals shortcut
- **THEN** the Proposals page opens

### Requirement: Mocked data until the API exists
Until api-java #30 lands, proposals SHALL come from a mocked source selected by `CLIENT_PROPOSALS_SCENARIO`; with it empty, the page SHALL show the real children and the empty state.

#### Scenario: No scenario
- **WHEN** `CLIENT_PROPOSALS_SCENARIO` is empty
- **THEN** the Open tab shows the empty state and the filter lists the real dependents
