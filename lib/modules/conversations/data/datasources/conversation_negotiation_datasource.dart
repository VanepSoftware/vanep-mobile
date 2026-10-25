import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

abstract class ConversationNegotiationDataSource {
  Future<ConversationNegotiation> findNegotiation(String conversationToken);
}
