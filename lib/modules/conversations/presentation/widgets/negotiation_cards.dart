import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/chat_timeline.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/negotiation_labels.dart';

const negotiationCardWidth = 290.0;

// TODO(VAN-43): the proposal detail, accept and adjustment flows do not exist
// yet; open the proposal detail from the banner, "See proposal", "Accept" and
// the adjustment button once VAN-43 ships.
Future<void> openUnbuiltNegotiationAction(BuildContext context, String title) {
  return openComingSoonPage(
    context,
    title: title,
    message: AppLocalizations.of(context)!.comingSoon,
  );
}

TextStyle get negotiationDetailStyle =>
    VanepTypography.cardSubtitle.copyWith(color: VanepColors.textPrimary);

class NegotiationEventCard extends StatelessWidget {
  const NegotiationEventCard({
    required this.entry,
    required this.viewerSide,
    super.key,
  });

  final ChatNegotiationEntry entry;
  final ConversationParticipant viewerSide;

  @override
  Widget build(BuildContext context) {
    final event = entry.event;
    final sentByViewer = event.author == viewerSide;
    return switch (event) {
      QuoteRequestEvent() => QuoteRequestCard(
        request: event,
        sentByViewer: sentByViewer,
      ),
      ProposalVersionEvent() => ProposalVersionCard(
        proposal: event,
        sentByViewer: sentByViewer,
        isCurrent: entry.isCurrentProposal,
      ),
      AdjustmentRequestEvent() => AdjustmentRequestCard(
        adjustment: event,
        sentByViewer: sentByViewer,
      ),
    };
  }
}

class NegotiationCardFrame extends StatelessWidget {
  const NegotiationCardFrame({
    required this.event,
    required this.icon,
    required this.title,
    required this.sentByViewer,
    required this.children,
    this.status,
    this.highlighted = false,
    this.faded = false,
    super.key,
  });

  final NegotiationEvent event;
  final IconData icon;
  final String title;
  final bool sentByViewer;
  final List<Widget> children;
  final Widget? status;
  final bool highlighted;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = this.status;
    final accented = sentByViewer || highlighted;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.85;

    return Align(
      alignment: sentByViewer ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: faded ? 0.62 : 1,
        child: Container(
          width: negotiationCardWidth < maxWidth
              ? negotiationCardWidth
              : maxWidth,
          margin: const EdgeInsets.symmetric(vertical: 6),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: sentByViewer
                ? VanepColors.action.withValues(alpha: 0.04)
                : VanepColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accented
                  ? VanepColors.action.withValues(alpha: 0.3)
                  : VanepColors.cardBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: VanepColors.divider),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: accented
                          ? VanepColors.action
                          : VanepColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title, style: VanepTypography.ratingLabel),
                    ),
                    ?status,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, child) in children.indexed) ...[
                      if (index > 0) const SizedBox(height: 6),
                      child,
                    ],
                    if (sentByViewer) ...[
                      const SizedBox(height: 6),
                      Text(
                        formatSentByViewer(l10n, event),
                        textAlign: TextAlign.end,
                        style: VanepTypography.cardSubtitle.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
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

class NegotiationDetailLine extends StatelessWidget {
  const NegotiationDetailLine({required this.text, this.icon, super.key});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: VanepColors.textSecondary),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(text, style: negotiationDetailStyle)),
      ],
    );
  }
}

class QuoteRequestCard extends StatelessWidget {
  const QuoteRequestCard({
    required this.request,
    required this.sentByViewer,
    super.key,
  });

  final QuoteRequestEvent request;
  final bool sentByViewer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NegotiationCardFrame(
      event: request,
      icon: Icons.send_outlined,
      title: l10n.conversationNegotiationQuoteRequestTitle,
      sentByViewer: sentByViewer,
      children: [
        NegotiationDetailLine(
          icon: Icons.person_outline,
          text: formatQuoteRequestChild(l10n, request),
        ),
        NegotiationDetailLine(
          icon: Icons.event_repeat_outlined,
          text: formatQuoteRequestSchedule(l10n, request),
        ),
        NegotiationDetailLine(
          icon: Icons.event_outlined,
          text: formatQuoteRequestStart(l10n, request),
        ),
        NegotiationDetailLine(
          icon: Icons.location_on_outlined,
          text: formatQuoteRequestBoarding(l10n, request),
        ),
      ],
    );
  }
}

class ProposalVersionCard extends StatelessWidget {
  const ProposalVersionCard({
    required this.proposal,
    required this.sentByViewer,
    required this.isCurrent,
    super.key,
  });

  final ProposalVersionEvent proposal;
  final bool sentByViewer;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAnswer = isCurrent && !sentByViewer;

    return NegotiationCardFrame(
      event: proposal,
      icon: Icons.request_quote_outlined,
      title: l10n.conversationNegotiationProposalTitle(proposal.version),
      sentByViewer: sentByViewer,
      highlighted: isCurrent,
      faded: !isCurrent,
      status: Text(
        isCurrent
            ? l10n.conversationNegotiationProposalCurrent
            : l10n.conversationNegotiationProposalReplaced,
        style: VanepTypography.ratingLabel.copyWith(
          color: isCurrent ? VanepColors.action : VanepColors.textSecondary,
        ),
      ),
      children: [
        ProposalFee(
          monthlyFeeCents: proposal.monthlyFeeCents,
          large: isCurrent,
        ),
        NegotiationDetailLine(text: formatProposalInstallments(l10n, proposal)),
        if (isCurrent) ...[
          NegotiationDetailLine(text: formatProposalPeriod(l10n, proposal)),
          NegotiationDetailLine(text: formatProposalExpiry(l10n, proposal)),
        ],
        if (canAnswer) const ProposalAnswerActions(),
      ],
    );
  }
}

class ProposalFee extends StatelessWidget {
  const ProposalFee({
    required this.monthlyFeeCents,
    required this.large,
    super.key,
  });

  final int monthlyFeeCents;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: formatMoney(l10n, monthlyFeeCents),
            style: TextStyle(
              fontSize: large ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: VanepColors.textPrimary,
            ),
          ),
          TextSpan(
            text: l10n.clientProposalsPerMonth,
            style: large
                ? VanepTypography.cardSubtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: VanepColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}

class ProposalAnswerActions extends StatelessWidget {
  const ProposalAnswerActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: VanepSecondaryButton(
              compact: true,
              label: l10n.conversationNegotiationSeeProposal,
              onPressed: () => openUnbuiltNegotiationAction(
                context,
                l10n.conversationNegotiationSeeProposal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: VanepPrimaryButton(
              compact: true,
              label: l10n.conversationNegotiationAccept,
              onPressed: () => openUnbuiltNegotiationAction(
                context,
                l10n.conversationNegotiationAccept,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdjustmentRequestCard extends StatelessWidget {
  const AdjustmentRequestCard({
    required this.adjustment,
    required this.sentByViewer,
    super.key,
  });

  final AdjustmentRequestEvent adjustment;
  final bool sentByViewer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NegotiationCardFrame(
      event: adjustment,
      icon: Icons.tune,
      title: l10n.conversationNegotiationAdjustmentTitle,
      sentByViewer: sentByViewer,
      children: [
        Text.rich(
          TextSpan(
            style: negotiationDetailStyle,
            children: [
              TextSpan(text: '${l10n.conversationNegotiationSuggestedFee} '),
              TextSpan(
                text: formatMonthlyFee(
                  l10n,
                  adjustment.suggestedMonthlyFeeCents,
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        NegotiationDetailLine(
          text: l10n.conversationNegotiationQuotedNote(adjustment.note),
        ),
      ],
    );
  }
}
