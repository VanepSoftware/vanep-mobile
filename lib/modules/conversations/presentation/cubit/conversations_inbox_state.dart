import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';

enum ConversationsInboxStatus { initial, loading, ready, loadFailed }

class ConversationsInboxState extends Equatable {
  const ConversationsInboxState({
    this.status = ConversationsInboxStatus.initial,
    this.conversations = const [],
    this.failure,
  });

  final ConversationsInboxStatus status;

  final List<Conversation> conversations;

  final ConversationFailure? failure;

  bool get isLoading =>
      status == ConversationsInboxStatus.initial ||
      status == ConversationsInboxStatus.loading;

  bool get hasLoadFailed => status == ConversationsInboxStatus.loadFailed;

  bool get isEmpty =>
      status == ConversationsInboxStatus.ready && conversations.isEmpty;

  @override
  List<Object?> get props => [status, conversations, failure];
}
