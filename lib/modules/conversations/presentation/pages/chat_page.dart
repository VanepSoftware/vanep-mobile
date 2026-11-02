import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/chat_timeline.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/negotiation_chat_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_input_bar.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_message_bubble.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/negotiation_chat_cards.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';

const olderMessagesTriggerExtent = 300.0;

class NegotiationChatActions<R extends ServiceRequest> {
  const NegotiationChatActions({
    required this.onSeeProposal,
    this.onAccept,
    this.onAskAdjustment,
    this.onNewVersion,
  });

  final Future<void> Function(R request) onSeeProposal;
  final Future<void> Function(R request, Proposal proposal)? onAccept;
  final Future<void> Function(R request, Proposal proposal)? onAskAdjustment;
  final Future<void> Function(R request, Proposal proposal)? onNewVersion;
}

Future<void> runNegotiationAction<R extends ServiceRequest>(
  BuildContext context,
  Future<void> Function() action,
) async {
  final timeline = context.read<NegotiationTimelineCubit<R>>();
  await action();
  await timeline.load();
}

class ChatPage<R extends ServiceRequest> extends StatelessWidget {
  const ChatPage({
    required this.counterpartName,
    required this.viewerSide,
    this.negotiationActions,
    this.clock = DateTime.now,
    super.key,
  });

  final String counterpartName;
  final ConversationParticipant viewerSide;
  final NegotiationChatActions<R>? negotiationActions;
  final DateTime Function() clock;

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
        final actions = negotiationActions;
        return Scaffold(
          backgroundColor: VanepColors.card,
          appBar: VanepAppBar(title: counterpartName),
          body: actions == null
              ? ChatBody<R>(
                  state: state,
                  viewerSide: viewerSide,
                  today: clock(),
                )
              : BlocBuilder<
                  NegotiationTimelineCubit<R>,
                  NegotiationTimelineState<R>
                >(
                  builder: (context, timeline) => ChatBody<R>(
                    state: state,
                    viewerSide: viewerSide,
                    today: clock(),
                    negotiation: timeline.negotiation,
                    hasNegotiationLoadFailed: timeline.hasLoadFailed,
                    actions: actions,
                  ),
                ),
        );
      },
    );
  }
}

class ChatBody<R extends ServiceRequest> extends StatelessWidget {
  const ChatBody({
    required this.state,
    required this.viewerSide,
    required this.today,
    this.negotiation,
    this.hasNegotiationLoadFailed = false,
    this.actions,
    super.key,
  });

