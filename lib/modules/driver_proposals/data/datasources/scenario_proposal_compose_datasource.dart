import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

class ProposalComposeUnavailable implements Exception {
  const ProposalComposeUnavailable({this.isNetwork = false});

  final bool isNetwork;
}

abstract class ProposalComposeDataSource {
  Future<ProposalComposeDraft> loadCompose();

  Future<void> send(ProposalComposeDraft draft);
}

enum DriverProposalScenario { overdueInvoice, notAcceptingStudents, loadFailed }

DriverProposalScenario? driverProposalScenarioFromName(String name) {
  return switch (name) {
    'overdueInvoice' => DriverProposalScenario.overdueInvoice,
    'notAcceptingStudents' => DriverProposalScenario.notAcceptingStudents,
    'loadFailed' => DriverProposalScenario.loadFailed,
    _ => null,
  };
}

ProposalComposeBlock proposalComposeBlockFor(DriverProposalScenario? scenario) {
  return switch (scenario) {
    DriverProposalScenario.overdueInvoice =>
      ProposalComposeBlock.overdueInvoice,
    DriverProposalScenario.notAcceptingStudents =>
      ProposalComposeBlock.notAcceptingStudents,
    _ => ProposalComposeBlock.none,
  };
}

List<ProposalScheduleSlot> sampleProposalSchedule() {
  const outbound = 6 * 60 + 40;
  const inbound = 12 * 60 + 10;
  return [
    for (final weekday in schoolWeekdays) ...[
      ProposalScheduleSlot(
        weekday: weekday,
        leg: RouteLeg.outbound,
        minutesFromMidnight: outbound,
      ),
      ProposalScheduleSlot(
        weekday: weekday,
        leg: RouteLeg.inbound,
        minutesFromMidnight: inbound,
      ),
    ],
  ];
}

// TODO(VAN-XX): mocked proposal the driver assembles. No proposal endpoint
// exists yet (api-java exposes contracts only). Remove sampleProposalComposeDraft,
// ScenarioProposalComposeDataSource and DRIVER_PROPOSAL_SCENARIO together
// when that endpoint lands.
ProposalComposeDraft sampleProposalComposeDraft({
  ProposalComposeBlock block = ProposalComposeBlock.none,
}) {
  return ProposalComposeDraft(
    familyName: 'Família Silva',
    students: const [
      ProposalStudentLine(
        token: 'pedro',
        name: 'Pedro Silva',
        schoolName: 'Colégio Delta',
        monthlyAmountCents: 35000,
      ),
      ProposalStudentLine(
        token: 'ana',
        name: 'Ana Silva',
        schoolName: 'Escola Horizonte',
        monthlyAmountCents: 28000,
      ),
    ],
    schedule: sampleProposalSchedule(),
    conditions: const ProposalConditions(
      dueDay: 10,
      notes: 'Pagamento até o vencimento. Falta avisada não é descontada.',
    ),
    commissionCents: 500,
    block: block,
  );
}

class ScenarioProposalComposeDataSource implements ProposalComposeDataSource {
  const ScenarioProposalComposeDataSource({this.scenario});

  final DriverProposalScenario? scenario;

  @override
  Future<ProposalComposeDraft> loadCompose() async {
    if (scenario == DriverProposalScenario.loadFailed) {
      throw const ProposalComposeUnavailable();
    }
    return sampleProposalComposeDraft(block: proposalComposeBlockFor(scenario));
  }

  @override
  Future<void> send(ProposalComposeDraft draft) async {}
}
