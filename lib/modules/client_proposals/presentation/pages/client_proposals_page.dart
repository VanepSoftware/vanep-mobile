import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_segmented_control.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/awaiting_request_card.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/child_filter_button.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/child_filter_sheet.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/client_proposals_skeleton.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/closed_proposal_card.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/pending_proposal_card.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposals_empty_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';

typedef ProposalRequestCallback = Future<void> Function(
  ClientServiceRequest request,
);

const closedPrefetchExtent = 320.0;

Future<void> confirmCancelRequest(
  BuildContext context,
  ClientServiceRequest request,
) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<ClientProposalsCubit>();
  final confirmed = await showVanepConfirmDialog(
    context: context,
    title: l10n.clientProposalsCancelTitle,
    message: l10n.clientProposalsCancelMessage(request.driverName),
    confirmLabel: l10n.clientProposalsCancelRequest,
    cancelLabel: l10n.clientProposalsCancelKeep,
    isDestructive: true,
  );
  if (confirmed) await cubit.cancelRequest(request.token);
}

class ClientProposalsActions {
  const ClientProposalsActions({
    required this.onSearchVansTapped,
    required this.onSeeProposal,
    required this.onSeeRequest,
    required this.onChat,
  });

  final VoidCallback onSearchVansTapped;
  final ProposalRequestCallback onSeeProposal;
  final ProposalRequestCallback onSeeRequest;
  final ProposalRequestCallback onChat;

  VoidCallback? chatWith(ClientServiceRequest request) {
    if (request.conversationToken == null) return null;
    return () => onChat(request);
  }
}

Future<void> openAndReloadProposals(
  BuildContext context,
  ProposalRequestCallback open,
  ClientServiceRequest request,
) async {
  final cubit = context.read<ClientProposalsCubit>();
  await open(request);
  await cubit.loadProposals();
}

class ClientProposalsPage extends StatelessWidget {
  const ClientProposalsPage({required this.actions, super.key});

  final ClientProposalsActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ClientProposalsCubit>();

