import 'package:equatable/equatable.dart';

const conversationMessageMaxLength = 2000;

enum ConversationParticipant { client, driver }

abstract class ConversationMessage {
  String get token;

  String get body;

  ConversationParticipant get sender;

  DateTime get sentAt;
}

class ConversationMessagePage extends Equatable {
  const ConversationMessagePage({
    required this.messages,
    required this.hasMore,
  });

  final List<ConversationMessage> messages;

  final bool hasMore;

  @override
  List<Object?> get props => [messages, hasMore];
}
