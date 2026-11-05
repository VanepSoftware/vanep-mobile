import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposal.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

final testProposalsNow = DateTime(2026, 10, 25, 10);

const testPedro = ProposalChild(
  token: 'child-pedro',
  name: 'Pedro',
  birthDate: '2015-03-22',
);

const testLucas = ProposalChild(
  token: 'child-lucas',
  name: 'Lucas',
  birthDate: '2020-01-10',
);

const testAna = ProposalChild(
  token: 'child-ana',
  name: 'Ana',
  birthDate: '2018-06-01',
);

final testJoaoPedroProposal = PendingProposal(
  token: 'proposal-joao-pedro',
  driver: const ProposalDriver(
    name: 'João Pedro Lima',
    vehicleModel: 'Master',
    vehicleYear: 2019,
    rating: 4.7,
    gender: Gender.male,
  ),
  childToken: testPedro.token,
  childName: testPedro.name,
  schoolName: 'Colégio Delta',
  shift: SchoolShift.afternoon,
  weekdays: weekdaysMondayToFriday,
  startsOn: DateTime(2027, 2),
  monthlyFeeCents: 30000,
  previousMonthlyFeeCents: 34000,
  expiresAt: testProposalsNow.add(const Duration(days: 6)),
);

final testRitaProposal = PendingProposal(
  token: 'proposal-rita',
  driver: const ProposalDriver(
    name: 'Rita Alves',
    vehicleModel: 'Ducato',
    vehicleYear: 2022,
    gender: Gender.female,
  ),
  childToken: testPedro.token,
  childName: testPedro.name,
  schoolName: 'Colégio Delta',
  shift: SchoolShift.afternoon,
  weekdays: const [DateTime.monday, DateTime.wednesday, DateTime.friday],
  startsOn: DateTime(2027, 2, 15),
  monthlyFeeCents: 32000,
  expiresAt: testProposalsNow.add(const Duration(days: 7)),
);

final testAnaProposal = PendingProposal(
  token: 'proposal-silvia',
  driver: const ProposalDriver(
    name: 'Sílvia Rocha',
    vehicleModel: 'Sprinter',
    vehicleYear: 2021,
    rating: 4.9,
  ),
  childToken: testAna.token,
  childName: testAna.name,
  schoolName: 'Escola Aurora',
  shift: SchoolShift.morning,
  weekdays: weekdaysMondayToFriday,
  startsOn: DateTime(2027, 2),
  monthlyFeeCents: 26000,
  expiresAt: testProposalsNow.add(const Duration(hours: 5)),
);

final testMarcosRequest = SentRequest(
  token: 'request-marcos',
  driverName: 'Marcos Teixeira',
  childToken: testPedro.token,
  childName: testPedro.name,
  sentAt: testProposalsNow.subtract(const Duration(days: 1)),
  answerBy: testProposalsNow.add(const Duration(hours: 52, minutes: 30)),
);

final testCarlosClosed = ClosedProposal(
  token: 'closed-carlos',
  driverName: 'Carlos Mendes',
  childToken: testPedro.token,
  childName: testPedro.name,
  monthlyFeeCents: 38000,
  outcome: ProposalOutcome.declined,
  closedAt: testProposalsNow.subtract(const Duration(days: 12)),
);

final testFernandaClosed = ClosedProposal(
  token: 'closed-fernanda',
  driverName: 'Fernanda Souza',
  childToken: testAna.token,
  childName: testAna.name,
  monthlyFeeCents: 29000,
  outcome: ProposalOutcome.expired,
  closedAt: testProposalsNow.subtract(const Duration(days: 20)),
);

final testProposalsFeed = ProposalsFeed(
  pending: [testJoaoPedroProposal, testRitaProposal],
  awaiting: [testMarcosRequest],
  closed: [testCarlosClosed, testFernandaClosed],
);

ClientProposals testClientProposals({
  List<ProposalChild> children = const [testPedro, testLucas, testAna],
  ProposalsFeed? feed,
}) {
  return ClientProposals(
    loadedAt: testProposalsNow,
    children: children,
    feed: feed ?? testProposalsFeed,
  );
}
