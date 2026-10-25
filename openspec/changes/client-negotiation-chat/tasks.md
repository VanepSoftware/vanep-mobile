## 1. Core (branch: feat/44-negotiation-chat — single PR by developer decision)

- [x] 1.1 Move `formatProposalWeekdays` and `formatProposalStartDate` (with `weekdaysMondayToFriday`) to `lib/core` as `formatWeekdays`, `formatDayMonth` and `formatStartingOn`, keeping the `client_proposals` callers and tests green
- [x] 1.2 Add `titleContent` to `VanepAppBar` and `compact` to `VanepPrimaryButton` / `VanepSecondaryButton`

## 2. Domain

- [x] 2.1 Write tests for `ConversationNegotiation` (current proposal, replaced versions, who may answer), `buildChatTimeline` (order, day dividers, notices) and `FindConversationNegotiation`
- [x] 2.2 Create `ConversationNegotiationRepository` contract
- [x] 2.3 Create value objects: `ConversationNegotiation`, sealed `NegotiationEvent` and `ChatTimelineEntry`
- [x] 2.4 Implement `FindConversationNegotiation` and `buildChatTimeline`

## 3. Data

- [x] 3.1 Write tests for the repository and both scenarios
- [x] 3.2 Implement the empty and scenario data sources and the repository
- [x] 3.3 Add `CONVERSATION_NEGOTIATION_SCENARIO` to `Environment` and `.env.example`; register them in `conversations_container.dart`

## 4. Cubit

- [x] 4.1 Write `bloc_test` cases: negotiation loaded with the messages, negotiation failure keeps the chat ready
- [x] 4.2 Extend `ChatState` and `ChatCubit`

## 5. Page

- [x] 5.1 Write widget tests: header with vehicle and info, banner, cards and notices, replaced vs current proposal, actions only for the recipient, adjustment button, chat without negotiation unchanged
- [x] 5.2 Add localization keys (pt-BR and en)
- [x] 5.3 Implement `ChatCounterpartAppBar`, `CurrentProposalBanner`, the negotiation cards, the timeline notices and the adjustment button
- [x] 5.4 Wire the driver profile from the chat header in `app.dart`
- [x] 5.5 Run `make lint` and `make test`
- [x] 5.6 Run on the iPhone 17 simulator (iOS 26.5) against the local API with `CONVERSATION_NEGOTIATION_SCENARIO=negotiating`
- [ ] 5.7 Developer verification on device before merge (R27a)

## 6. Later

- [ ] 6.1 Real API wiring when api-java #30 / #42 land
- [ ] 6.2 Open the proposal detail (VAN-43) from the banner and the cards; accept and adjustment flows
