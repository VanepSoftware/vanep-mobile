import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_segmented_control.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_negotiations.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/driver_negotiation_actions.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/driver_negotiation_card.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposals_empty_state.dart';

const negotiationsPrefetchExtent = 320.0;

class DriverProposalsTabActions {
  const DriverProposalsTabActions({
    required this.onOpenRequest,
    required this.onOpenProposal,
  });

  final DriverRequestCallback onOpenRequest;
  final DriverRequestCallback onOpenProposal;

  DriverRequestCallback openerOf(DriverServiceRequest request) {
    return driverTurnOf(request) == DriverTurn.newRequest
        ? onOpenRequest
        : onOpenProposal;
  }
}

Future<void> openAndReloadNegotiations(
  BuildContext context,
  DriverRequestCallback open,
  DriverServiceRequest request,
) async {
  final cubit = context.read<DriverNegotiationsCubit>();
  await open(request);
  await cubit.load();
}

class DriverProposalsTab extends StatelessWidget {
  const DriverProposalsTab({required this.actions, super.key});

  final DriverProposalsTabActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DriverNegotiationsCubit>();

    return Scaffold(
      backgroundColor: VanepColors.surface,
      appBar: VanepAppBar(title: l10n.navProposals),
      body: BlocConsumer<DriverNegotiationsCubit, DriverNegotiationsState>(
        listenWhen: (previous, current) =>
            current.actionFailure != null &&
            current.actionFailure != previous.actionFailure,
        listener: (context, state) => VanepFeedback.showError(
          context,
          negotiationFailureMessage(l10n, state.actionFailure!),
        ),
        builder: (context, state) {
          final negotiations = state.negotiations;
          final isNegotiations =
              state.segment == DriverProposalsSegment.negotiations;
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (isNegotiations &&
                    notification.metrics.extentAfter <
                        negotiationsPrefetchExtent) {
                  cubit.loadMore();
                }
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  VanepSegmentedControl<DriverProposalsSegment>(
                    segments: [
                      VanepSegment(
                        value: DriverProposalsSegment.negotiations,
                        label: l10n.driverProposalsTabNegotiations,
                        count: negotiations?.totalCount,
                      ),
                      VanepSegment(
                        value: DriverProposalsSegment.contracts,
                        label: l10n.driverProposalsTabContracts,
                      ),
                    ],
                    selected: state.segment,
                    onSelected: cubit.selectSegment,
                  ),
                  const SizedBox(height: proposalsSectionSpacing),
                  if (!isNegotiations)
                    VanepComingSoon(
                      title: l10n.driverProposalsTabContracts,
                      message: l10n.comingSoon,
                    )
                  else if (negotiations != null)
                    DriverNegotiationsList(
                      negotiations: negotiations,
                      actions: actions,
                      isLoadingMore: state.isLoadingMore,
                    )
                  else if (state.hasLoadFailed)
                    VanepErrorView(
                      message: l10n.driverProposalsLoadError,
                      retryLabel: l10n.clientProposalsRetry,
                      onRetry: cubit.load,
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        color: VanepColors.action,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DriverNegotiationsList extends StatelessWidget {
  const DriverNegotiationsList({
    required this.negotiations,
    required this.actions,
    this.isLoadingMore = false,
    super.key,
  });

  final DriverNegotiations negotiations;
  final DriverProposalsTabActions actions;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (negotiations.isEmpty) {
      return ProposalsEmptyState(
        icon: Icons.request_quote_outlined,
        title: l10n.driverProposalsEmptyTitle,
        message: l10n.driverProposalsEmptyMessage,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (title, requests) in [
          (l10n.clientProposalsPendingTitle, negotiations.pending),
          (l10n.clientProposalsAwaitingTitle, negotiations.awaiting),
        ])
          if (requests.isNotEmpty) ...[
            ProposalsSectionTitle(title: title),
            for (final request in requests) ...[
              DriverNegotiationCard(
                request: request,
                now: negotiations.loadedAt,
                onTap: () => openAndReloadNegotiations(
                  context,
                  actions.openerOf(request),
                  request,
                ),
              ),
              const SizedBox(height: proposalsCardSpacing),
            ],
            const SizedBox(
              height: proposalsSectionSpacing - proposalsCardSpacing,
            ),
          ],
        if (isLoadingMore)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(color: VanepColors.action),
            ),
          ),
      ],
    );
  }
}
