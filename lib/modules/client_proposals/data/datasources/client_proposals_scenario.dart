// TODO(VAN-42): selects mocked data in ScenarioClientProposalsDataSource;
// delete together with it and CLIENT_PROPOSALS_SCENARIO once api-java #30 is
// wired.
enum ClientProposalsScenario {
  openProposals,
  singleChild,
  limitReached;

  static ClientProposalsScenario? fromName(String name) {
    for (final scenario in values) {
      if (scenario.name == name.trim()) return scenario;
    }
    return null;
  }
}
