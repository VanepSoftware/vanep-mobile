import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';

enum DriverConversationsStatus { initial, loading, ready, loadFailed }

class DriverConversationsState extends Equatable {
  const DriverConversationsState({
    this.status = DriverConversationsStatus.initial,
    this.conversations = const [],
    this.failure,
  });

  final DriverConversationsStatus status;

  final List<Conversation> conversations;

  final ConversationFailure? failure;

  bool get isLoading =>
      status == DriverConversationsStatus.initial ||
      status == DriverConversationsStatus.loading;

  bool get hasLoadFailed => status == DriverConversationsStatus.loadFailed;

  bool get isEmpty =>
      status == DriverConversationsStatus.ready && conversations.isEmpty;

  @override
  List<Object?> get props => [status, conversations, failure];
}
