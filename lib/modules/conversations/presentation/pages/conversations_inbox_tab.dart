import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_inbox_tile.dart';

class ConversationsInboxTab extends StatelessWidget {
  const ConversationsInboxTab({
    required this.viewerSide,
    required this.onConversationTapped,
    super.key,
  });

  final ConversationParticipant viewerSide;
  final Future<void> Function(Conversation conversation) onConversationTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              l10n.conversationsInboxTitle,
              style: VanepTypography.pageTitle,
            ),
          ),
          Expanded(
            child:
                BlocBuilder<ConversationsInboxCubit, ConversationsInboxState>(
                  builder: (context, state) => ConversationsInboxBody(
                    state: state,
                    viewerSide: viewerSide,
                    onConversationTapped: onConversationTapped,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class ConversationsInboxBody extends StatelessWidget {
  const ConversationsInboxBody({
    required this.state,
    required this.viewerSide,
    required this.onConversationTapped,
    super.key,
  });

  final ConversationsInboxState state;
  final ConversationParticipant viewerSide;
  final Future<void> Function(Conversation conversation) onConversationTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ConversationsInboxCubit>();

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: VanepColors.action),
      );
    }
    if (state.hasLoadFailed) {
      final failure = state.failure;
      return VanepErrorView(
        message: failure == null
            ? l10n.conversationsInboxLoadError
            : conversationFailureLabel(l10n, failure),
        retryLabel: l10n.conversationRetry,
        onRetry: cubit.loadConversations,
      );
    }
    if (state.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            conversationsInboxEmptyLabel(l10n, viewerSide),
            textAlign: TextAlign.center,
            style: VanepTypography.cardSubtitle,
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: VanepColors.action,
      onRefresh: cubit.loadConversations,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: state.conversations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return ConversationInboxTile(
            key: ValueKey(conversation.token),
            conversation: conversation,
            viewerSide: viewerSide,
            onTap: () async {
              await onConversationTapped(conversation);
              await cubit.loadConversations();
            },
          );
        },
      ),
    );
  }
}
