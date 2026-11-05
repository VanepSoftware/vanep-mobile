import 'package:vanep_mobile/modules/conversations/domain/repositories/conversation_repository.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';

class WatchConversation {
  const WatchConversation(this.repository);

  final ConversationRepository repository;

  Stream<ConversationRealtimeEvent> call(String conversationToken) {
    return repository.watchConversation(conversationToken);
  }
}
