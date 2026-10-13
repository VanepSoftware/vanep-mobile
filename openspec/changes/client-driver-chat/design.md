## Context

`driver_profile_page.dart` already renders `VanepPrimaryButton(label: l10n.driverProfileChatButton, onPressed: () {})`. Clients reach that page from the driver search, often before any `client_driver` link exists. Drivers use the same app, through `driver_shell.dart`, whose home tab renders `VanepHomeTopBar` (menu and notifications).

The backend contract comes from the `client-driver-chat` change in `vanep-api-java`:

| Call | Who | Returns |
|---|---|---|
| `POST /api/conversations` `{driverToken}` | client | 201 new / 200 existing conversation |
| `GET /api/conversations/me` | driver | list, most recent message first |
| `GET /api/conversations/{token}/messages?page&size` | both parties | Spring `Page`, newest first |
| `POST /api/conversations/{token}/messages` `{body}` | both parties | 201 message |
| STOMP `/api/ws` → `SUBSCRIBE /topic/conversations/{token}` | both parties | same message shape as the REST response |

Conversation: `token`, `driverToken`, `driverName`, `clientName`, `lastMessageAt`. Message: `token`, `body`, `sender` (`CLIENT`/`DRIVER`), `sentAt`.

What already exists and is reused:

- Authenticated `Dio` with `AuthInterceptor` (token refresh on 401), built in `auth_container.dart`.
- `AuthLocalDataSource.readSession()` for the current access token.
- `Environment.authBaseUrl` as the single API base URL.
- `Result<E, T>`, `VanepFeedback`, `VanepComingSoon`/empty-state patterns, `VanepTextField`, `VanepAvatar`, `VanepSkeleton`.
- `readPagingInt` for Spring `Page` JSON, currently private to `ibge_locations`.
- Navigation via top-level `open*` functions in `app.dart` that push a `MaterialPageRoute` with its `BlocProvider`.

## Goals / Non-Goals

**Goals:**

- Client and driver exchange text messages, with live delivery while the chat is open.
- Four PRs, each ≤600 productive lines and ≤10 new files, one dependency layer per PR (R16–R23).

**Non-Goals:**

- Push notifications, read receipts, typing indicator, unread badge, attachments, edit/delete, a client conversation list, Flutter web, and offline queueing of unsent messages.

## Decisions

### D1 — One module, `conversations`

All chat code lives in `lib/modules/conversations/` with `conversations_container.dart`. The driver profile and the driver home do not import it. They receive callbacks (`onChatTapped`, `onMessagesTapped`) wired in `app.dart`, the composition root, as `openDriverSearch` and `openDriverProfile` already are (R02, R07).

### D2 — The chat page owns open-or-resume

The client route is `openDriverChat(context, driverToken)`. The `ChatCubit` calls `OpenConversation(driverToken)` and then loads the history. The driver route is `openConversationChat(context, conversation)`, where the cubit already has the conversation and loads the history directly. Both use the same `ChatPage` and `ChatCubit`.

**Alternative rejected:** open the conversation in the driver profile before navigating. That would make `DriverProfileCubit` depend on the conversations module (a cross-module import, R02) or need an extra cubit just for one request.

### D3 — The viewer's side is decided at the composition root

`ChatPage` receives `viewerSide: ConversationParticipant` (`client` from the profile route, `driver` from the inbox route). A bubble is "mine" when `message.sender == viewerSide`. This is one derivation in one place (R06a), and it needs no lookup of the current user's role.

### D4 — Realtime is a domain stream of events

`ConversationRepository.watchConversation(token)` returns `Stream<ConversationRealtimeEvent>`, a sealed type with `ConversationMessageReceived(message)` and `ConversationRealtimeReconnected`. The cubit appends received messages and, on reconnection, reloads the first history page (spec: reconnecting recovers missed messages). Cancelling the stream subscription disconnects the STOMP client.

**Why a domain event and not a raw message stream:** reconnection must trigger a reload, and only the cubit owns the message list (R06a). The data layer reports what happened, and the cubit decides.

### D5 — The cubit's message list is the single source of truth, keyed by token

The state holds messages ordered by `sentAt`. Inserting a message whose token is already present is a no-op. This covers the sender's own message arriving both in the `POST` response and on the topic, and also overlaps between a history reload and live messages.

### D6 — The WebSocket URL derives from `AUTH_URL`

