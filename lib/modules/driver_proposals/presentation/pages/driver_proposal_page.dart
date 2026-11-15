import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_current_dot.dart';
import 'package:vanep_mobile/core/ui/vanep_expiry_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_installment_price.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_proposal_detail.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/driver_proposals_labels.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/driver_service_request_page.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/driver_negotiation_actions.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/driver_request_sections.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/item_groups.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/leg_times.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

void openFullProposal(BuildContext context, DriverNegotiationActions actions) {
  final cubit = context.read<DriverProposalCubit>();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DriverProposalCubit>.value(
        value: cubit,
        child: DriverProposalPage(actions: actions, isReadOnly: true),
      ),
    ),
  );
}

class DriverProposalPage extends StatelessWidget {
  const DriverProposalPage({
    required this.actions,
    this.isReadOnly = false,
    this.clock = DateTime.now,
    super.key,
  });

  final DriverNegotiationActions actions;
  final bool isReadOnly;
  final DateTime Function() clock;

  void onStateChanged(BuildContext context, DriverProposalState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.status == DriverProposalStatus.notFound) {
      VanepFeedback.showError(context, l10n.negotiationFailureNotFound);
      Navigator.of(context).pop(true);
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
    final cubit = context.read<DriverProposalCubit>();

    return BlocConsumer<DriverProposalCubit, DriverProposalState>(
      listenWhen: (previous, current) =>
          current.status != previous.status ||
          current.actionFailure != previous.actionFailure,
      listener: onStateChanged,
      builder: (context, state) {
        final detail = state.detail;
        final adjustment = isReadOnly ? null : detail?.pendingAdjustment;
        final onChat = detail == null ? null : actions.chatWith(detail.request);
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: VanepAppBar(
            title: adjustment != null
                ? l10n.driverProposalsAdjustmentRequested
                : l10n.proposalDetailTitle,
            caption: detail == null
                ? null
                : formatClientAndChildren(l10n, detail.request),
            actions: [
              if (onChat != null)
                IconButton(
                  tooltip: l10n.clientProposalsChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: onChat,
                ),
            ],
          ),
          body: switch (state.status) {
            DriverProposalStatus.ready when detail != null => RefreshIndicator(
              onRefresh: cubit.load,
              child: adjustment != null
                  ? DriverAdjustmentBody(
                      detail: detail,
                      adjustment: adjustment,
                      actions: actions,
                      today: clock(),
                    )
                  : DriverProposalBody(detail: detail, today: clock()),
            ),
            DriverProposalStatus.loadFailed => VanepErrorView(
              message: l10n.proposalDetailLoadError,
              retryLabel: l10n.clientProposalsRetry,
              onRetry: cubit.load,
            ),
            _ => Center(
              child: CircularProgressIndicator(color: context.palette.action),
            ),
          },
          bottomNavigationBar: detail != null && adjustment != null
              ? DriverAnswerFooter(
                  primaryLabel: l10n.driverProposalsNewVersion,
                  onDecline: () => declineAndLeave(
                    context,
                    actions: actions,
                    request: detail.request,
                    reload: cubit.load,
                  ),
                  onPrimary: () => composeAndLeave(
                    context,
                    actions: actions,
                    request: detail.request,
                    previousVersion: detail.proposal,
                    reload: cubit.load,
                  ),
                )
              : null,
        );
      },
    );
  }
}

class DriverAdjustmentBody extends StatelessWidget {
  const DriverAdjustmentBody({
    required this.detail,
    required this.adjustment,
    required this.actions,
    required this.today,
    super.key,
  });

  final DriverProposalDetail detail;
  final DateTime today;
  final ProposalAdjustment adjustment;
  final DriverNegotiationActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        AdjustmentRequestCard(
          adjustment: adjustment,
          proposal: detail.proposal,
          today: today,
        ),
        const SizedBox(height: detailSectionSpacing),
        CurrentVersionCard(
          proposal: detail.proposal,
          today: today,
          onSeeFullProposal: () => openFullProposal(context, actions),
        ),
        const SizedBox(height: detailSectionSpacing),
        NegotiationHistorySection(events: detail.history),
        const SizedBox(height: detailSectionSpacing),
        DetailNotice(text: l10n.driverAdjustmentReplacesNotice),
      ],
    );
  }
}

String? currentValueOf(
  AppLocalizations l10n,
  Proposal proposal,
  ProposalAdjustmentField field,
) {
  return switch (field) {
    ProposalAdjustmentField.price => formatMoney(
      l10n,
      proposal.installmentAmountCents,
    ),
    ProposalAdjustmentField.installments => l10n.installmentsCount(
      proposal.installments,
    ),
    ProposalAdjustmentField.period => formatProposalPeriod(l10n, proposal),
    ProposalAdjustmentField.schedule || ProposalAdjustmentField.other => null,
  };
}

String formatAdjustmentMoment(
  AppLocalizations l10n,
  DateTime moment,
  DateTime today,
) {
  final local = moment.toLocal();
  final time = l10n.driverAdjustmentTime(
    local.hour,
    local.minute.toString().padLeft(2, '0'),
  );
  return switch (calendarDaysBetween(local, today)) {
    0 => l10n.driverAdjustmentSentToday(time),
    1 => l10n.driverAdjustmentSentYesterday(time),
    _ => l10n.driverAdjustmentSentOn(formatDayAndMonth(l10n, local), time),
  };
}

class AdjustmentRequestCard extends StatelessWidget {
  const AdjustmentRequestCard({
    required this.adjustment,
    required this.proposal,
    required this.today,
    super.key,
  });

