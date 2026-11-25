import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

Future<Conversation?> resolveConversationForClientVan(
  BuildContext context,
  ClientVan van,
) async {
  if (van.driver.token.isEmpty) return null;

  ConversationsInboxCubit? inboxCubit;
  try {
    inboxCubit = context.read<ConversationsInboxCubit>();
  } catch (_) {}

  if (inboxCubit == null) return null;

  if (inboxCubit.state.status != ConversationsInboxStatus.ready) {
    await inboxCubit.loadConversations();
  }

  final matched = _findMatchingConversation(
    inboxCubit.state.conversations,
    van.driver.token,
  );
  if (matched != null) return matched;

  await inboxCubit.loadConversations();
  return _findMatchingConversation(
    inboxCubit.state.conversations,
    van.driver.token,
  );
}

Future<void> openChatDirectlyForClientVan(
  BuildContext context,
  ClientVan van,
) async {
  final l10n = AppLocalizations.of(context)!;
  final conversation = await resolveConversationForClientVan(context, van);
  if (!context.mounted) return;
  if (conversation == null) {
    VanepFeedback.showInfo(context, l10n.clientVansNoConversationYet);
    return;
  }
  if (!getIt.isRegistered<ChatCubit>()) return;

  final hasTimeline =
      getIt.isRegistered<NegotiationTimelineCubit<ClientServiceRequest>>();
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ChatCubit>(
            create: (_) => getIt<ChatCubit>(param1: conversation.token)..start(),
          ),
          if (hasTimeline)
            BlocProvider<NegotiationTimelineCubit<ClientServiceRequest>>(
              create: (_) =>
                  getIt<NegotiationTimelineCubit<ClientServiceRequest>>(
                    param1: conversation.token,
                  )..load(),
            ),
        ],
        child: ChatPage<ClientServiceRequest>(
          counterpartName: conversationCounterpartName(
            conversation,
            ConversationParticipant.client,
          ),
          viewerSide: ConversationParticipant.client,
        ),
      ),
    ),
  );
}

Conversation? _findMatchingConversation(
  List<Conversation> conversations,
  String driverToken,
) {
  for (final conv in conversations) {
    if (conv.driverToken == driverToken) {
      return conv;
    }
  }
  return null;
}
