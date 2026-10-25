import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/find_conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/chat_timeline.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

void main() {
  group('ConversationNegotiation', () {
    test('the latest version is the current proposal', () {
      expect(fullNegotiation.currentProposal, secondProposal);
      expect(fullNegotiation.isCurrentProposal(secondProposal), isTrue);
      expect(fullNegotiation.isCurrentProposal(firstProposal), isFalse);
    });

    test('without proposals there is no current one', () {
      expect(requestOnlyNegotiation.currentProposal, isNull);
      expect(ConversationNegotiation.none.isEmpty, isTrue);
    });

    test('only the side that received the proposal may answer it', () {
      expect(
        fullNegotiation.canAnswerCurrentProposal(
          ConversationParticipant.client,
        ),
        isTrue,
      );
      expect(
        fullNegotiation.canAnswerCurrentProposal(
          ConversationParticipant.driver,
        ),
        isFalse,
      );
      expect(
        requestOnlyNegotiation.canAnswerCurrentProposal(
          ConversationParticipant.client,
        ),
        isFalse,
      );
    });
  });

  group('buildChatTimeline', () {
    test('mixes messages and events by time with a divider per day', () {
      final driverHello = localMessage(
        'hello',
        ConversationParticipant.driver,
        DateTime(2026, 10, 10, 21, 2),
      );
      final driverOffer = localMessage(
        'offer',
        ConversationParticipant.driver,
        DateTime(2026, 10, 12, 13, 15),
      );

      final timeline = buildChatTimeline(
        messages: [driverOffer, driverHello],
        negotiation: fullNegotiation,
      );

      expect(timeline, [
        ChatDayDivider(DateTime(2026, 10, 10)),
        ChatNegotiationEntry(quoteRequest),
        const ChatPrivacyNotice(),
        ChatMessageEntry(driverHello),
        ChatDayDivider(DateTime(2026, 10, 11)),
        ChatNegotiationEntry(firstProposal),
        ChatDayDivider(DateTime(2026, 10, 12)),
        ChatNegotiationEntry(adjustmentRequest),
        ChatMessageEntry(driverOffer),
        ChatDayDivider(DateTime(2026, 10, 13)),
        ChatNegotiationEntry(secondProposal, isCurrentProposal: true),
        const ChatAgreementNotice(),
      ]);
    });

    test('without negotiation only messages and dividers are listed', () {
      final morning = localMessage(
        'morning',
        ConversationParticipant.client,
        DateTime(2026, 10, 12, 8),
      );
      final later = localMessage(
        'later',
        ConversationParticipant.driver,
        DateTime(2026, 10, 12, 9),
      );

      final timeline = buildChatTimeline(
        messages: [morning, later],
        negotiation: ConversationNegotiation.none,
      );

      expect(timeline, [
        ChatDayDivider(DateTime(2026, 10, 12)),
        ChatMessageEntry(morning),
        ChatMessageEntry(later),
      ]);
    });
  });

  group('FindConversationNegotiation', () {
    test('asks the repository for the conversation negotiation', () async {
      final repository = MockConversationNegotiationRepository();
      when(() => repository.findNegotiation('conversation-1'))
          .thenAnswer((_) async => Ok(fullNegotiation));

      final result = await FindConversationNegotiation(repository)
          .call('conversation-1');

      expect(result, isA<Ok<ConversationFailure, ConversationNegotiation>>());
      verify(() => repository.findNegotiation('conversation-1')).called(1);
    });
  });
}
