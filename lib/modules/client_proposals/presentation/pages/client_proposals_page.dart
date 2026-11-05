import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_segmented_control.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/child_filter_button.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/child_filter_sheet.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/client_proposals_skeleton.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/closed_proposal_card.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/pending_proposal_card.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_empty_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/sent_request_card.dart';

class ClientProposalsPage extends StatelessWidget {
  const ClientProposalsPage({required this.onSearchVansTapped, super.key});

  final VoidCallback onSearchVansTapped;

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
            onPressed: onSearchVansTapped,
          ),
        ],
      ),
      body: BlocBuilder<ClientProposalsCubit, ClientProposalsState>(
        builder: (context, state) {
          final proposals = state.proposals;
          return RefreshIndicator(
            onRefresh: cubit.loadProposals,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                if (proposals != null)
                  ClientProposalsContent(
                    state: state,
                    proposals: proposals,
                    onSearchVansTapped: onSearchVansTapped,
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
    required this.onSearchVansTapped,
    super.key,
  });

  final ClientProposalsState state;
  final ClientProposals proposals;
  final VoidCallback onSearchVansTapped;

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
            onSearchVansTapped: onSearchVansTapped,
          )
        else
          ClosedProposalsTab(feed: feed),
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
    required this.onSearchVansTapped,
    super.key,
  });

  final ClientProposals proposals;
  final ProposalsFeed feed;
  final VoidCallback onSearchVansTapped;

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
            onAction: onSearchVansTapped,
          ),
        if (feed.pending.isNotEmpty) ...[
          ProposalsSectionTitle(title: l10n.clientProposalsPendingTitle),
          for (final proposal in feed.pending) ...[
            PendingProposalCard(proposal: proposal, now: now),
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
            SentRequestCard(request: request, now: now),
            const SizedBox(height: proposalsCardSpacing),
          ],
        ],
      ],
    );
  }
}

class ClosedProposalsTab extends StatelessWidget {
  const ClosedProposalsTab({required this.feed, super.key});

  final ProposalsFeed feed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (feed.closed.isEmpty) {
      return ProposalsEmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.clientProposalsEmptyClosedTitle,
        message: l10n.clientProposalsEmptyClosedMessage,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final proposal in feed.closed) ...[
          ClosedProposalCard(proposal: proposal),
          const SizedBox(height: proposalsCardSpacing),
        ],
      ],
    );
  }
}
