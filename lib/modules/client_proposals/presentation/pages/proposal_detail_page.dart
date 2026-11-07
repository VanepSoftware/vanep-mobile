import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_comparison_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposal_confirmations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposal_detail_sections.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/item_groups.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

typedef ProposalActionCallback = Future<bool> Function(
  ClientServiceRequest request,
  Proposal proposal,
);

class ProposalDetailActions {
  const ProposalDetailActions({
    required this.onChat,
    required this.onAskAdjustment,
    required this.onDecline,
    required this.onAccepted,
  });

  final void Function(ClientServiceRequest request) onChat;
  final ProposalActionCallback onAskAdjustment;
  final Future<ProposalDeclineOutcome?> Function(
    ClientServiceRequest request,
    Proposal proposal,
  )
  onDecline;
  final void Function(ClientServiceRequest request, Proposal proposal)
  onAccepted;
}

Future<void> confirmCancelDetailRequest(
  BuildContext context,
  ClientServiceRequest request,
) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<ProposalDetailCubit>();
  final confirmed = await showVanepConfirmDialog(
    context: context,
    title: l10n.clientProposalsCancelTitle,
    message: l10n.clientProposalsCancelMessage(request.driverName),
    confirmLabel: l10n.clientProposalsCancelRequest,
    cancelLabel: l10n.clientProposalsCancelKeep,
    isDestructive: true,
  );
  if (confirmed) await cubit.cancelRequest();
}

void openProposalComparison(
  BuildContext context, {
  required Proposal previous,
  required Proposal current,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          ProposalComparisonPage(previous: previous, current: current),
    ),
  );
}

Future<void> declineFromDetail(
  BuildContext context, {
  required ProposalDetailActions actions,
  required ClientServiceRequest request,
  required Proposal proposal,
}) async {
  final navigator = Navigator.of(context);
  final cubit = context.read<ProposalDetailCubit>();
  switch (await actions.onDecline(request, proposal)) {
    case ProposalDeclineOutcome.declined:
      navigator.pop(true);
    case ProposalDeclineOutcome.outdated:
      await cubit.load();
    case null:
      return;
  }
}

Future<void> acceptFromDetail(
  BuildContext context,
  ClientServiceRequest request,
) async {
  final cubit = context.read<ProposalDetailCubit>();
  if (await confirmProposalAcceptance(context, request)) await cubit.accept();
}

class ProposalDetailPage extends StatelessWidget {
  const ProposalDetailPage({
    required this.actions,
    this.clock = DateTime.now,
    super.key,
  });

  final ProposalDetailActions actions;
  final DateTime Function() clock;

  void onStateChanged(BuildContext context, ProposalDetailState state) {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final request = state.request;
    final accepted = state.acceptedProposal;
    if (state.status == ProposalDetailStatus.notFound) {
      VanepFeedback.showError(context, l10n.negotiationFailureNotFound);
      navigator.pop(true);
    } else if (state.cancelledRequest != null) {
      navigator.pop(true);
    } else if (accepted != null && request != null) {
      actions.onAccepted(request, accepted);
    } else if (state.actionFailure case final failure?) {
      VanepFeedback.showError(
        context,
        negotiationFailureMessage(l10n, failure),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalDetailCubit>();

    return BlocConsumer<ProposalDetailCubit, ProposalDetailState>(
      listenWhen: (previous, current) =>
          current.status != previous.status ||
          current.actionFailure != previous.actionFailure ||
          current.acceptedProposal != previous.acceptedProposal ||
          current.cancelledRequest != previous.cancelledRequest,
      listener: onStateChanged,
      builder: (context, state) {
        final request = state.request;
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: VanepAppBar(
            title: state.isRequestMode
                ? l10n.proposalDetailRequestTitle
                : l10n.proposalDetailTitle,
            caption: request == null
                ? null
                : l10n.clientProposalsForChild(
                    formatRequestChildren(l10n, request),
                  ),
            actions: [
              if (request != null && request.conversationToken != null)
                IconButton(
                  tooltip: l10n.clientProposalsChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => actions.onChat(request),
                ),
            ],
          ),
          body: switch (state.status) {
            ProposalDetailStatus.ready when request != null => RefreshIndicator(
              onRefresh: cubit.load,
              child: ProposalDetailBody(
                state: state,
                request: request,
                actions: actions,
                today: clock(),
              ),
            ),
            ProposalDetailStatus.loadFailed => VanepErrorView(
              message: l10n.proposalDetailLoadError,
              retryLabel: l10n.clientProposalsRetry,
              onRetry: cubit.load,
            ),
            _ => const Center(
              child: CircularProgressIndicator(color: VanepColors.action),
            ),
          },
          bottomNavigationBar: request == null
              ? null
              : DetailFooter(state: state, request: request, actions: actions),
        );
      },
    );
  }
}

class ProposalDetailBody extends StatelessWidget {
  const ProposalDetailBody({
    required this.state,
    required this.request,
    required this.actions,
    required this.today,
    super.key,
  });

