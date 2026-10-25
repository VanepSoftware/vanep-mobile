## Why

The client already chats with a driver in real time (VAN-38), but the chat knows nothing about the negotiation behind it. The approved design (Genwork VAN-44 / Linear VAN-99, "Responsável → Propostas · 3. Negociação na conversa") puts the negotiation inside the conversation: the quote request, every proposal version, the adjustment requests and a banner with the current proposal, with the rule that only what is in the proposal counts. The API has no proposals yet (api-java #30 / #42), so the negotiation is built against a domain contract with a mocked data source, like the Home (VAN-41) and the Proposals list (VAN-42).

## What Changes

- New chat header: the driver's avatar, name and "Driver · <vehicle>" with an info button that opens the driver profile.
- Banner under the header with the current proposal ("Proposal v2 · R$ 300/mo · expires on 21/10", "See").
- The message list becomes a timeline: day dividers, text messages and negotiation cards in chronological order.
  - **Quote request** card (child and age, school and shift, days with one-way exceptions, start date, boarding place).
  - **Proposal** card per version: older versions faded with "Replaced"; the latest one "Current", with installments, due day, period, expiry and the actions "See proposal" and "Accept".
  - **Adjustment request** card (suggested fee and note).
  - Notices: "The driver only sees the neighborhood and the first name until acceptance" after the request, and "Agreements made in the chat only count if included in a new version of the proposal" after the current proposal.
- An adjustment button next to the message input while a proposal waits for the client.
- Text messages keep coming from the real API; the negotiation comes from `CONVERSATION_NEGOTIATION_SCENARIO` in dev and is empty otherwise.
- All copy through ARB localization (pt-BR and en).
- Not in scope: proposal detail (VAN-43), accepting a proposal and sending an adjustment request on the backend (they open the coming-soon page), the driver-side negotiation screens (VAN-58 to VAN-60).

## Capabilities

### New Capabilities
- `client-negotiation-chat`: the negotiation timeline inside the client–driver chat, the current-proposal banner and the adjustment entry point.

### Modified Capabilities

## Impact

- Code: `lib/modules/conversations/` (domain, data, cubit, page and widgets), `lib/app.dart` (driver profile from the chat), `lib/core/environment/environment.dart`, `.env.example`, `lib/l10n/*.arb`.
- `formatProposalWeekdays` and `formatProposalStartDate` move from `client_proposals` to `lib/core/formatters` so both modules share them (R02, R06a).
- Branch stacked on `feat/42-client-proposals` (#115), which brings `formatMoney`, `VanepPersonAvatar` and `SchoolShift` to `lib/core`.
- Backend dependency for the real wiring: proposals and quote requests (api-java #30 / #42).
