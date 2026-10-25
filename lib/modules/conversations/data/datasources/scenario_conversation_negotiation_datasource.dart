import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_negotiation_scenario.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

DateTime daysBeforeAt(DateTime now, int days, int hour, [int minute = 0]) =>
    DateTime(now.year, now.month, now.day - days, hour, minute);

// TODO(VAN-44): mocked negotiation for development only. The same request,
// proposals and adjustment are returned for every conversation; replace with
// the remote data source when api-java #30 / #42 serve the negotiation, and
// delete this class, ConversationNegotiationScenario and
// CONVERSATION_NEGOTIATION_SCENARIO.
class ScenarioConversationNegotiationDataSource
    implements ConversationNegotiationDataSource {
  const ScenarioConversationNegotiationDataSource({
    required this.scenario,
    this.clock = DateTime.now,
  });

  final ConversationNegotiationScenario scenario;

  final DateTime Function() clock;

  @override
  Future<ConversationNegotiation> findNegotiation(
    String conversationToken,
  ) async {
    final now = clock();
    return switch (scenario) {
      ConversationNegotiationScenario.negotiating => negotiatingWith(now),
      ConversationNegotiationScenario.requestSent => ConversationNegotiation(
        events: [quoteRequestAt(daysBeforeAt(now, 1, 20, 14), now)],
      ),
    };
  }

  ConversationNegotiation negotiatingWith(DateTime now) {
    return ConversationNegotiation(
      events: [
        quoteRequestAt(daysBeforeAt(now, 4, 20, 14), now),
        proposalAt(daysBeforeAt(now, 3, 10, 30), now, version: 1, fee: 34000),
        AdjustmentRequestEvent(
          token: 'scenario-adjustment-1',
          author: ConversationParticipant.client,
          occurredAt: daysBeforeAt(now, 2, 9, 40),
          suggestedMonthlyFeeCents: 29000,
          note: 'Tem como melhorar o valor? São 4 voltas por semana.',
        ),
        proposalAt(daysBeforeAt(now, 1, 11), now, version: 2, fee: 30000),
      ],
    );
  }

  QuoteRequestEvent quoteRequestAt(DateTime sentAt, DateTime now) {
    return QuoteRequestEvent(
      token: 'scenario-request-1',
      author: ConversationParticipant.client,
      occurredAt: sentAt,
      childName: 'Pedro',
      childAge: 11,
      schoolName: 'Colégio Delta',
      shift: SchoolShift.afternoon,
      weekdays: weekdaysMondayToFriday,
      oneWayWeekdays: const [DateTime.wednesday],
      startsOn: DateTime(now.year + 1, 2),
      boardingPlace: 'QNL 5, Taguatinga',
    );
  }

  ProposalVersionEvent proposalAt(
    DateTime sentAt,
    DateTime now, {
    required int version,
    required int fee,
  }) {
    return ProposalVersionEvent(
      token: 'scenario-proposal-$version',
      author: ConversationParticipant.driver,
      occurredAt: sentAt,
      version: version,
      monthlyFeeCents: fee,
      installments: 12,
      dueDay: 10,
      startsOn: DateTime(now.year + 1, 2),
      endsOn: DateTime(now.year + 1, 12, 17),
      expiresAt: DateTime(sentAt.year, sentAt.month, sentAt.day + 8),
      vehicleModel: 'Master',
      vehicleYear: 2019,
    );
  }
}