`Environment` gains a `conversationsWebSocketUrl` getter: `authBaseUrl` with `http`→`ws` / `https`→`wss` and the path `/api/ws`. No new `.env` variable, so the two URLs cannot point at different servers.

### D7 — The token goes in the handshake header

The STOMP datasource reads the access token through the same function the `AuthInterceptor` uses (`readSession()?.accessToken`) and passes it as `Authorization: Bearer …` in `webSocketConnectHeaders`. The backend authenticates the upgrade like any `/api/**` route. When the handshake fails with an expired token, the datasource refreshes through `AuthRepository.refreshSession()` once and retries. This is supported on Android and iOS, not on web (out of scope).

### D8 — `stomp_dart_client`

It speaks STOMP 1.2 with heartbeats and automatic reconnection (`reconnectDelay`) and supports connect headers.

**Alternative rejected:** raw `web_socket_channel` with hand-rolled STOMP frames. It is less code to depend on, but more code to own (framing, heartbeat, reconnection), all of which would need tests.

### D9 — Spring `Page` parsing moves to core

`readPagingInt` moves from `ibge_locations` to `lib/core/network/`, and both modules use it. The history DTO maps `content` and the paging fields to a domain `ConversationMessagePage(messages, hasMore)`.

### D10 — UI reuses the design system

The message input composes `VanepTextField` with an icon send button. Bubbles use design-system color and typography tokens. If no bubble fits in `lib/core/ui/`, `ConversationMessageBubble` stays in the module's `presentation/widgets/` (it is chat-specific, not shared chrome). The messages action is an optional `onMessagesTapped` on `VanepHomeTopBar`, so the client shell, which does not pass it, renders unchanged (R10a/R10b).

### Module layout

```
lib/modules/conversations/
├── conversations_container.dart
├── domain/
│   ├── entities/        conversation.dart,
│   │                    conversation_message.dart (+ ConversationParticipant,
│   │                    ConversationMessagePage: they only exist for the message)
│   ├── value_objects/   conversation_realtime_event.dart
│   ├── failures/        conversation_failure.dart
│   ├── repositories/    conversation_repository.dart
│   └── usecases/        open_conversation.dart, list_driver_conversations.dart,
│                        list_conversation_messages.dart,
│                        send_conversation_message.dart, watch_conversation.dart
├── data/
│   ├── dtos/            conversation_dto.dart, conversation_message_dto.dart
│   ├── datasources/     conversation_remote_datasource.dart,
│   │                    conversation_realtime_datasource.dart
│   └── repositories/    conversation_repository_impl.dart
└── presentation/
    ├── cubit/           chat_cubit.dart, chat_state.dart,
    │                    driver_conversations_cubit.dart, driver_conversations_state.dart
    ├── pages/           chat_page.dart, driver_conversations_page.dart
    └── widgets/         conversation_message_bubble.dart, conversation_input_bar.dart,
                         driver_conversation_tile.dart
```

### Flow

```
 client: driver profile ──[Conversar]──▶ openDriverChat(driverToken)
                                              │
 driver: home top bar ──[✉]──▶ DriverConversationsPage ──tap──▶ openConversationChat(conv)
                                              │
                                              ▼
                         ChatPage(viewerSide) + ChatCubit
                         ├ OpenConversation (client route only)
                         ├ ListConversationMessages (page 0, then older)
                         ├ WatchConversation ── received ─▶ insert by token
                         │                   └─ reconnected ▶ reload page 0
                         └ SendConversationMessage ─▶ insert by token
```

## Risks / Trade-offs

- **[Messages missed while disconnected]** → D4: reload the first page on reconnection. The REST history is the source of truth.
- **[Expired token on a long-open socket]** → the backend validates only at the handshake, so the open socket keeps working. Every reconnection reads the current token (D7). Sending is REST, which already refreshes on 401.
- **[Backend phases not merged yet]** → M1 has no backend dependency. M2 tests use mocked `Dio` and a fake STOMP client. M3 and M4 can be built against stubbed repositories and verified on device only after backend B2 (REST) and B3 (realtime) are deployed (R21, R27a).
- **[M3 is the tightest phase]** → if it exceeds 600 lines, split the input bar and bubble widgets into their own PR before the cubit and page.
- **[Rate limiting on the backend]** → tracked in the backend change (B3).

## Open Questions

None blocking. Decided: only the client starts a conversation, a conversation is unique per client–driver pair and outlives the link, and the driver entry point is a messages icon in the home top bar.
