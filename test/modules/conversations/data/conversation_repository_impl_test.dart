import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/data/repositories/conversation_repository_impl.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';

import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

DioException dioFailure(int? status) {
  final requestOptions = RequestOptions(path: '/api/conversations');
  return DioException(
    requestOptions: requestOptions,
    response: status == null
        ? null
        : Response<Object?>(requestOptions: requestOptions, statusCode: status),
  );
}

void main() {
  late MockConversationRemoteDataSource remote;
  late MockConversationRealtimeDataSource realtime;
  late ConversationRepositoryImpl repository;

  setUp(() {
    remote = MockConversationRemoteDataSource();
    realtime = MockConversationRealtimeDataSource();
    repository = ConversationRepositoryImpl(remote: remote, realtime: realtime);
  });

  test('a successful open is returned as Ok', () async {
    when(
      () => remote.openConversation('driver-1'),
    ).thenAnswer((_) async => testConversation);

    final result = await repository.openConversation('driver-1');

    expect(result.valueOrNull, testConversation);
  });

  final failuresByStatus = <int?, ConversationFailure>{
    null: const ConversationNetworkFailure(),
    400: const ConversationMessageRejectedFailure(),
    403: const ConversationForbiddenFailure(),
    404: const ConversationDriverUnavailableFailure(),
    500: const ConversationUnexpectedFailure(),
  };
  for (final entry in failuresByStatus.entries) {
    test('status ${entry.key} maps to ${entry.value.runtimeType}', () async {
      when(
        () =>
            remote.sendMessage(conversationToken: 'conversation-1', body: 'Oi'),
      ).thenThrow(dioFailure(entry.key));

      final result = await repository.sendMessage(
        conversationToken: 'conversation-1',
        body: 'Oi',
      );

      expect(result.errorOrNull, entry.value);
    });
  }

  test('a malformed payload maps to an unexpected failure', () async {
    when(
      remote.listMyConversations,
    ).thenThrow(const FormatException('bad'));

    final result = await repository.listMyConversations();

    expect(result.errorOrNull, const ConversationUnexpectedFailure());
  });

  test('watchConversation forwards the realtime events', () {
    final received = ConversationMessageReceived(testDriverMessage);
    when(
      () => realtime.watchConversation('conversation-1'),
    ).thenAnswer((_) => Stream.value(received));

    expect(
      repository.watchConversation('conversation-1'),
      emitsInOrder([received, emitsDone]),
    );
  });
}
