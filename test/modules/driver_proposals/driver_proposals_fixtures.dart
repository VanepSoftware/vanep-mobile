import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

const testPedroLine = ProposalStudentLine(
  token: 'pedro',
  name: 'Pedro Silva',
  schoolName: 'Colégio Delta',
  monthlyAmountCents: 35000,
);

const testAnaLine = ProposalStudentLine(
  token: 'ana',
  name: 'Ana Silva',
  schoolName: 'Escola Horizonte',
  monthlyAmountCents: 28000,
);

const testProposalConditions = ProposalConditions(
  dueDay: 10,
  notes: 'Pagamento até o vencimento. Falta avisada não é descontada.',
);

const testProposalSchedule = [
  ProposalScheduleSlot(
    weekday: DateTime.monday,
    leg: RouteLeg.outbound,
    minutesFromMidnight: 6 * 60 + 40,
  ),
  ProposalScheduleSlot(
    weekday: DateTime.monday,
    leg: RouteLeg.inbound,
    minutesFromMidnight: 12 * 60 + 10,
  ),
  ProposalScheduleSlot(
    weekday: DateTime.tuesday,
    leg: RouteLeg.outbound,
    minutesFromMidnight: 6 * 60 + 40,
  ),
];

ProposalComposeDraft testProposalComposeDraft({
  ProposalComposeBlock block = ProposalComposeBlock.none,
  int pedroCents = 35000,
  int anaCents = 28000,
  int commissionCents = 500,
}) {
  return ProposalComposeDraft(
    familyName: 'Família Silva',
    students: [
      testPedroLine.withAmount(pedroCents),
      testAnaLine.withAmount(anaCents),
    ],
    schedule: testProposalSchedule,
    conditions: testProposalConditions,
    commissionCents: commissionCents,
    block: block,
  );
}
