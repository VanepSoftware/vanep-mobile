// TODO(VAN-41): selects mocked data in ScenarioDailyOverviewDataSource; delete
// together with it once the real endpoints are wired.
enum ClientHomeScenario {
  firstAccess,
  negotiating,
  everythingAtOnce,
  beforeRoute,
  vanArriving,
  arrivedAtSchool,
  noRouteToday;

  static ClientHomeScenario? fromName(String name) {
    for (final scenario in values) {
      if (scenario.name == name.trim()) return scenario;
    }
    return null;
  }
}
