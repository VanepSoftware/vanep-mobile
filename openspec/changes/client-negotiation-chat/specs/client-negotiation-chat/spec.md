## ADDED Requirements

### Requirement: Chat header with the counterpart
The chat SHALL show the counterpart's avatar with initials, name and role. When a current proposal exists, the role SHALL be followed by the proposal's vehicle. On the client side, an info button SHALL open the driver profile.

#### Scenario: Client with a proposal
- **WHEN** the client opens a chat whose current proposal uses a "Master 2019"
- **THEN** the header shows "João Pedro Lima" and "Driver · Master 2019" with an info button

### Requirement: Current proposal banner
While the negotiation has a proposal, the chat SHALL show under the header the latest version, its monthly fee and its expiry date, with a "See" action.

#### Scenario: Two versions
- **WHEN** the negotiation has versions 1 and 2
- **THEN** the banner shows "Proposal v2 · R$ 300/mo · expires on 21/10"

#### Scenario: No proposal yet
- **WHEN** only the quote request was sent
- **THEN** no banner is shown

### Requirement: Negotiation timeline
The chat SHALL list text messages and negotiation events in chronological order, with a day divider whenever the day changes. Cards sent by the viewer SHALL align right with "You · <time>"; cards from the other side align left.

#### Scenario: Request, proposals and adjustment
- **WHEN** the negotiation has a request, proposal v1, an adjustment request and proposal v2
- **THEN** they appear in that order mixed with the messages by time, v1 faded with "Replaced" and v2 marked "Current"

#### Scenario: Notices
- **WHEN** the timeline has a quote request and a current proposal
- **THEN** the privacy notice follows the request and the "only what is in the proposal counts" notice follows the current proposal

### Requirement: Answering a proposal
The current proposal card SHALL show "See proposal" and "Accept", and the input SHALL show an adjustment button, only to the side that received the proposal.

#### Scenario: Client receives a proposal
- **WHEN** the driver sent the current proposal and the client opens the chat
- **THEN** "See proposal", "Accept" and the adjustment button are shown

#### Scenario: Driver sees their own proposal
- **WHEN** the driver opens the same chat
- **THEN** the proposal card has no actions and the input has no adjustment button

### Requirement: Chat without negotiation
When the conversation has no negotiation, the chat SHALL behave as before: no banner, no cards, no notices and no adjustment button.

#### Scenario: Production today
- **WHEN** no negotiation scenario is configured
- **THEN** the chat shows only the real messages with day dividers
