import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';

abstract class ConversationRepository {
  Future<Result<ConversationFailure, Conversation>> openConversation(
    String driverToken,
  );

  Future<Result<ConversationFailure, List<Conversation>>>
  listDriverConversations();

  Future<Result<ConversationFailure, ConversationMessagePage>> listMessages({
    required String conversationToken,
    required int page,
  });

  Future<Result<ConversationFailure, ConversationMessage>> sendMessage({
    required String conversationToken,
    required String body,
  });

  Stream<ConversationRealtimeEvent> watchConversation(String conversationToken);
}
