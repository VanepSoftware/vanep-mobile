import 'package:vanep_mobile/modules/conversations/data/datasources/conversation_negotiation_datasource.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

// TODO(VAN-44): no negotiation until the API serves quote requests, proposal
// versions and adjustment requests per conversation (api-java #30 / #42);
// replace with the remote data source then.
class EmptyConversationNegotiationDataSource
    implements ConversationNegotiationDataSource {
  const EmptyConversationNegotiationDataSource();

  @override
  Future<ConversationNegotiation> findNegotiation(
    String conversationToken,
  ) async => ConversationNegotiation.none;
}
