## ADDED Requirements

### Requirement: The client opens the chat from the driver profile

Tapping `driverProfileChatButton` on the driver profile MUST navigate to the chat page for that driver. The chat page MUST ask the API to open or resume the conversation before loading its history. The app MUST NOT keep its own record of which drivers already have a conversation. The API's open-or-resume answer is the single source of truth (R06a).

#### Scenario: First contact with a driver

- **WHEN** a client with no conversation with the driver taps "Conversar com o motorista"
- **THEN** the app opens the chat page of the newly created conversation, with an empty history

#### Scenario: Returning to an existing conversation

- **WHEN** a client who already talked to the driver taps "Conversar com o motorista"
- **THEN** the app opens the chat page of the same conversation, showing its previous messages

#### Scenario: Opening the conversation fails

- **WHEN** the open-or-resume request fails (network error or the driver is no longer available)
- **THEN** the chat page shows a localized error with a retry action, and the user can go back to the driver profile

### Requirement: The driver lists received conversations

The driver's home top bar MUST show a messages action. It MUST open a list of the driver's conversations, ordered as the API returns them (most recent message first). Each item MUST show the client's name and the time of the last message. Tapping an item MUST open the chat page of that conversation. The client's home MUST NOT show this action.

#### Scenario: The driver opens the list

- **WHEN** a driver with conversations taps the messages action
- **THEN** the app shows those conversations, most recent first, each with the client's name and last message time

#### Scenario: The driver has no conversations

- **WHEN** a driver with no conversation opens the list
- **THEN** the app shows a localized empty state

#### Scenario: The list fails to load

- **WHEN** loading the list fails
- **THEN** the app shows a localized error with a retry action

### Requirement: The chat shows the history, newest at the bottom

The chat page MUST load the most recent page of messages on open and show them in chronological order, with the newest message at the bottom. Scrolling to the oldest loaded message MUST load the next older page until the API reports no more. Each message MUST be aligned to the viewer's side when its sender side matches the viewer's side (`CLIENT` for the client, `DRIVER` for the driver), and to the other side otherwise.

#### Scenario: Messages are aligned by sender

- **WHEN** the client opens a conversation with messages from both sides
- **THEN** the client's messages appear on the viewer's side and the driver's on the other side

#### Scenario: Older messages load on scroll

- **WHEN** the conversation has more messages than the first page and the user scrolls to the oldest loaded message
- **THEN** the app loads and shows the next older page above it

### Requirement: Both sides send text messages

The chat page MUST let the user send a text message through the API. The send action MUST be disabled while the input is blank. Text longer than 2000 characters MUST NOT be sent. While a message is being sent, the input MUST NOT accept a second send. After the API confirms, the message MUST appear once in the conversation and the input MUST be cleared. If sending fails, the typed text MUST stay in the input and the app MUST show a localized error.

#### Scenario: Sending a message

- **WHEN** the user types "Tem vaga para a manhã?" and taps send
- **THEN** the message appears on the viewer's side and the input is cleared

#### Scenario: Blank input cannot be sent

- **WHEN** the input is empty or holds only whitespace
- **THEN** the send action is disabled

#### Scenario: Sending fails

- **WHEN** the API rejects the message or the network fails
- **THEN** the typed text stays in the input and a localized error is shown

### Requirement: New messages arrive live while the chat is open

While the chat page is open, the app MUST subscribe to the conversation's realtime topic with the current access token. It MUST add each received message to the conversation. A message already present (for example, the sender's own message, received both as the REST response and on the topic) MUST NOT be shown twice, matched by message token. Closing the page MUST end the subscription. When the connection drops and comes back, the app MUST reload the latest history page, so that messages published while disconnected are shown.

#### Scenario: The other side's message arrives live

- **WHEN** the driver has the chat open and the client sends a message to that conversation
- **THEN** the message appears on the driver's screen without any user action

#### Scenario: The sender's own message is not duplicated

- **WHEN** the user sends a message and receives it on the realtime topic as well
- **THEN** the message appears exactly once

#### Scenario: Reconnecting recovers missed messages

- **WHEN** the connection drops, the other side sends a message, and the connection comes back
- **THEN** the missed message appears in the conversation

#### Scenario: Leaving the chat stops listening

- **WHEN** the user leaves the chat page
- **THEN** the app closes the realtime subscription for that conversation
