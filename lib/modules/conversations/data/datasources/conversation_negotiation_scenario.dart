// TODO(VAN-44): selects mocked data in
// ScenarioConversationNegotiationDataSource; delete together with it and
// CONVERSATION_NEGOTIATION_SCENARIO once the negotiation endpoint is wired.
enum ConversationNegotiationScenario {
  negotiating,
  requestSent;

  static ConversationNegotiationScenario? fromName(String name) {
    for (final scenario in values) {
      if (scenario.name == name.trim()) return scenario;
    }
    return null;
  }
}
