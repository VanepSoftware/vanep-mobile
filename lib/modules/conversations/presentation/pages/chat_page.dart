import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/chat_timeline.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/chat_counterpart_title.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/chat_timeline_notices.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_input_bar.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_message_bubble.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/current_proposal_banner.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/negotiation_cards.dart';

const olderMessagesTriggerExtent = 300.0;

class ChatPage extends StatelessWidget {
  const ChatPage({
    required this.viewerSide,
    this.onDriverProfileTapped,
    super.key,
  });

  final ConversationParticipant viewerSide;
  final void Function(String driverToken)? onDriverProfileTapped;

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
          backgroundColor: VanepColors.surface,
          appBar: conversation == null
              ? VanepAppBar(title: l10n.conversationTitle)
              : ChatCounterpartAppBar(
                  conversation: conversation,
                  state: state,
                  viewerSide: viewerSide,
                  onDriverProfileTapped: onDriverProfileTapped,
                ),
          body: ChatBody(state: state, viewerSide: viewerSide),
        );
      },
    );
  }
}

class ChatCounterpartAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ChatCounterpartAppBar({
    required this.conversation,
    required this.state,
    required this.viewerSide,
    this.onDriverProfileTapped,
    super.key,
  });

  final Conversation conversation;
  final ChatState state;
  final ConversationParticipant viewerSide;
  final void Function(String driverToken)? onDriverProfileTapped;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onDriverProfileTapped = this.onDriverProfileTapped;
    final showsDriverProfile =
        viewerSide == ConversationParticipant.client &&
        onDriverProfileTapped != null;

    return VanepAppBar(
      titleContent: ChatCounterpartTitle(
        name: conversationCounterpartName(conversation, viewerSide),
        role: formatCounterpartRole(l10n, viewerSide, state.negotiation),
      ),
      actions: [
        if (showsDriverProfile)
          IconButton(
            tooltip: l10n.conversationDriverProfileTooltip,
            onPressed: () => onDriverProfileTapped(conversation.driverToken),
            icon: const Icon(Icons.info_outline),
          ),
      ],
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
    final currentProposal = state.negotiation.currentProposal;
    return Column(
      children: [
        if (currentProposal != null)
          CurrentProposalBanner(
            proposal: currentProposal,
            onTap: () => openUnbuiltNegotiationAction(
              context,
              l10n.conversationNegotiationBannerTitle(currentProposal.version),
            ),
          ),
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
          onAdjustmentTapped:
              state.negotiation.canAnswerCurrentProposal(viewerSide)
              ? () => openUnbuiltNegotiationAction(
                  context,
                  l10n.conversationAdjustmentTooltip,
                )
              : null,
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
    final newestFirst = state.timeline.reversed.toList();
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
          final entry = newestFirst[index];
          return ChatTimelineEntryView(
            key: ValueKey(entry.key),
            entry: entry,
            viewerSide: viewerSide,
          );
        },
      ),
    );
  }
}

class ChatTimelineEntryView extends StatelessWidget {
  const ChatTimelineEntryView({
    required this.entry,
    required this.viewerSide,
    super.key,
  });

  final ChatTimelineEntry entry;
  final ConversationParticipant viewerSide;

  @override
  Widget build(BuildContext context) {
    final entry = this.entry;
    return switch (entry) {
      ChatDayDivider(:final day) => ChatDayChip(day: day),
      ChatMessageEntry(:final message) => ConversationMessageBubble(
        message: message,
        sentByViewer: isSentByViewer(message, viewerSide),
      ),
      ChatNegotiationEntry() => NegotiationEventCard(
        entry: entry,
        viewerSide: viewerSide,
      ),
      ChatPrivacyNotice() => const ChatPrivacyNoticeText(),
      ChatAgreementNotice() => const ChatAgreementNoticeBox(),
    };
  }
}