  final ProposalAdjustment adjustment;
  final Proposal proposal;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final suggestion = adjustment.suggestedValue?.trim() ?? '';
    final note = adjustment.note?.trim() ?? '';
    return VanepCard(
      borderColor: context.palette.actionBorder,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n
                      .driverAdjustmentHeader(
                        adjustmentFieldLabel(l10n, adjustment.field),
                      )
                      .toUpperCase(),
                  style: context.typography.overline.copyWith(fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatAdjustmentMoment(l10n, adjustment.createdAt, today),
                style: context.typography.cardSubtitle,
              ),
            ],
          ),
          if (suggestion.isNotEmpty) ...[
            const SizedBox(height: 20),
            AdjustmentComparison(
              version: proposal.version,
              current: currentValueOf(l10n, proposal, adjustment.field),
              suggestion: suggestion,
            ),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 20),
            AdjustmentNote(note: note),
          ],
        ],
      ),
    );
  }
}

class AdjustmentComparison extends StatelessWidget {
  const AdjustmentComparison({
    required this.version,
    required this.current,
    required this.suggestion,
    super.key,
  });

  final int version;
  final String? current;
  final String suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = this.current;
    final suggested = AdjustmentValue(
      label: l10n.driverAdjustmentSuggested,
      value: suggestion,
      isSuggestion: true,
    );
    if (current == null) return suggested;
    return Semantics(
      label: l10n.driverAdjustmentFromTo(current, suggestion),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AdjustmentValue(
              label: l10n.proposalDetailVersion(version),
              value: current,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Icon(
              Icons.arrow_forward,
              size: 20,
              color: context.palette.textMuted,
            ),
          ),
          Expanded(child: suggested),
        ],
      ),
    );
  }
}

class AdjustmentValue extends StatelessWidget {
  const AdjustmentValue({
    required this.label,
    required this.value,
    this.isSuggestion = false,
    super.key,
  });

  final String label;
  final String value;
  final bool isSuggestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.typography.cardSubtitle),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.typography.heading.copyWith(
            fontSize: 20,
            color: isSuggestion
                ? context.palette.action
                : context.palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class AdjustmentNote extends StatelessWidget {
  const AdjustmentNote({required this.note, super.key});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        note,
        style: context.typography.body.copyWith(
          color: context.palette.textPrimary,
        ),
      ),
    );
  }
}

class CurrentVersionCard extends StatelessWidget {
  const CurrentVersionCard({
    required this.proposal,
    required this.today,
    required this.onSeeFullProposal,
    super.key,
  });

  final Proposal proposal;
  final DateTime today;
  final VoidCallback onSeeFullProposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = {
      for (final item in proposal.items)
        formatSlotsDaysAndLegs(l10n, item.slots),
    };
    final pickups = {
      for (final item in proposal.items)
        ...formatLegTimes(l10n, timesOfLeg(item.slots, RouteLeg.outbound)),
    };
    return VanepCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              VanepCurrentDot(
                isCurrent: true,
                semanticLabel: l10n.negotiationHistoryCurrent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.proposalDetailVersion(proposal.version),
                  style: context.typography.cardTitle,
                ),
              ),
              VanepExpiryChip(
                label: l10n.proposalDetailExpiresOn(
                  formatDayAndMonth(l10n, proposal.validUntil),
                ),
                isUrgent: isExpiryUrgent(today, proposal.validUntil),
              ),
            ],
          ),
          const SizedBox(height: 8),
          VanepInstallmentPrice(
            amountCents: proposal.installmentAmountCents,
            installments: proposal.installments,
            amountStyle: context.typography.heading.copyWith(fontSize: 22),
            countStyle: context.typography.cardSubtitle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatMoney(l10n, proposal.totalAmountCents),
            style: context.typography.cardSubtitle,
          ),
          const SizedBox(height: 4),
          DetailInfoRow(
            label: l10n.proposalDetailDaysTitle,
            values: days.toList(),
          ),
          if (pickups.isNotEmpty)
            DetailInfoRow(
              label: l10n.quoteRequestPickup,
              values: pickups.toList(),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: ProposalLinkButton(
              label: l10n.driverAdjustmentSeeFullProposal,
              showsChevron: true,
              onPressed: onSeeFullProposal,
            ),
          ),
        ],
      ),
    );
  }
}

class DriverProposalBody extends StatelessWidget {
  const DriverProposalBody({
    required this.detail,
    required this.today,
    super.key,
  });

  final DriverProposalDetail detail;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proposal = detail.proposal;
    final vehicle = proposal.vehicle;
    final message = proposal.message;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        if (!detail.isOpen) ...[
          VanepCard(
            child: DetailNotice(
              text: l10n.proposalDetailClosed(
                proposalStatusLabel(l10n, proposal.status),
              ),
            ),
          ),
          const SizedBox(height: detailSectionSpacing),
        ],
        ProposalValueCard(proposal: proposal, today: today),
        if (vehicle != null) ...[
          const SizedBox(height: 10),
          DetailNotice(
            icon: Icons.airport_shuttle_outlined,
            text: formatProposalVehicle(l10n, vehicle),
          ),
        ],
        const SizedBox(height: detailSectionSpacing),
        DriverStudentsSection(request: detail.request),
        const SizedBox(height: detailSectionSpacing),
        DetailWeekLegsSection(
          gridsByChildren: [
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
        DetailScheduleSection(proposal: proposal),
        const SizedBox(height: detailSectionSpacing),
        DetailConditionsSection(proposal: proposal),
        if (message != null && message.trim().isNotEmpty) ...[
          const SizedBox(height: detailSectionSpacing),
          DetailTextSection(
            title: l10n.proposalAdjustmentMessage,
            text: message,
          ),
        ],
        const SizedBox(height: detailSectionSpacing),
        NegotiationHistorySection(events: detail.history),
      ],
    );
  }
}
