import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_schedule.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';

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

// TODO(VAN-XX): mocked proposal the driver assembles. No proposal endpoint
// exists yet (api-java exposes contracts only). Remove sampleProposalComposeDraft,
// ScenarioProposalComposeDataSource and DRIVER_PROPOSAL_SCENARIO together
// when that endpoint lands.
ProposalComposeDraft sampleProposalComposeDraft({
  ProposalComposeBlock block = ProposalComposeBlock.none,
}) {
  return ProposalComposeDraft(
    familyName: 'Família Andrade',
    students: const [
      ProposalStudentLine(
        token: 'theo',
        name: 'Theo',
        monthlyAmountCents: 32000,
      ),
      ProposalStudentLine(
        token: 'alice',
        name: 'Alice',
        monthlyAmountCents: 30000,
      ),
    ],
    vans: const [
      ProposalVanOption(
        token: 'sprinter',
        model: 'Sprinter',
        plate: 'SDF4E21',
        capacity: 16,
        freeSeats: 4,
      ),
      ProposalVanOption(
        token: 'master',
        model: 'Master',
        plate: 'RTA2B19',
        capacity: 15,
        freeSeats: 1,
      ),
    ],
    selectedVanToken: 'sprinter',
    shift: SchoolShift.afternoon,
    requestedSlots: fullSchoolWeekSlots(),
    slots: fullSchoolWeekSlots(),
    times: const ProposalRouteTimes(
      pickupStartMinutes: 12 * 60 + 5,
      pickupEndMinutes: 12 * 60 + 15,
      schoolArrivalMinutes: 12 * 60 + 50,
      schoolDepartureMinutes: 18 * 60,
      stopWaitMinutes: 5,
    ),
    payment: ProposalPayment(
      installments: 12,
      dueDay: 10,
      startDate: DateTime(2027, 2),
      endDate: DateTime(2027, 12, 17),
    ),
    conditions: const ProposalConditions(
      reservationFee: ProposalReservationFee.oneInstallmentDeducted,
      readjustment: ProposalReadjustment.ipcaOnRenewal,
      cancellationNoticeDays: 30,
      cancellationPenaltyPercent: 10,
    ),
    commissionCents: 500,
    validityDays: 7,
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
