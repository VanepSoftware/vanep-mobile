# Tasks & Phased Delivery: Client–Driver Chat

### Phased delivery (R16–R23)

| Phase | Contents | Depends on | Parallel with |
|---|---|---|---|
| **M1** | Domain: entities, realtime event, failures, repository contract, 5 use cases | — | Backend B1 |
| **M2** | Data: DTOs, REST and STOMP datasources, repository implementation, DI, WebSocket URL, paging helper moved to core | M1 merged | Backend B2/B3 (mocked) |
| **M3** | Client chat: `ChatCubit`, `ChatPage`, bubble and input widgets, `openDriverChat`, wire `driverProfileChatButton`, l10n | M2 merged | — |
| **M4** | Driver inbox: `DriverConversationsCubit`, page and tile, messages action on `VanepHomeTopBar`, `openConversationChat` | M3 merged | — |

Cap per PR: 600 productive lines and 10 new production files (R23). Estimate (production / tests): M1 ~150 / ~150, M2 ~300 / ~250, M3 ~350 / ~250, M4 ~200 / ~150.

Device verification of M3 and M4 needs backend B2 (REST) and B3 (realtime) deployed to the environment the app points at.

> ⚠️ **R27a: nenhum commit sem a sua aprovação explícita.** Ao final de cada fase, `make lint` e `make test` passando não bastam. Eu paro e espero você validar no emulador ou no aparelho antes de commitar ou abrir PR.

---

## 0. Preparation

- [x] 0.1 Read the whole `constitution.md` before any work
- [x] 0.2 Review `proposal.md`, `design.md` and the `client-driver-chat` spec, plus the backend change of the same name in `vanep-api-java`
- [x] 0.3 Issue: vanep-mobile #38. Its body is outdated (contract-only chat, unread, push); this spec is the source of truth

## 1. Phase M1 — Domain (branch: `feat/38-chat-domain`)

> Goal: the chat's business contract exists and is tested, with no Flutter, HTTP or STOMP dependency.
> Order: test → domain contract → entity → use case

- [x] 1.1 Fixtures `test/modules/conversations/conversations_fixtures.dart` and mocks `test/modules/conversations/conversations_mocks.dart` (same layout as `dependents`)
- [x] 1.2 Entity `Conversation` (`token`, `driverToken`, `driverName`, `clientName`, `lastMessageAt`) with value equality
- [x] 1.3 `conversation_message.dart`: enum `ConversationParticipant` (`client`, `driver`), entity `ConversationMessage` (`token`, `body`, `sender`, `sentAt`) and `ConversationMessagePage` (`messages`, `hasMore`)
- [x] 1.4 Sealed `ConversationRealtimeEvent`: `ConversationMessageReceived(message)` and `ConversationRealtimeReconnected` (D4)
- [x] 1.5 `ConversationFailure` hierarchy: network, driver unavailable (404), message rejected (400), forbidden (403)
- [x] 1.6 Contract `ConversationRepository`: `openConversation(driverToken)`, `listDriverConversations()`, `listMessages(conversationToken, page)`, `sendMessage(conversationToken, body)`, `watchConversation(conversationToken)`
- [x] 1.7 Use cases with `mocktail` tests: `OpenConversation`, `ListDriverConversations`, `ListConversationMessages`, `SendConversationMessage` (rejects blank and >2000 characters before calling the repository), `WatchConversation`
- [x] 1.8 Run `make lint` and `make test`
- [x] 1.9 **Wait for developer validation (R27a)**, then commit and open the PR

## 2. Phase M2 — Data (branch: `feat/38-chat-data`)

> Goal: the contract talks to the real API over REST and STOMP.
> Order: test → DTO → datasource → repository → DI

- [x] 2.1 Create the branch from `feat/38-chat-domain`
- [x] 2.2 Move `readPagingInt` from `ibge_locations` to `lib/core/network/` and update its caller (D9). Existing tests stay green
- [x] 2.3 `Environment.conversationsWebSocketUrl` derived from `authBaseUrl` (`http`→`ws`, `https`→`wss`, path `/api/ws`), with a unit test for both schemes (D6)
- [x] 2.4 Freezed DTOs `ConversationDto` and `ConversationMessageDto` implementing the entities, mapping `sender` to `ConversationParticipant`. Run `build_runner` (R15)
- [x] 2.5 `ConversationRemoteDatasource` (authenticated `Dio`): the four REST calls, mapping the history `Page` to `ConversationMessagePage`. Tests with mocked `Dio` and JSON fixtures
- [x] 2.6 Add `stomp_dart_client`. `ConversationRealtimeDatasource`: connects with `Authorization: Bearer` in `webSocketConnectHeaders` (D7), subscribes to `/topic/conversations/{token}`, emits `ConversationRealtimeEvent`s, signals reconnection, refreshes the token once on handshake failure, and disconnects when the stream is cancelled. Reconnection is driven by the datasource (one `StompClient` per attempt) because `StompConfig` fixes the handshake headers. Tests with a fake STOMP client
- [x] 2.7 `ConversationRepositoryImpl`: wraps both datasources in `Result` and maps HTTP status codes to `ConversationFailure`. Tests
- [x] 2.8 `conversations_container.dart`: register datasources, repository and use cases, and call it from the app's DI setup. The token functions move out of `AuthInterceptor` wiring into `AccessTokenSource` (`lib/core/network`), registered by `auth_container` and shared by the interceptor and the realtime datasource (R02, R06a)
- [x] 2.9 Run `make lint` and `make test`
- [x] 2.10 **Wait for developer validation (R27a)**, then commit and open the PR

