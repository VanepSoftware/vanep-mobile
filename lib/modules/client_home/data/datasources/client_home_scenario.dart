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
