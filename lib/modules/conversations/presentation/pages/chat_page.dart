import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_input_bar.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_message_bubble.dart';

const olderMessagesTriggerExtent = 300.0;

class ChatPage extends StatelessWidget {
  const ChatPage({required this.viewerSide, super.key});

  final ConversationParticipant viewerSide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          current.isReady &&
          current.failure != null &&
          previous.failure != current.failure,
      listener: (context, state) => VanepFeedback.showError(
        context,
        conversationFailureLabel(l10n, state.failure!),
      ),
      builder: (context, state) {
        final conversation = state.conversation;
        return Scaffold(
          backgroundColor: VanepColors.card,
          appBar: VanepAppBar(
            title: conversation == null
                ? l10n.conversationTitle
                : conversationCounterpartName(conversation, viewerSide),
          ),
          body: ChatBody(state: state, viewerSide: viewerSide),
        );
      },
    );
  }
}

class ChatBody extends StatelessWidget {
  const ChatBody({required this.state, required this.viewerSide, super.key});

  final ChatState state;
  final ConversationParticipant viewerSide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ChatCubit>();

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: VanepColors.action),
      );
    }
    if (state.hasLoadFailed) {
      final failure = state.failure;
      return VanepErrorView(
        message: failure == null
            ? l10n.conversationLoadError
            : conversationFailureLabel(l10n, failure),
        retryLabel: l10n.conversationRetry,
        onRetry: cubit.start,
      );
    }
    return Column(
      children: [
        Expanded(
          child: state.isEmpty
              ? Center(
                  child: Text(
                    l10n.conversationEmpty,
                    style: VanepTypography.cardSubtitle,
                  ),
                )
              : ChatMessageList(state: state, viewerSide: viewerSide),
        ),
        ConversationInputBar(
          isSending: state.isSending,
          onSend: cubit.sendMessage,
        ),
      ],
    );
  }
}

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    required this.state,
    required this.viewerSide,
    super.key,
  });

  final ChatState state;
  final ConversationParticipant viewerSide;

  @override
  Widget build(BuildContext context) {
    final newestFirst = state.messages.reversed.toList();
    final cubit = context.read<ChatCubit>();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < olderMessagesTriggerExtent) {
          cubit.loadOlderMessages();
        }
        return false;
      },
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: newestFirst.length + (state.isLoadingOlder ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == newestFirst.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: CircularProgressIndicator(color: VanepColors.action),
              ),
            );
          }
          final message = newestFirst[index];
          return ConversationMessageBubble(
            key: ValueKey(message.token),
            message: message,
            sentByViewer: isSentByViewer(message, viewerSide),
          );
        },
      ),
    );
  }
}
