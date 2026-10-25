import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/conversations_container.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_negotiation_scenario.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/empty_conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/scenario_conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/repositories/conversation_negotiation_repository_impl.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

ScenarioConversationNegotiationDataSource scenarioSource(
  ConversationNegotiationScenario scenario,
) {
  return ScenarioConversationNegotiationDataSource(
    scenario: scenario,
    clock: () => DateTime(2026, 10, 14, 19, 30),
  );
}

void main() {
  group('ConversationNegotiationRepositoryImpl', () {
    test('wraps the data source negotiation', () async {
      final dataSource = MockConversationNegotiationDataSource();
      when(() => dataSource.findNegotiation('conversation-1'))
          .thenAnswer((_) async => fullNegotiation);

      final result = await ConversationNegotiationRepositoryImpl(
        dataSource: dataSource,
      ).findNegotiation('conversation-1');

      expect(
        result,
        Ok<ConversationFailure, ConversationNegotiation>(fullNegotiation),
      );
    });

    test('maps a data source error to an unexpected failure', () async {
      final dataSource = MockConversationNegotiationDataSource();
      when(() => dataSource.findNegotiation('conversation-1'))
          .thenThrow(StateError('boom'));

      final result = await ConversationNegotiationRepositoryImpl(
        dataSource: dataSource,
      ).findNegotiation('conversation-1');

      expect(
        result,
        const Err<ConversationFailure, ConversationNegotiation>(
          ConversationUnexpectedFailure(),
        ),
      );
    });
  });

  test('the empty data source has no negotiation', () async {
    final negotiation = await const EmptyConversationNegotiationDataSource()
        .findNegotiation('conversation-1');

    expect(negotiation, ConversationNegotiation.none);
  });

  group('ScenarioConversationNegotiationDataSource', () {
    test(
      'negotiating has the request, two versions and an adjustment',
      () async {
        final negotiation = await scenarioSource(
          ConversationNegotiationScenario.negotiating,
        ).findNegotiation('conversation-1');

        expect(negotiation.events.whereType<QuoteRequestEvent>(), hasLength(1));
        expect(
          negotiation.events.whereType<AdjustmentRequestEvent>(),
          hasLength(1),
        );
        expect(negotiation.currentProposal?.version, 2);
        expect(negotiation.currentProposal?.monthlyFeeCents, 30000);
        expect(
          negotiation.canAnswerCurrentProposal(ConversationParticipant.client),
          isTrue,
        );
        expect(
          negotiation.events.every(
            (event) => event.occurredAt.isBefore(DateTime(2026, 10, 14)),
          ),
          isTrue,
        );
      },
    );

    test('request sent has only the quote request', () async {
      final negotiation = await scenarioSource(
        ConversationNegotiationScenario.requestSent,
      ).findNegotiation('conversation-1');

      expect(negotiation.events.single, isA<QuoteRequestEvent>());
      expect(negotiation.currentProposal, isNull);
    });
  });

  group('conversationNegotiationDataSourceFor', () {
    test('an unknown or empty name keeps the negotiation empty', () {
      expect(
        conversationNegotiationDataSourceFor(''),
        isA<EmptyConversationNegotiationDataSource>(),
      );
      expect(
        conversationNegotiationDataSourceFor('unknown'),
        isA<EmptyConversationNegotiationDataSource>(),
      );
    });

    test('a scenario name selects the mocked negotiation', () {
      final dataSource = conversationNegotiationDataSourceFor(' negotiating ');

      expect(dataSource, isA<ScenarioConversationNegotiationDataSource>());
      expect(
        (dataSource as ScenarioConversationNegotiationDataSource).scenario,
        ConversationNegotiationScenario.negotiating,
      );
    });
  });
}
