import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_current_dot.dart';
import 'package:vanep_mobile/core/ui/vanep_installment_price.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/negotiation_chat_labels.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

const negotiationCardSpacing = 12.0;

const negotiationCardMaxWidth = 320.0;

const negotiationCardWidthFactor = 0.82;

const negotiationCardRadius = 14.0;

const supersededVersionOpacity = 0.6;

class NegotiationChatCard extends StatelessWidget {
  const NegotiationChatCard({
    required this.icon,
    required this.title,
    required this.at,
    required this.sentByViewer,
    required this.children,
    this.trailing,
    this.isHighlighted = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final DateTime at;
  final bool sentByViewer;
  final List<Widget> children;
  final Widget? trailing;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    final isTinted = sentByViewer || isHighlighted;
    final maxWidth =
        MediaQuery.sizeOf(context).width * negotiationCardWidthFactor;
    return Align(
      alignment: sentByViewer ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth < negotiationCardMaxWidth
              ? maxWidth
              : negotiationCardMaxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: sentByViewer ? VanepColors.actionTint : VanepColors.card,
            borderRadius: BorderRadius.circular(negotiationCardRadius),
            border: Border.all(
              color: isTinted
                  ? VanepColors.actionBorder
                  : VanepColors.cardBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isTinted
                          ? VanepColors.actionBorder
                          : VanepColors.divider,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: VanepColors.action),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: VanepTypography.cardTitle.copyWith(fontSize: 14),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing,
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...children,
                    const SizedBox(height: 6),
                    Text(
                      formatConversationTime(at),
                      textAlign: TextAlign.end,
                      style: VanepTypography.cardSubtitle.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NegotiationCardLine extends StatelessWidget {
  const NegotiationCardLine({
    required this.text,
    this.icon,
    this.isStrong = false,
    super.key,
  });

  final String text;
  final IconData? icon;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: VanepColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.textPrimary,
                fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NegotiationRequestCard extends StatelessWidget {
  const NegotiationRequestCard({
    required this.request,
    required this.at,
    required this.today,
    required this.sentByViewer,
    super.key,
  });

  final ServiceRequest request;
  final DateTime at;
  final DateTime today;
  final bool sentByViewer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final neighborhoods = {
      for (final item in request.items) ?item.pickupNeighborhood,
    };
    return NegotiationChatCard(
      icon: Icons.send_outlined,
      title: l10n.negotiationHistoryRequestSent,
      at: at,
      sentByViewer: sentByViewer,
      children: [
        for (final item in request.items) ...[
          NegotiationCardLine(
            icon: Icons.person_outline,
            text: formatRequestChild(l10n, item, today),
            isStrong: true,
          ),
          if (formatRequestSchool(l10n, item) case final school?)
            NegotiationCardLine(icon: Icons.school_outlined, text: school),
          for (final days in formatRequestDays(l10n, item.days))
            NegotiationCardLine(icon: Icons.event_repeat, text: days),
          const SizedBox(height: 4),
        ],
        NegotiationCardLine(
          icon: Icons.event_outlined,
          text: l10n.negotiationChatStartsOn(
            formatCalendarDate(l10n, request.desiredStartDate),
          ),
        ),
        for (final neighborhood in neighborhoods)
          NegotiationCardLine(
            icon: Icons.location_on_outlined,
            text: l10n.negotiationChatPickupIn(neighborhood),
          ),
      ],
    );
  }
}

class NegotiationVersionCard extends StatelessWidget {
  const NegotiationVersionCard({
    required this.proposal,
    required this.at,
    required this.sentByViewer,
    this.onSeeProposal,
    this.onAccept,
    super.key,
  });

  final Proposal proposal;
  final DateTime at;
  final bool sentByViewer;
  final VoidCallback? onSeeProposal;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrent = proposal.status == ProposalStatus.sent;
    final onSeeProposal = this.onSeeProposal;
    final onAccept = this.onAccept;
    final card = NegotiationChatCard(
      icon: Icons.request_quote_outlined,
      title: l10n.negotiationChatVersion(proposal.version),
      at: at,
      sentByViewer: sentByViewer,
      isHighlighted: isCurrent,
      trailing: isCurrent
          ? VanepCurrentDot(
              isCurrent: true,
              semanticLabel: l10n.negotiationHistoryCurrent,
            )
          : Text(
              proposalStatusLabel(l10n, proposal.status),
              style: VanepTypography.cardSubtitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
      children: [
        VanepInstallmentPrice(
          amountCents: proposal.installmentAmountCents,
          installments: proposal.installments,
          amountStyle: VanepTypography.heading.copyWith(
            fontSize: isCurrent ? 22 : 18,
          ),
          countStyle: VanepTypography.cardSubtitle.copyWith(
            fontSize: isCurrent ? 14 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatMoney(l10n, proposal.totalAmountCents),
          style: VanepTypography.cardSubtitle,
        ),
        const SizedBox(height: 4),
        NegotiationCardLine(text: l10n.negotiationChatDueDay(proposal.dueDay)),
        if (isCurrent) ...[
          NegotiationCardLine(
            text: formatCalendarRange(l10n, proposal.startsOn, proposal.endsOn),
          ),
          NegotiationCardLine(
            text: l10n.proposalDetailExpiresOn(
              formatDayAndMonth(l10n, proposal.validUntil),
            ),
          ),
        ],
        if (onSeeProposal != null || onAccept != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (onSeeProposal != null)
                Expanded(
                  child: VanepSecondaryButton(
                    label: l10n.clientProposalsSeeProposal,
                    onPressed: onSeeProposal,
                  ),
                ),
              if (onSeeProposal != null && onAccept != null)
                const SizedBox(width: 8),
              if (onAccept != null)
                Expanded(
                  child: VanepPrimaryButton(
                    label: l10n.proposalDetailAccept,
                    onPressed: onAccept,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
    if (proposal.status != ProposalStatus.superseded) return card;
    return Opacity(opacity: supersededVersionOpacity, child: card);
  }
}

class NegotiationAdjustmentCard extends StatelessWidget {
  const NegotiationAdjustmentCard({
    required this.event,
    required this.sentByViewer,
    this.onNewVersion,
    super.key,
  });

  final AdjustmentRequestedEvent event;
  final bool sentByViewer;
  final VoidCallback? onNewVersion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final field = adjustmentFieldLabel(l10n, event.field);
    final suggestion = event.suggestedValue?.trim() ?? '';
    final note = event.note?.trim() ?? '';
    final onNewVersion = this.onNewVersion;
    return NegotiationChatCard(
      icon: Icons.tune,
      title: l10n.negotiationChatAdjustmentTitle,
      at: event.at,
      sentByViewer: sentByViewer,
      children: [
        NegotiationCardLine(
          text: suggestion.isEmpty
              ? field
              : l10n.negotiationChatSuggestion(field, suggestion),
          isStrong: true,
        ),
        if (note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              note,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (onNewVersion != null) ...[
          const SizedBox(height: 10),
          VanepPrimaryButton(
            label: l10n.driverProposalsNewVersion,
            onPressed: onNewVersion,
          ),
        ],
      ],
    );
  }
}

class NegotiationNotice extends StatelessWidget {
  const NegotiationNotice({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: VanepColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: VanepColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatDayDivider extends StatelessWidget {
  const ChatDayDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: VanepColors.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: VanepTypography.cardSubtitle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class OpenProposalBanner extends StatelessWidget {
  const OpenProposalBanner({
    required this.proposal,
    required this.onSee,
    super.key,
  });

  final Proposal proposal;
  final VoidCallback onSee;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: VanepColors.actionTint,
      shape: const Border(
        top: BorderSide(color: VanepColors.divider),
        bottom: BorderSide(color: VanepColors.actionBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            const Icon(
              Icons.request_quote_outlined,
              size: 20,
              color: VanepColors.action,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                formatOpenProposalBanner(l10n, proposal),
                style: VanepTypography.cardSubtitle.copyWith(
                  color: VanepColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(onPressed: onSee, child: Text(l10n.negotiationChatSee)),
          ],
        ),
      ),
    );
  }
}

class NegotiationLoadFailedBanner extends StatelessWidget {
  const NegotiationLoadFailedBanner({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: VanepColors.warningSurfaceSoft,
      shape: const Border(
        top: BorderSide(color: VanepColors.divider),
        bottom: BorderSide(color: VanepColors.warningBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              size: 20,
              color: VanepColors.warning,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.negotiationChatLoadError,
                style: VanepTypography.cardSubtitle.copyWith(
                  color: VanepColors.warningText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.conversationRetry)),
          ],
        ),
      ),
    );
  }
}

class AdjustmentRequestedBanner extends StatelessWidget {
  const AdjustmentRequestedBanner({required this.onRespond, super.key});

  final VoidCallback onRespond;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: VanepColors.warningSurfaceSoft,
      shape: const Border(
        top: BorderSide(color: VanepColors.divider),
        bottom: BorderSide(color: VanepColors.warningBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            const Icon(Icons.tune, size: 20, color: VanepColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.driverProposalsAdjustmentRequested,
                style: VanepTypography.cardSubtitle.copyWith(
                  color: VanepColors.warningText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onRespond,
              child: Text(l10n.negotiationChatRespond),
            ),
          ],
        ),
      ),
    );
  }
}
