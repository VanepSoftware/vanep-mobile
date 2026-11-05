import 'package:intl/intl.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';

String conversationFailureLabel(
  AppLocalizations l10n,
  ConversationFailure failure,
) {
  return switch (failure) {
    ConversationNetworkFailure() => l10n.conversationFailureNetwork,
    ConversationDriverUnavailableFailure() =>
      l10n.conversationFailureDriverUnavailable,
    ConversationMessageRejectedFailure() => l10n.conversationFailureRejected,
    ConversationForbiddenFailure() => l10n.conversationFailureForbidden,
    ConversationUnexpectedFailure() => l10n.conversationFailureUnexpected,
  };
}

String conversationCounterpartName(
  Conversation conversation,
  ConversationParticipant viewerSide,
) {
  return switch (viewerSide) {
    ConversationParticipant.client => conversation.driverName,
    ConversationParticipant.driver => conversation.clientName,
  };
}

String conversationsInboxEmptyLabel(
  AppLocalizations l10n,
  ConversationParticipant viewerSide,
) {
  return switch (viewerSide) {
    ConversationParticipant.client => l10n.conversationsInboxEmptyClient,
    ConversationParticipant.driver => l10n.conversationsInboxEmpty,
  };
}

bool isSentByViewer(
  ConversationMessage message,
  ConversationParticipant viewerSide,
) => message.sender == viewerSide;

String formatConversationTime(DateTime moment) =>
    DateFormat.Hm().format(moment.toLocal());

String formatConversationListTime(DateTime moment, {DateTime? now}) {
  final local = moment.toLocal();
  final today = (now ?? DateTime.now()).toLocal();
  final isToday =
      local.year == today.year &&
      local.month == today.month &&
      local.day == today.day;
  return isToday
      ? DateFormat.Hm().format(local)
      : DateFormat('dd/MM').format(local);
}
