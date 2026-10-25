import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_negotiation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

class FindConversationNegotiation {
  const FindConversationNegotiation(this.repository);

  final ConversationNegotiationRepository repository;

  Future<Result<ConversationFailure, ConversationNegotiation>> call(
    String conversationToken,
  ) {
    return repository.findNegotiation(conversationToken);
  }
}
