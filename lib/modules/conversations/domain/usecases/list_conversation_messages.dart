import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';

class ListConversationMessages {
  const ListConversationMessages(this.repository);

  final ConversationRepository repository;

  Future<Result<ConversationFailure, ConversationMessagePage>> call({
    required String conversationToken,
    required int page,
  }) {
    return repository.listMessages(
      conversationToken: conversationToken,
      page: page,
    );
  }
}
