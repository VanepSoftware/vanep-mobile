## Why

The driver profile already shows a "Conversar com o motorista" button (`driverProfileChatButton`), but it does nothing (`onPressed: () {}`). A client who finds a van in the search has no way to ask the driver anything, before or after hiring them, and the driver has nowhere to answer. This change delivers the minimum for both sides to exchange text messages in real time, on top of the `client-driver-chat` contract in `vanep-api-java`.

## What Changes

- New `conversations` module (domain, data, presentation) following R01/R02.
- **Client:** tapping "Conversar com o motorista" opens a chat with that driver. The app always asks the API to open or resume the conversation, so it never needs to know whether one already exists.
- **Driver:** a messages icon in the home top bar (`VanepHomeTopBar`, next to notifications) opens the list of conversations the driver received, most recent first. Tapping one opens the same chat page the client uses.
- **Chat page:** loads the latest history page, loads older pages on scroll, sends text, and shows new messages live while the page is open. Bubbles are aligned by sender side (`CLIENT`/`DRIVER`) against the viewer's side.
- **Realtime:** a STOMP-over-WebSocket datasource (`stomp_dart_client`) subscribes to `/topic/conversations/{token}` at `/api/ws`. Its URL is derived from the existing `AUTH_URL`, and the handshake carries the bearer token from the existing session. Sending stays REST through the authenticated `Dio`.
- New dependency `stomp_dart_client`. No new `.env` variable.

**Out of scope** (can come later without breaking the contract): push notifications while the app is closed, read receipts, typing indicator, unread count/badge, attachments, editing or deleting messages, a conversation list for the client, the web frontend, and offline queueing of unsent messages.

## Capabilities

### New Capabilities
- `client-driver-chat`: the client opens or resumes a conversation from the driver profile, the driver lists received conversations, and both exchange text messages with live delivery while the chat is open.

### Modified Capabilities

None.

## Impact

- **Code:** new `lib/modules/conversations/` with its `conversations_container.dart`. `driver_profile_page.dart` wires the button. `VanepHomeTopBar` gains an optional messages action. `DriverHomeTab`/`driver_shell.dart` pass it. `app.dart` gains `openConversation` and `openDriverConversations`. `Environment` derives the WebSocket URL. New ARB keys in `app_pt.arb` and `app_en.arb`.
- **Dependencies:** `stomp_dart_client`.
- **Backend:** depends on the `client-driver-chat` change in `vanep-api-java` (REST in phase B2, WebSocket in phase B3). Mobile phases that land first use stubs (R21).
- **Platforms:** Android and iOS. The handshake header is not available on Flutter web, which is not a target of this change.