## 3. Phase M3 — Client chat (branch: `feat/38-chat-client-page`)

> Goal: the client taps "Conversar com o motorista" and chats with the driver in real time.
> Order: test → cubit → page/widget

- [x] 3.1 Create the branch from `feat/38-chat-data`
- [x] 3.2 `bloc_test` for `ChatCubit`: open-or-resume then load (client route), load directly (driver route), open failure with retry, older page on scroll, send success (input cleared), send failure (text kept), live message inserted, duplicate token ignored (D5), reload on reconnection, subscription cancelled on `close()`
- [x] 3.3 `ChatState` and `ChatCubit` (D2, D4, D5). Messages ordered by `sentAt`, unique by token
- [x] 3.4 Widgets `ConversationMessageBubble` (aligned by `sender == viewerSide`, D3) and `ConversationInputBar` (uses the shared `vanepInputDecoration`, since `VanepTextField` always renders a label; send disabled when blank or sending, 2000-character limit) using design-system tokens (D10)
- [x] 3.5 `ChatPage(viewerSide)`: reversed list, loading spinner, error with retry through `VanepErrorView` (promoted from `drivers`' `DriversErrorView` to `lib/core/ui`, R10b), older pages on scroll. Widget test for alignment and the disabled send button
- [x] 3.6 ARB keys in `app_pt.arb` and `app_en.arb`: page title, input hint, send, empty conversation, open/load/send errors, retry if no existing key fits
- [x] 3.7 `openDriverChat(context, driverToken)` in `app.dart` with `viewerSide: client`. Pass it to `DriverProfilePage` as a callback and wire `driverProfileChatButton` (D1)
- [x] 3.8 Register `ChatCubit` as a factory in `conversations_container.dart`
- [x] 3.9 Run `make lint` and `make test`
- [x] 3.10 PR opened. The developer asked to open every phase PR without stopping for device validation (2026-10-12); the on-device check below stays pending before merge: against an API with B2 and B3: open a new conversation, reopen it, send, receive live from a second session, and drop/restore the network to see missed messages appear. Then commit and open the PR

## 4. Phase M4 — Driver inbox (branch: `feat/38-chat-driver-inbox`)

> Goal: the driver sees who messaged them and replies.
> Order: test → cubit → page/widget

- [x] 4.1 Create the branch from `feat/38-chat-client-page`
- [x] 4.2 `bloc_test` for `DriverConversationsCubit`: loaded list, empty state, failure with retry, reload when returning from a chat
- [x] 4.3 `DriverConversationsState` and `DriverConversationsCubit`
- [x] 4.4 `DriverConversationTile` (client name and last message time, design-system list-row tokens) and `DriverConversationsPage` (loading, empty, error, list)
- [x] 4.5 `VanepHomeTopBar`: optional `onMessagesTapped`. The icon renders only when it is provided. Widget test: client shell unchanged, driver shell shows the icon
- [x] 4.6 `openDriverConversations(context)` and `openConversationChat(context, conversation)` with `viewerSide: driver` in `app.dart`. Wire them through `driver_shell.dart` (new required `openConversations`, like `openMyVans`) and `DriverHomeTab` (optional `onMessagesTapped`)
- [x] 4.7 ARB keys: messages action tooltip, inbox title, empty state
- [x] 4.8 Register `DriverConversationsCubit` in `conversations_container.dart`
- [x] 4.9 Run `make lint` and `make test`
- [x] 4.10 PR opened without per-phase device validation, at the developer's request (2026-10-12); the on-device check below stays pending before merge:: the driver opens the inbox, sees the client's conversation on top, replies, and the client receives the reply live. Then commit and open the PR

## 5. Phase M5 — Chat in the bottom navigation (branch: `feat/38-chat-tabs`)

> Goal: the chat is a bottom-navigation tab for both sides instead of an icon in the driver's top bar.

- [x] 5.1 Driver tabs: Início · Vans · Propostas · **Mensagens**. "Alunos" leaves the bottom bar and becomes an item of the Vans hub (still coming soon)
- [x] 5.2 Client tabs: Início · Vans · **Mensagens** · Dependentes. "Contratos" leaves the bottom bar; it returns inside Vans when contracts exist
- [x] 5.3 Driver "Mensagens" tab reuses the conversation list (`DriverConversationsTab`), reloads when selected and opens the chat. The top-bar messages icon from M4 is removed
- [x] 5.4 Client "Mensagens" tab shows coming soon: listing the client's conversations needs a backend route that does not exist yet
- [x] 5.5 Run `make lint` and `make test`; open the PR
