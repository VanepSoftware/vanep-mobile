import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_realtime_datasource.dart';
import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_remote_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';

ConversationFailure conversationFailureFrom(DioException exception) {
  return switch (exception.response?.statusCode) {
    null => const ConversationNetworkFailure(),
    400 => const ConversationMessageRejectedFailure(),
    403 => const ConversationForbiddenFailure(),
    404 => const ConversationDriverUnavailableFailure(),
    _ => const ConversationUnexpectedFailure(),
  };
}

Future<Result<ConversationFailure, T>> guardConversationCall<T>(
  Future<T> Function() call,
) async {
  try {
    return Ok(await call());
  } on DioException catch (exception) {
    return Err(conversationFailureFrom(exception));
  } on FormatException {
    return const Err(ConversationUnexpectedFailure());
  }
}

class ConversationRepositoryImpl implements ConversationRepository {
  const ConversationRepositoryImpl({
    required this.remote,
    required this.realtime,
  });

  final ConversationRemoteDataSource remote;
  final ConversationRealtimeDataSource realtime;

  @override
  Future<Result<ConversationFailure, Conversation>> openConversation(
    String driverToken,
  ) {
    return guardConversationCall(() => remote.openConversation(driverToken));
  }

  @override
  Future<Result<ConversationFailure, List<Conversation>>>
  listMyConversations() {
    return guardConversationCall(remote.listMyConversations);
  }

  @override
  Future<Result<ConversationFailure, ConversationMessagePage>> listMessages({
    required String conversationToken,
    required int page,
  }) {
    return guardConversationCall(
      () =>
          remote.listMessages(conversationToken: conversationToken, page: page),
    );
  }

  @override
  Future<Result<ConversationFailure, ConversationMessage>> sendMessage({
    required String conversationToken,
    required String body,
  }) {
    return guardConversationCall(
      () =>
          remote.sendMessage(conversationToken: conversationToken, body: body),
    );
  }

  @override
  Stream<ConversationRealtimeEvent> watchConversation(
    String conversationToken,
  ) {
    return realtime.watchConversation(conversationToken);
  }
}
