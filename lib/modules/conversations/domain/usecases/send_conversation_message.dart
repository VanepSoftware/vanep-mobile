import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';

bool isBlankConversationMessage(String body) => body.trim().isEmpty;

bool exceedsConversationMessageLength(String body) =>
    body.trim().length > conversationMessageMaxLength;

class SendConversationMessage {
  const SendConversationMessage(this.repository);

  final ConversationRepository repository;

  Future<Result<ConversationFailure, ConversationMessage>> call({
    required String conversationToken,
    required String body,
  }) async {
    if (isBlankConversationMessage(body) ||
        exceedsConversationMessageLength(body)) {
      return const Err(ConversationMessageRejectedFailure());
    }
    return repository.sendMessage(
      conversationToken: conversationToken,
      body: body.trim(),
    );
  }
}
