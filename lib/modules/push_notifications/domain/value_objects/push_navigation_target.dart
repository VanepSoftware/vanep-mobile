import 'package:equatable/equatable.dart';

sealed class PushNavigationTarget extends Equatable {
  const PushNavigationTarget();

  @override
  List<Object?> get props => [];
}

final class ChatPushTarget extends PushNavigationTarget {
  const ChatPushTarget({
    required this.conversationToken,
    required this.counterpartName,
  });

  final String conversationToken;

  final String counterpartName;

  @override
  List<Object?> get props => [conversationToken, counterpartName];
}

final class ProposalPushTarget extends PushNavigationTarget {
  const ProposalPushTarget();
}

final class ContractPushTarget extends PushNavigationTarget {
  const ContractPushTarget();
}

const pushTypeKey = 'type';

const pushConversationTokenKey = 'conversationToken';

const pushCounterpartNameKey = 'counterpartName';

const chatPushTypes = {'chat'};

const proposalPushTypes = {'proposal', 'proposta'};

const contractPushTypes = {'contract', 'contrato'};

PushNavigationTarget? pushNavigationTargetFrom(Map<String, Object?> data) {
  final type = readPushString(data, pushTypeKey).toLowerCase();
  if (chatPushTypes.contains(type)) return chatPushTargetFrom(data);
  if (proposalPushTypes.contains(type)) return const ProposalPushTarget();
  if (contractPushTypes.contains(type)) return const ContractPushTarget();
  return null;
}

ChatPushTarget? chatPushTargetFrom(Map<String, Object?> data) {
  final conversationToken = readPushString(data, pushConversationTokenKey);
  if (conversationToken.isEmpty) return null;
  return ChatPushTarget(
    conversationToken: conversationToken,
    counterpartName: readPushString(data, pushCounterpartNameKey),
  );
}

String readPushString(Map<String, Object?> data, String key) {
  final value = data[key];
  return value is String ? value.trim() : '';
}
