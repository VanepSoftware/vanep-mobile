import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/client_proposals_scenario.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/proposal_children_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/proposals_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposal.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

DateTime nextFirstOfFebruary(DateTime now) {
  final year = now.month >= DateTime.february ? now.year + 1 : now.year;
  return DateTime(year, DateTime.february);
}

String birthDateForAge(DateTime now, int years) {
  return formatIsoCalendarDate(DateTime(now.year - years, 1, 15));
}

// TODO(VAN-42): mocked data for development only. Every child, proposal and
// request below is fake; replace with the remote proposals data source
// (api-java #30) and DependentProposalChildrenDataSource, then delete this
// class, ClientProposalsScenario and CLIENT_PROPOSALS_SCENARIO.
class ScenarioClientProposalsDataSource
    implements ProposalsDataSource, ProposalChildrenDataSource {
  const ScenarioClientProposalsDataSource({
    required this.scenario,
    this.clock = DateTime.now,
  });

  final ClientProposalsScenario scenario;

  final DateTime Function() clock;

  @override
  Future<List<ProposalChild>> findChildren() async {
    final now = clock();
    final pedro = ProposalChild(
      token: 'child-pedro',
      name: 'Pedro',
      birthDate: birthDateForAge(now, 11),
    );
    if (scenario == ClientProposalsScenario.singleChild) return [pedro];
    return [
      pedro,
      ProposalChild(
        token: 'child-lucas',
        name: 'Lucas',
        birthDate: birthDateForAge(now, 6),
      ),
      ProposalChild(
        token: 'child-ana',
        name: 'Ana',
        birthDate: birthDateForAge(now, 8),
      ),
      ProposalChild(
        token: 'child-bia',
        name: 'Bia',
        birthDate: birthDateForAge(now, 13),
      ),
      ProposalChild(
        token: 'child-davi',
        name: 'Davi',
        birthDate: birthDateForAge(now, 4),
      ),
    ];
  }

  @override
  Future<ProposalsFeed> findProposals() async {
    final now = clock();
    return switch (scenario) {
      ClientProposalsScenario.openProposals => openProposalsFeed(now),
      ClientProposalsScenario.singleChild => singleChildFeed(now),
      ClientProposalsScenario.limitReached => limitReachedFeed(now),
    };
  }

  ProposalsFeed openProposalsFeed(DateTime now) {
    return ProposalsFeed(
      pending: [joaoPedroProposal(now), ritaProposal(now)],
      awaiting: [marcosRequest(now)],
      closed: [
        ClosedProposal(
          token: 'closed-carlos',
          driverName: 'Carlos Mendes',
          childToken: 'child-pedro',
          childName: 'Pedro',
          monthlyFeeCents: 38000,
          outcome: ProposalOutcome.declined,
          closedAt: now.subtract(const Duration(days: 12)),
        ),
        ClosedProposal(
          token: 'closed-fernanda',
          driverName: 'Fernanda Souza',
          childToken: 'child-ana',
          childName: 'Ana',
          monthlyFeeCents: 29000,
          outcome: ProposalOutcome.expired,
          closedAt: now.subtract(const Duration(days: 20)),
        ),
      ],
    );
  }

  ProposalsFeed singleChildFeed(DateTime now) {
    return ProposalsFeed(
      pending: [joaoPedroProposal(now)],
      closed: [
        ClosedProposal(
          token: 'closed-marcos',
          driverName: 'Marcos Teixeira',
          childToken: 'child-pedro',
          childName: 'Pedro',
          monthlyFeeCents: 31000,
          outcome: ProposalOutcome.cancelled,
          closedAt: now.subtract(const Duration(days: 3)),
        ),
      ],
    );
  }

  ProposalsFeed limitReachedFeed(DateTime now) {
    return ProposalsFeed(
      pending: [
        joaoPedroProposal(now),
        ritaProposal(now),
        PendingProposal(
          token: 'proposal-silvia',
          driver: const ProposalDriver(
            name: 'Sílvia Rocha',
            vehicleModel: 'Sprinter',
            vehicleYear: 2021,
            rating: 4.9,
            gender: Gender.female,
          ),
          childToken: 'child-ana',
          childName: 'Ana',
          schoolName: 'Escola Aurora',
          shift: SchoolShift.morning,
          weekdays: const [
            DateTime.monday,
            DateTime.wednesday,
            DateTime.friday,
          ],
          startsOn: nextFirstOfFebruary(now),
          monthlyFeeCents: 26000,
          expiresAt: now.add(const Duration(days: 1)),
        ),
      ],
      awaiting: [
        marcosRequest(now),
        SentRequest(
          token: 'request-paulo',
          driverName: 'Paulo Nunes',
          childToken: 'child-lucas',
          childName: 'Lucas',
          sentAt: now.subtract(const Duration(hours: 3)),
          answerBy: now.add(const Duration(hours: 69)),
        ),
      ],
    );
  }

  PendingProposal joaoPedroProposal(DateTime now) {
    return PendingProposal(
      token: 'proposal-joao-pedro',
      driver: const ProposalDriver(
        name: 'João Pedro Lima',
        vehicleModel: 'Master',
        vehicleYear: 2019,
        rating: 4.7,
        gender: Gender.male,
      ),
      childToken: 'child-pedro',
      childName: 'Pedro',
      schoolName: 'Colégio Delta',
      shift: SchoolShift.afternoon,
      weekdays: weekdaysMondayToFriday,
      startsOn: nextFirstOfFebruary(now),
      monthlyFeeCents: 30000,
      previousMonthlyFeeCents: 34000,
      expiresAt: now.add(const Duration(days: 6)),
    );
  }

  PendingProposal ritaProposal(DateTime now) {
    return PendingProposal(
      token: 'proposal-rita',
      driver: const ProposalDriver(
        name: 'Rita Alves',
        vehicleModel: 'Ducato',
        vehicleYear: 2022,
        gender: Gender.female,
      ),
      childToken: 'child-pedro',
      childName: 'Pedro',
      schoolName: 'Colégio Delta',
      shift: SchoolShift.afternoon,
      weekdays: weekdaysMondayToFriday,
      startsOn: nextFirstOfFebruary(now),
      monthlyFeeCents: 32000,
      expiresAt: now.add(const Duration(days: 7)),
    );
  }

  SentRequest marcosRequest(DateTime now) {
    return SentRequest(
      token: 'request-marcos',
      driverName: 'Marcos Teixeira',
      childToken: 'child-pedro',
      childName: 'Pedro',
      sentAt: now.subtract(const Duration(days: 1)),
      answerBy: now.add(const Duration(hours: 52, minutes: 30)),
    );
  }
}
