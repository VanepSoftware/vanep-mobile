## ADDED Requirements

### Requirement: One contract per family and one price per student
The compose screen SHALL show one family and one monthly price for each student. The driver SHALL be able to change a student's price. The screen SHALL describe the draft as one contract for the family and one item per student.

#### Scenario: Two students
- **WHEN** the draft has two students
- **THEN** the screen shows the family name and a price field for each student

#### Scenario: Price change
- **WHEN** the driver changes a student's monthly price
- **THEN** that line updates and the other lines stay the same

### Requirement: Route schedule by day and leg
The screen SHALL list the schedule grouped by weekday. Each day SHALL show its route legs with the time stored on the slot. The driver SHALL NOT edit those times.

#### Scenario: Outbound and return
- **WHEN** a weekday has an outbound slot and a return slot
- **THEN** that day shows both legs with their times

### Requirement: Standard driver conditions
The screen SHALL show the driver's standard due day and notes as read-only.

#### Scenario: Due day
- **WHEN** the draft due day is 10
- **THEN** the conditions show that day and the notes

### Requirement: Commission and amount received
The screen SHALL show the family total, the Vanep commission and the amount the driver receives. The received amount SHALL be the family total minus the commission.

#### Scenario: Summary
- **WHEN** the student prices sum to R$ 630 and the commission is R$ 5
- **THEN** the summary shows the family total, the commission and R$ 625 received

### Requirement: Overdue invoice pauses sending
An overdue invoice SHALL keep the form visible and SHALL disable sending. `SendDriverProposal` SHALL refuse the draft with an overdue-invoice failure and SHALL NOT call the repository.

#### Scenario: Send is paused
- **WHEN** the draft is blocked by an overdue invoice
- **THEN** the form is visible, the send button is disabled and a pause message is shown

### Requirement: Accepting new students off blocks compose
When the driver is not accepting new students, the screen SHALL NOT show the form or the send button. It SHALL explain that accepting new students is off. `SendDriverProposal` SHALL refuse the draft and SHALL NOT call the repository.

#### Scenario: Compose is blocked
- **WHEN** the draft is blocked because the driver is not accepting new students
- **THEN** the price, schedule and send button are absent and the block message is shown

### Requirement: Send a valid proposal
Sending SHALL be enabled only when there is no gate, every student price is above zero and the driver would receive a positive amount. A successful send SHALL tell the driver the proposal was sent.

#### Scenario: Enabled send
- **WHEN** the draft is open and every price is valid
- **THEN** the send button is enabled

#### Scenario: Successful send
- **WHEN** the driver sends a valid proposal and the repository accepts it
- **THEN** the driver sees that the proposal was sent
