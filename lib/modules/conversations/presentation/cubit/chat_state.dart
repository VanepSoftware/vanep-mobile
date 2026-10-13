import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';

enum ChatStatus { initial, loading, ready, loadFailed }

List<ConversationMessage> mergeConversationMessages(
  List<ConversationMessage> current,
  Iterable<ConversationMessage> incoming,
) {
  final messagesByToken = {
    for (final message in current) message.token: message,
    for (final message in incoming) message.token: message,
  };
  return messagesByToken.values.toList()..sort(compareBySentAt);
}

int compareBySentAt(ConversationMessage first, ConversationMessage second) {
  final bySentAt = first.sentAt.compareTo(second.sentAt);
  return bySentAt != 0 ? bySentAt : first.token.compareTo(second.token);
}

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.conversation,
    this.messages = const [],
    this.hasMore = false,
    this.nextPage = 1,
    this.isLoadingOlder = false,
    this.isSending = false,
    this.failure,
  });

  final ChatStatus status;

  final Conversation? conversation;

  final List<ConversationMessage> messages;

  final bool hasMore;

  final int nextPage;

  final bool isLoadingOlder;

  final bool isSending;

  final ConversationFailure? failure;

  bool get isLoading =>
      status == ChatStatus.initial || status == ChatStatus.loading;

  bool get hasLoadFailed => status == ChatStatus.loadFailed;

  bool get isReady => status == ChatStatus.ready;

  bool get isEmpty => isReady && messages.isEmpty;

  ChatState copyWith({
    ChatStatus? status,
    Conversation? conversation,
    List<ConversationMessage>? messages,
    bool? hasMore,
    int? nextPage,
    bool? isLoadingOlder,
    bool? isSending,
    ConversationFailure? failure,
    bool clearFailure = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isSending: isSending ?? this.isSending,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversation,
    messages,
    hasMore,
    nextPage,
    isLoadingOlder,
    isSending,
    failure,
  ];
}
