import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';

class ListDriverConversations {
  const ListDriverConversations(this.repository);

  final ConversationRepository repository;

  Future<Result<ConversationFailure, List<Conversation>>> call() {
    return repository.listDriverConversations();
  }
}
