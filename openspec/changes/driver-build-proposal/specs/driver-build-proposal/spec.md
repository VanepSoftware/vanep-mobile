## ADDED Requirements

### Requirement: One contract per family and one price per student
The compose screen SHALL show the family and its students in the header. It SHALL show one monthly price for each student with the legs that student rides. The driver SHALL be able to change a student's price.

#### Scenario: Two students
- **WHEN** the draft has two students
- **THEN** the header shows the family and both names, and each student has a price field

#### Scenario: Price change
- **WHEN** the driver changes a student's monthly price
- **THEN** that line updates and the other lines stay the same

### Requirement: Van choice
The screen SHALL show the selected van (model and plate) and the free seats and capacity for the request's shift. The driver SHALL be able to pick another of their vans. Sending SHALL require enough free seats for every student.

#### Scenario: Van without seats
- **WHEN** the selected van has fewer free seats than students
- **THEN** a warning is shown and sending is disabled

### Requirement: Contract summary with Vanep commission
The screen SHALL show the family total, the Vanep commission and the amount the driver receives for the whole contract, each with its per-installment value. The commission SHALL be a fixed amount per month (R$ 5). The received amount SHALL be the family total minus the commission.

#### Scenario: Summary
- **WHEN** the student prices sum to R$ 620, the commission is R$ 5 and there are 12 installments
- **THEN** the summary shows R$ 7.440 (12x de R$ 620), R$ 60 (12x de R$ 5) and R$ 7.380 (12x de R$ 615)

### Requirement: Payment and period
The screen SHALL show installments with the due day and the contract period. The driver SHALL be able to change the installments (1 to 12), the due day and the period. The period end SHALL be after its start.

#### Scenario: Installments change
- **WHEN** the driver picks 10 installments
- **THEN** the summary and the footer use 10 installments

### Requirement: Days and legs
The screen SHALL show a grid of school weekdays by leg (outbound, return), starting from the family's request. The driver SHALL be able to toggle each cell. The grid SHALL say whether it matches the request. Sending SHALL require at least one cell.

#### Scenario: Toggle a leg
- **WHEN** the driver turns off Friday return
- **THEN** that cell is off and the grid says it differs from the request

### Requirement: Route times
The screen SHALL show the pickup window, school arrival, school departure and maximum wait at the stop, calculated by the route. The driver SHALL be able to edit them. The pickup window end SHALL NOT be before its start.

#### Scenario: Edit departure
- **WHEN** the driver changes the departure to 18h30
- **THEN** the times show 18h30

### Requirement: Conditions
The screen SHALL show the reservation fee, the readjustment and the cancellation terms, starting from the driver's defaults. The driver SHALL be able to edit them for this proposal.

#### Scenario: Defaults
- **WHEN** the draft opens with the driver's defaults
- **THEN** the conditions show the reservation fee, readjustment and cancellation terms

### Requirement: Message and validity
The screen SHALL offer an optional message to the family and SHALL state how many days the proposal stays valid.

### Requirement: Overdue invoice pauses sending
An overdue invoice SHALL keep the form visible and SHALL disable sending. `SendDriverProposal` SHALL refuse the draft with an overdue-invoice failure and SHALL NOT call the repository.

#### Scenario: Send is paused
- **WHEN** the draft is blocked by an overdue invoice
- **THEN** the form is visible, the send button is disabled and a pause message is shown

### Requirement: Accepting new students off blocks compose
When the driver is not accepting new students, the screen SHALL NOT show the form or the send button. It SHALL explain that accepting new students is off. `SendDriverProposal` SHALL refuse the draft and SHALL NOT call the repository.

#### Scenario: Compose is blocked
- **WHEN** the draft is blocked because the driver is not accepting new students
- **THEN** the prices, schedule and send button are absent and the block message is shown

### Requirement: Send a valid proposal
Sending SHALL be enabled only when there is no gate, every student price is above zero, the driver would receive a positive amount, the van has enough free seats and at least one day and leg is selected. A successful send SHALL tell the driver the proposal was sent.

#### Scenario: Enabled send
- **WHEN** the draft is open and every value is valid
- **THEN** the send button is enabled

#### Scenario: Successful send
- **WHEN** the driver sends a valid proposal and the repository accepts it
- **THEN** the driver sees that the proposal was sent
