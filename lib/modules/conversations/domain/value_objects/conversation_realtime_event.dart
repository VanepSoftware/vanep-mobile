import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';

sealed class ConversationRealtimeEvent extends Equatable {
  const ConversationRealtimeEvent();

  @override
  List<Object?> get props => const [];
}

final class ConversationMessageReceived extends ConversationRealtimeEvent {
  const ConversationMessageReceived(this.message);

  final ConversationMessage message;

  @override
  List<Object?> get props => [message];
}

final class ConversationRealtimeReconnected extends ConversationRealtimeEvent {
  const ConversationRealtimeReconnected();
}