  final ProposalDetailState state;
  final ClientServiceRequest request;
  final ProposalDetailActions actions;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proposal = state.proposal;
    final previous = state.previousVersion;
    final notes = request.notes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        if (proposal != null)
          ProposalVersionBanner(state: state, proposal: proposal),
        DetailDriverCard(request: request, proposal: proposal),
        const SizedBox(height: detailSectionSpacing),
        if (proposal != null) ...[
          ProposalValueCard(
            proposal: proposal,
            today: today,
            previousVersion: previous,
            onCompare: previous == null
                ? null
                : () => openProposalComparison(
                    context,
                    previous: previous,
                    current: proposal,
                  ),
          ),
          const SizedBox(height: detailSectionSpacing),
        ],
        DetailStudentsSection(request: request, today: today),
        const SizedBox(height: detailSectionSpacing),
        DetailWeekLegsSection(
          gridsByChildren: proposal == null
              ? [
                  for (final group in groupItemsByDays(request.items))
                    (
                      joinFirstNames(
                        l10n,
                        group.map((item) => item.dependentName),
                      ),
                      weekLegsRowsOfDays(l10n, group.first.days),
                    ),
                ]
              : [
                  for (final group in groupItemsBySchedule(proposal.items))
                    (
                      joinNames(l10n, [
                        for (final item in group) item.dependentFirstName,
                      ]),
                      weekLegsRowsOfSlots(l10n, group.first.slots),
                    ),
                ],
        ),
        const SizedBox(height: detailSectionSpacing),
        if (proposal != null) ...[
          DetailScheduleSection(proposal: proposal, request: request),
          const SizedBox(height: detailSectionSpacing),
          DetailConditionsSection(proposal: proposal),
          const SizedBox(height: detailSectionSpacing),
          if (proposal.message case final message? when message.isNotEmpty) ...[
            DetailTextSection(
              title: l10n.proposalDetailMessageTitle,
              text: message,
            ),
            const SizedBox(height: detailSectionSpacing),
          ],
        ] else ...[
          RequestTermsCard(request: request),
          const SizedBox(height: detailSectionSpacing),
          if (notes != null && notes.isNotEmpty) ...[
            DetailTextSection(
              title: l10n.proposalDetailYourMessage,
              text: notes,
            ),
            const SizedBox(height: detailSectionSpacing),
          ],
        ],
        NegotiationHistorySection(events: state.history),
        if (proposal != null) ...[
          const SizedBox(height: detailSectionSpacing),
          DetailNotice(text: l10n.proposalDetailContractNotice),
        ],
        if (proposal != null && state.canAct) ...[
          const SizedBox(height: detailSectionSpacing),
          VanepSecondaryButton(
            label: l10n.proposalDeclineTitle,
            isDestructive: true,
            onPressed: () => declineFromDetail(
              context,
              actions: actions,
              request: request,
              proposal: proposal,
            ),
          ),
        ],
      ],
    );
  }
}

class RequestTermsCard extends StatelessWidget {
  const RequestTermsCard({required this.request, super.key});

  final ClientServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: Column(
        children: [
          DetailInfoRow(
            label: l10n.proposalDetailDesiredStart,
            values: [formatCalendarDate(l10n, request.desiredStartDate)],
          ),
          DetailInfoRow(
            label: l10n.proposalDetailAnswerBy,
            values: [formatDayMonthAndTime(l10n, request.expiresAt)],
          ),
        ],
      ),
    );
  }
}

class ProposalVersionBanner extends StatelessWidget {
  const ProposalVersionBanner({
    required this.state,
    required this.proposal,
    super.key,
  });

  final ProposalDetailState state;
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentToken = state.currentVersionToken;
    if (proposal.status == ProposalStatus.sent) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: detailSectionSpacing),
      child: VanepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DetailNotice(
              text: proposal.status == ProposalStatus.superseded
                  ? l10n.proposalDetailSuperseded
                  : l10n.proposalDetailClosed(
                      proposalStatusLabel(l10n, proposal.status),
                    ),
            ),
            if (currentToken != null)
              Align(
                alignment: Alignment.centerLeft,
                child: ProposalLinkButton(
                  label: l10n.proposalDetailSeeCurrent,
                  showsChevron: true,
                  onPressed: () => context
                      .read<ProposalDetailCubit>()
                      .showVersion(currentToken),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DetailFooter extends StatelessWidget {
  const DetailFooter({
    required this.state,
    required this.request,
    required this.actions,
    super.key,
  });

  final ProposalDetailState state;
  final ClientServiceRequest request;
  final ProposalDetailActions actions;

  Future<void> askAdjustment(BuildContext context, Proposal proposal) async {
    final cubit = context.read<ProposalDetailCubit>();
    final asked = await actions.onAskAdjustment(request, proposal);
    if (asked) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proposal = state.proposal;
    final Widget? content;
    if (proposal != null && state.canAct) {
      content = Row(
        children: [
          Expanded(
            child: VanepSecondaryButton(
              label: l10n.proposalDetailAskAdjustment,
              icon: Icons.tune,
              onPressed: () => askAdjustment(context, proposal),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: VanepPrimaryButton(
              label: l10n.proposalDetailAccept,
              isLoading: state.isAccepting,
              onPressed: () => acceptFromDetail(context, request),
            ),
          ),
        ],
      );
    } else if (state.isRequestMode &&
        request.status == ServiceRequestStatus.open) {
      content = ProposalLinkButton(
        label: l10n.clientProposalsCancelRequest,
        color: VanepColors.danger,
        onPressed: state.isCancelling
            ? null
            : () => confirmCancelDetailRequest(context, request),
      );
    } else {
      content = null;
    }
    if (content == null) return const SizedBox.shrink();
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: VanepColors.card,
          border: Border(top: BorderSide(color: VanepColors.divider)),
        ),
        child: content,
      ),
    );
  }
}
