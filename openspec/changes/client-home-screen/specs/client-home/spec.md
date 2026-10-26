## ADDED Requirements

### Requirement: Fixed block structure
The client Home tab SHALL render three blocks in this fixed order: Today, Needs you, Shortcuts. The order SHALL NOT change between states; a state only changes the content of a block.

#### Scenario: Blocks keep their order
- **WHEN** the Home renders any of the seven states
- **THEN** the Today block appears before Needs you, and Needs you before Shortcuts

#### Scenario: Needs you hidden when empty
- **WHEN** there are no pending items
- **THEN** the Needs you block is not rendered and Shortcuts follows Today directly

### Requirement: Today block grouped by van
The Today block SHALL group children by van, not by child. Siblings on the same van SHALL share one card, and a child not going today SHALL be shown as absent within that card. The van departing first, or the one that is live, SHALL be expanded; other vans SHALL collapse into a single row.

#### Scenario: Siblings on one van
- **WHEN** two dependents are linked to the same van
- **THEN** one van card lists both, with one avatar per child

#### Scenario: Child not going today
- **WHEN** a dependent has an absence for today
- **THEN** their avatar is dimmed and the card shows "not going today" with an undo action

#### Scenario: Multiple vans
- **WHEN** dependents belong to two vans
- **THEN** the van that leaves first is expanded and the other is a collapsed row

#### Scenario: Dependents without a route
- **WHEN** some dependents have no van or no route today
- **THEN** they are grouped in one collapsed row stating why each has no route

### Requirement: First access state
When the client has no linked van and has not completed onboarding steps, the Today block SHALL be replaced by a first-steps card showing progress ("n of 3"), the completed steps, the current step with a primary action, and the pending steps. A "I received a driver invite" row and a "How Vanep works" section SHALL follow.

#### Scenario: Progress reflects real data
- **WHEN** the client has an address but no dependent
- **THEN** the card shows 2 of 3 steps complete and the third step as current

#### Scenario: Step completion removes the card
- **WHEN** all three steps are complete
- **THEN** the first-steps card is no longer shown

### Requirement: Negotiating without a van
When the client has dependents without a van and at least one open negotiation, the Today block SHALL state that the dependents have no van yet, show the number of negotiations in progress, and offer "See proposals" and "Search vans".

#### Scenario: Open negotiations
- **WHEN** three negotiations are open and no dependent has a van
- **THEN** the block reads "3 negotiations in progress" with both actions

### Requirement: Needs you prioritization
The Needs you block SHALL show at most three items ordered by tier, then by the closest deadline within a tier. Tiers, highest first: a decision with a short deadline (contract awaiting signature), proposals (new proposal, expired request), payments, then follow-ups (renewal, vehicle document, rating). When more than three items exist, the block SHALL show a "See all" action. When the first visible item is a contract to sign or a new proposal, it SHALL be shown expanded with its actions; the others are compact rows. A SUSPENDED contract item is out of scope until its design exists.

#### Scenario: Cap of three
- **WHEN** five items are pending
- **THEN** only the three highest priority items are shown, plus "See all"

#### Scenario: Signature before payment
- **WHEN** a contract awaits signature until Friday and a monthly fee is due tomorrow
- **THEN** the contract item is listed first and shown expanded, and the payment is a row

#### Scenario: Closest deadline within a tier
- **WHEN** two proposals expire in 6 and 2 days
- **THEN** the one expiring in 2 days is listed first

### Requirement: Live van state
When a route is in progress, the Today block SHALL show the live van card with the ETA to the child's stop, the route progress (boarding, school, departure, home), a "Live map" action and a "Talk to the driver" action, and the freshness of the data.

#### Scenario: Live ETA
- **WHEN** the van is 6 minutes from the stop
- **THEN** the card shows "6 min to your stop" with the estimated time

#### Scenario: Map unavailable
- **WHEN** the live map integration is not available
- **THEN** the "Live map" action is disabled and the card still renders

### Requirement: Arrival state
When a child has been dropped at school, the Home SHALL show a confirmation with the confirmed time, the school, the next departure time, and a "Today" timeline of events (route started, boarded, dropped, absence) with a "See all" action.

#### Scenario: Timeline order
- **WHEN** the timeline has four events
- **THEN** they are listed newest first, each with time, description and who recorded it

### Requirement: No route today state
When there is no route today, the Today block SHALL show "No route today", the next route date and time, a week strip of upcoming days, and any one-way notice (for example "return is with you").

#### Scenario: Weekend
- **WHEN** today is Saturday
- **THEN** the greeting is the weekend greeting and the next route is the following Monday

### Requirement: Shortcuts availability
The Shortcuts block SHALL always render the same six shortcuts: report absence, see on map, adjust stop, payments, proposals, contracts. A shortcut whose destination does not exist yet or cannot be used in the current state SHALL be disabled or open the coming-soon surface; it SHALL NOT be hidden.

#### Scenario: Six shortcuts always present
- **WHEN** the Home renders in any state
- **THEN** six shortcuts are visible

#### Scenario: Unavailable destination
- **WHEN** the user taps a shortcut with no implemented destination
- **THEN** the coming-soon surface is shown

### Requirement: Data source contract
The Home SHALL obtain its content only through a domain `ClientHomeRepository` contract returning a typed home state. The presentation layer SHALL NOT know whether the implementation is fake or remote. Loading, empty and error states SHALL use the shared feedback and error views.

#### Scenario: Loading and error
- **WHEN** the repository is loading or fails
- **THEN** a skeleton or the shared error view with retry is shown instead of blocks

#### Scenario: Swapping implementation
- **WHEN** the fake repository is replaced by a remote one in DI
- **THEN** no presentation code changes

### Requirement: Localization and touch targets
All visible copy SHALL come from localization files in pt-BR and en, and interactive elements SHALL have a touch target of at least 44px.

#### Scenario: No hardcoded copy
- **WHEN** the Home is rendered in en
- **THEN** every label comes from the localization files
