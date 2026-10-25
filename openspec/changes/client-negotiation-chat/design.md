## Context

The chat (VAN-38) is a `ChatCubit` + `ChatPage` in `lib/modules/conversations/`, fed by REST and STOMP. The negotiation shown in the design (request, proposal versions, adjustment requests) has no API yet. VAN-41 and VAN-42 solved the same gap with an empty data source for production and a scenario data source selected by an env var, every mocked block carrying a `TODO(VAN-XX)` (R40b).

## Goals / Non-Goals

**Goals:**
- Render the design's negotiation timeline inside the existing chat, mixed with the real messages.
- Keep the chat unchanged when there is no negotiation (production today, driver side).
- Replace the mocked negotiation with the API by touching only the data layer.

**Non-Goals:**
- Proposal detail, accept and adjustment flows (VAN-43); driver-side negotiation screens (VAN-58 to VAN-60).

## Decisions

- **Negotiation lives in the conversations module.** It is read per conversation (the `client_driver` pair) and only rendered by the chat, so it stays next to it: `ConversationNegotiation` and the sealed `NegotiationEvent` (`QuoteRequestEvent`, `ProposalVersionEvent`, `AdjustmentRequestEvent`) are value objects; `ConversationNegotiationRepository` is a contract separate from `ConversationRepository` so the mocked source never mixes with the real chat sources.
- **Derived, not stored (R06a).** The current proposal is the latest version; older versions are "replaced". The header vehicle comes from the current proposal. Whether the viewer may accept or ask for an adjustment comes from "the proposal was sent by the other side".
- **One timeline function.** `buildChatTimeline(messages, negotiation)` (domain) merges messages and events by time and inserts day dividers and the two notices. Widgets only render entries.
- **Side-neutral by author.** Every event has an `author` (`ConversationParticipant`); cards align like bubbles (viewer's on the right) and "You" is derived from `author == viewerSide`. No client-only branch in the page.
- **`ChatCubit` owns it.** After the conversation is resolved, the cubit loads messages and the negotiation together. A negotiation failure keeps the chat usable and surfaces through the existing failure snackbar.
- **Mocked data.** `EmptyConversationNegotiationDataSource` (production) and `ScenarioConversationNegotiationDataSource` selected by `CONVERSATION_NEGOTIATION_SCENARIO` (`negotiating`, `requestSent`). Times are relative to now, so the real messages sent today land after the mocked events.
- **Unbuilt actions.** "See" (banner), "See proposal", "Accept" and the adjustment button open the coming-soon page until VAN-43 ships.
- **Header.** `ChatCounterpartAppBar` replaces the plain title: avatar with initials, name, role and vehicle, and an info button wired to `openDriverProfile` on the client side.
- **Core extensions (R10b).** `VanepAppBar` gains `titleContent` for the composed header; `VanepPrimaryButton` and `VanepSecondaryButton` gain `compact` (44 px, 14 px label) so "See proposal" and "Accept" fit side by side in a 290 px card, as in the design.

### PR plan

Single PR by developer decision (as in VAN-41 and VAN-42), branch `feat/44-negotiation-chat` stacked on `feat/42-client-proposals` (#115). Layer order inside the PR follows R24.

| PR | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Core formatter move, domain, data (empty + scenario), cubit, header, banner, timeline cards, l10n, tests | VAN-42 (#115) | — |
| 2 | Real API wiring | 1 + api-java #30 / #42 | — |

## Risks / Trade-offs

- [Mocked shape drifts from the API] → only the negotiation data sources change when the endpoint lands.
- [Stacked on #115] → rebase onto `main` after #115 merges.
- [Mocked events are relative to now] → real messages sent before the mocked times would interleave oddly in dev; production has no mocked events.