  final ChatState state;
  final ConversationParticipant viewerSide;
  final DateTime today;
  final ConversationNegotiation<R>? negotiation;
  final bool hasNegotiationLoadFailed;
  final NegotiationChatActions<R>? actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ChatCubit>();
    final negotiation = this.negotiation;
    final actions = this.actions;
    final openProposal = negotiation?.openProposal;
    final onAskAdjustment = actions?.onAskAdjustment;
    final onNewVersion = actions?.onNewVersion;
    final respondsToAdjustment =
        negotiation != null &&
        onNewVersion != null &&
        isAdjustmentPending(negotiation.request);

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
        if (hasNegotiationLoadFailed)
          NegotiationLoadFailedBanner(
            onRetry: context.read<NegotiationTimelineCubit<R>>().load,
          ),
        if (negotiation != null &&
            onNewVersion != null &&
            openProposal != null &&
            respondsToAdjustment)
          AdjustmentRequestedBanner(
            onRespond: () => runNegotiationAction<R>(
              context,
              () => onNewVersion(negotiation.request, openProposal),
            ),
          )
        else if (negotiation != null && actions != null && openProposal != null)
          OpenProposalBanner(
            proposal: openProposal,
            onSee: () => runNegotiationAction<R>(
              context,
              () => actions.onSeeProposal(negotiation.request),
            ),
          ),
        Expanded(
          child: state.isEmpty && negotiation == null
              ? Center(
                  child: Text(
                    l10n.conversationEmpty,
                    style: VanepTypography.cardSubtitle,
                  ),
                )
              : ChatMessageList<R>(
                  state: state,
                  viewerSide: viewerSide,
                  today: today,
                  negotiation: negotiation,
                  actions: actions,
                ),
        ),
        ConversationInputBar(
          isSending: state.isSending,
          onSend: cubit.sendMessage,
          leading:
              negotiation != null &&
                  onAskAdjustment != null &&
                  openProposal != null
              ? IconButton(
                  tooltip: l10n.proposalDetailAskAdjustment,
                  color: VanepColors.action,
                  icon: const Icon(Icons.tune),
                  onPressed: () => runNegotiationAction<R>(
                    context,
                    () => onAskAdjustment(negotiation.request, openProposal),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class ChatMessageList<R extends ServiceRequest> extends StatelessWidget {
  const ChatMessageList({
    required this.state,
    required this.viewerSide,
    required this.today,
    this.negotiation,
    this.actions,
    super.key,
  });

  final ChatState state;
  final ConversationParticipant viewerSide;
  final DateTime today;
  final ConversationNegotiation<R>? negotiation;
  final NegotiationChatActions<R>? actions;

  List<ChatTimelineEntry> buildEntries() {
    final negotiation = this.negotiation;
    if (negotiation == null) {
      return [for (final message in state.messages) ChatMessageEntry(message)];
    }
    return buildChatTimeline(
      messages: state.messages,
      events: negotiation.events,
    );
  }

  Widget buildEntry(BuildContext context, ChatTimelineEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    return switch (entry) {
      ChatDayEntry(:final day) => ChatDayDivider(
        label: formatChatDay(l10n, day, today),
      ),
      ChatMessageEntry(:final message) => ConversationMessageBubble(
        key: ValueKey(message.token),
        message: message,
        sentByViewer: isSentByViewer(message, viewerSide),
      ),
      ChatEventEntry(:final event) => buildEventCard(context, event),
    };
  }

  Widget buildEventCard(BuildContext context, NegotiationEvent event) {
    final l10n = AppLocalizations.of(context)!;
    final negotiation = this.negotiation!;
    final actions = this.actions;
    final viewerIsClient = viewerSide == ConversationParticipant.client;
    final onAccept = actions?.onAccept;
    final onNewVersion = actions?.onNewVersion;
    final openProposal = negotiation.openProposal;
    return switch (event) {
      RequestSentEvent() when viewerIsClient => NegotiationRequestCard(
        request: negotiation.request,
        at: event.at,
        today: today,
        sentByViewer: true,
      ),
      RequestSentEvent() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NegotiationRequestCard(
            request: negotiation.request,
            at: event.at,
            today: today,
            sentByViewer: false,
          ),
          const SizedBox(height: negotiationCardSpacing / 2),
          NegotiationNotice(text: l10n.negotiationChatDriverPrivacyNotice),
        ],
      ),
      ProposalSentEvent(:final proposalToken, :final isOpen) =>
        switch (negotiation.versionWithToken(proposalToken)) {
          final proposal? => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NegotiationVersionCard(
                proposal: proposal,
                at: event.at,
                sentByViewer: !viewerIsClient,
                onSeeProposal: isOpen && viewerIsClient && actions != null
                    ? () => runNegotiationAction<R>(
                        context,
                        () => actions.onSeeProposal(negotiation.request),
                      )
                    : null,
                onAccept: isOpen && viewerIsClient && onAccept != null
                    ? () => runNegotiationAction<R>(
                        context,
                        () => onAccept(negotiation.request, proposal),
                      )
                    : null,
              ),
              if (isOpen) ...[
                const SizedBox(height: negotiationCardSpacing / 2),
                NegotiationNotice(text: l10n.negotiationChatAgreementsNotice),
              ],
            ],
          ),
          null => const SizedBox.shrink(),
        },
      AdjustmentRequestedEvent() => NegotiationAdjustmentCard(
        event: event,
        sentByViewer: viewerIsClient,
        onNewVersion:
            onNewVersion != null &&
                openProposal != null &&
                isAdjustmentPending(negotiation.request) &&
                event ==
                    negotiation.events
                        .whereType<AdjustmentRequestedEvent>()
                        .lastOrNull
            ? () => runNegotiationAction<R>(
                context,
                () => onNewVersion(negotiation.request, openProposal),
              )
            : null,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final newestFirst = buildEntries().reversed.toList();
    final cubit = context.read<ChatCubit>();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < olderMessagesTriggerExtent) {
          cubit.loadOlderMessages();
        }
        return false;
      },
      child: ListView.separated(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: newestFirst.length + (state.isLoadingOlder ? 1 : 0),
        separatorBuilder: (_, index) => SizedBox(
          height:
              index < newestFirst.length &&
                  newestFirst[index] is! ChatMessageEntry
              ? negotiationCardSpacing / 2
              : 0,
        ),
        itemBuilder: (context, index) {
          if (index == newestFirst.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: CircularProgressIndicator(color: VanepColors.action),
              ),
            );
          }
          return buildEntry(context, newestFirst[index]);
        },
      ),
    );
  }
}