    return Scaffold(
      backgroundColor: VanepColors.surface,
      appBar: VanepAppBar(
        title: l10n.clientProposalsTitle,
        actions: [
          IconButton(
            tooltip: l10n.clientProposalsSearchVans,
            icon: const Icon(Icons.search),
            onPressed: actions.onSearchVansTapped,
          ),
        ],
      ),
      body: BlocConsumer<ClientProposalsCubit, ClientProposalsState>(
        listenWhen: (previous, current) =>
            current.actionFailure != null &&
            current.actionFailure != previous.actionFailure,
        listener: (context, state) => VanepFeedback.showError(
          context,
          negotiationFailureMessage(l10n, state.actionFailure!),
        ),
        builder: (context, state) {
          final proposals = state.proposals;
          return RefreshIndicator(
            onRefresh: cubit.loadProposals,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (state.tab == ProposalsTab.closed &&
                    notification.metrics.extentAfter < closedPrefetchExtent) {
                  cubit.loadMoreClosed();
                }
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  if (proposals != null)
                    ClientProposalsContent(
                      state: state,
                      proposals: proposals,
                      actions: actions,
                    )
                  else if (state.hasLoadFailed)
                    VanepErrorView(
                      message: l10n.clientProposalsLoadError,
                      retryLabel: l10n.clientProposalsRetry,
                      onRetry: cubit.loadProposals,
                    )
                  else
                    const ClientProposalsSkeleton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ClientProposalsContent extends StatelessWidget {
  const ClientProposalsContent({
    required this.state,
    required this.proposals,
    required this.actions,
    super.key,
  });

  final ClientProposalsState state;
  final ClientProposals proposals;
  final ClientProposalsActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ClientProposalsCubit>();
    final feed = state.visibleFeed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (proposals.canFilterByChild) ...[
          ChildFilterButton(
            children: proposals.children,
            selectedChild: state.selectedChild,
            onTap: () => showChildFilterSheet(
              context,
              proposals: proposals,
              selectedChildToken: state.selectedChildToken,
              onChildSelected: cubit.selectChild,
            ),
          ),
          const SizedBox(height: proposalsSectionSpacing),
        ],
        VanepSegmentedControl<ProposalsTab>(
          segments: [
            VanepSegment(
              value: ProposalsTab.open,
              label: l10n.clientProposalsTabOpen,
              count: feed.openCount,
            ),
            VanepSegment(
              value: ProposalsTab.closed,
              label: l10n.clientProposalsTabClosed,
              count: feed.closedCount,
            ),
          ],
          selected: state.tab,
          onSelected: cubit.selectTab,
        ),
        const SizedBox(height: proposalsSectionSpacing),
        if (state.tab == ProposalsTab.open)
          OpenProposalsTab(
            proposals: proposals,
            feed: feed,
            actions: actions,
            cancellingRequestToken: state.cancellingRequestToken,
          )
        else
          ClosedProposalsTab(
            feed: feed,
            isLoadingMore: state.isLoadingMoreClosed,
          ),
      ],
    );
  }
}

class OpenRequestsLine extends StatelessWidget {
  const OpenRequestsLine({required this.proposals, super.key});

  final ClientProposals proposals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = proposals.hasReachedOpenRequestsLimit
        ? VanepColors.warning
        : VanepColors.textSecondary;
    return Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.clientProposalsOpenRequests(
              proposals.openRequestsCount,
              openRequestsLimit,
            ),
            style: VanepTypography.cardSubtitle.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class OpenProposalsTab extends StatelessWidget {
  const OpenProposalsTab({
    required this.proposals,
    required this.feed,
    required this.actions,
    this.cancellingRequestToken,
    super.key,
  });

  final ClientProposals proposals;
  final ProposalsFeed feed;
  final ClientProposalsActions actions;
  final String? cancellingRequestToken;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = proposals.loadedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OpenRequestsLine(proposals: proposals),
        const SizedBox(height: proposalsSectionSpacing),
        if (feed.openCount == 0)
          ProposalsEmptyState(
            icon: Icons.request_quote_outlined,
            title: l10n.clientProposalsEmptyOpenTitle,
            message: l10n.clientProposalsEmptyOpenMessage,
            actionLabel: l10n.clientHomeFindVanButton,
            onAction: actions.onSearchVansTapped,
          ),
        if (feed.pending.isNotEmpty) ...[
          ProposalsSectionTitle(title: l10n.clientProposalsPendingTitle),
          for (final request in feed.pending) ...[
            PendingProposalCard(
              request: request,
              now: now,
              onSeeProposal: () => openAndReloadProposals(
                context,
                actions.onSeeProposal,
                request,
              ),
              onChat: actions.chatWith(request),
            ),
            const SizedBox(height: proposalsCardSpacing),
          ],
        ],
        if (feed.pending.isNotEmpty && feed.awaiting.isNotEmpty)
          const SizedBox(
            height: proposalsSectionSpacing - proposalsCardSpacing,
          ),
        if (feed.awaiting.isNotEmpty) ...[
          ProposalsSectionTitle(title: l10n.clientProposalsAwaitingTitle),
          for (final request in feed.awaiting) ...[
            AwaitingRequestCard(
              request: request,
              now: now,
              isCancelling: cancellingRequestToken == request.token,
              onCancel: () => confirmCancelRequest(context, request),
              onSeeRequest: () => openAndReloadProposals(
                context,
                actions.onSeeRequest,
                request,
              ),
              onSeeProposal: () => openAndReloadProposals(
                context,
                actions.onSeeProposal,
                request,
              ),
            ),
            const SizedBox(height: proposalsCardSpacing),
          ],
        ],
      ],
    );
  }
}

class ClosedProposalsTab extends StatelessWidget {
  const ClosedProposalsTab({
    required this.feed,
    this.isLoadingMore = false,
    super.key,
  });

  final ProposalsFeed feed;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (feed.closed.isEmpty && !isLoadingMore) {
      return ProposalsEmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.clientProposalsEmptyClosedTitle,
        message: l10n.clientProposalsEmptyClosedMessage,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final request in feed.closed) ...[
          ClosedProposalCard(request: request),
          const SizedBox(height: proposalsCardSpacing),
        ],
        if (isLoadingMore)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
