import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

abstract class ConversationNegotiationRepository {
  Future<Result<ConversationFailure, ConversationNegotiation>> findNegotiation(
    String conversationToken,
  );
}
