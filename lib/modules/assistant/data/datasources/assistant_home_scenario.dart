// TODO(VAN-67): selects mocked data in MockedAssistantRouteDataSource; delete
// together with it once the real endpoints are wired.
enum AssistantHomeScenario {
  noVan,
  inviteReceived,
  beforeRoute,
  onRouteBoarding,
  accessPaused,
  onRouteDropOff;

  static AssistantHomeScenario? fromName(String name) {
    for (final scenario in values) {
      if (scenario.name == name.trim()) return scenario;
    }
    return null;
  }
}
