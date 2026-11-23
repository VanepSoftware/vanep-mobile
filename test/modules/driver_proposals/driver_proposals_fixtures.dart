import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_schedule.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';

const testTheoLine = ProposalStudentLine(
  token: 'theo',
  name: 'Theo',
  monthlyAmountCents: 32000,
);

const testAliceLine = ProposalStudentLine(
  token: 'alice',
  name: 'Alice',
  monthlyAmountCents: 30000,
);

const testSprinter = ProposalVanOption(
  token: 'sprinter',
  model: 'Sprinter',
  plate: 'SDF4E21',
  capacity: 16,
  freeSeats: 4,
);

const testMaster = ProposalVanOption(
  token: 'master',
  model: 'Master',
  plate: 'RTA2B19',
  capacity: 15,
  freeSeats: 1,
);

const testRouteTimes = ProposalRouteTimes(
  pickupStartMinutes: 12 * 60 + 5,
  pickupEndMinutes: 12 * 60 + 15,
  schoolArrivalMinutes: 12 * 60 + 50,
  schoolDepartureMinutes: 18 * 60,
  stopWaitMinutes: 5,
);

final testPayment = ProposalPayment(
  installments: 12,
  dueDay: 10,
  startDate: DateTime(2027, 2),
  endDate: DateTime(2027, 12, 17),
);

const testConditions = ProposalConditions(
  reservationFee: ProposalReservationFee.oneInstallmentDeducted,
  readjustment: ProposalReadjustment.ipcaOnRenewal,
  cancellationNoticeDays: 30,
  cancellationPenaltyPercent: 10,
);

const testFridayReturn = ProposalScheduleSlot(
  weekday: DateTime.friday,
  leg: RouteLeg.inbound,
);

ProposalComposeDraft testProposalComposeDraft({
  ProposalComposeBlock block = ProposalComposeBlock.none,
  int theoCents = 32000,
  int aliceCents = 30000,
  int commissionCents = 500,
  int installments = 12,
  String selectedVanToken = 'sprinter',
}) {
  return ProposalComposeDraft(
    familyName: 'Família Andrade',
    students: [
      testTheoLine.withAmount(theoCents),
      testAliceLine.withAmount(aliceCents),
    ],
    vans: const [testSprinter, testMaster],
    selectedVanToken: selectedVanToken,
    shift: SchoolShift.afternoon,
    requestedSlots: fullSchoolWeekSlots(),
    slots: fullSchoolWeekSlots(),
    times: testRouteTimes,
    payment: testPayment.copyWith(installments: installments),
    conditions: testConditions,
    commissionCents: commissionCents,
    validityDays: 7,
    block: block,
  );
}
