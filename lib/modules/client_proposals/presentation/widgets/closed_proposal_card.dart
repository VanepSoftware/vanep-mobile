import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposal.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';

(Color, Color) outcomeChipColors(ProposalOutcome outcome) {
  return switch (outcome) {
    ProposalOutcome.accepted => (const Color(0xFFE3F3EA), VanepColors.success),
    ProposalOutcome.expired => (
      VanepColors.warningSurface,
      VanepColors.warning,
    ),
    ProposalOutcome.declined || ProposalOutcome.cancelled => (
      VanepColors.surface,
      VanepColors.textSecondary,
    ),
  };
}

class ClosedProposalCard extends StatelessWidget {
  const ClosedProposalCard({required this.proposal, super.key});

  final ClosedProposal proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: ProposalPersonHeader(
        avatar: VanepPersonAvatar(name: proposal.driverName),
        name: proposal.driverName,
        subtitle: l10n.clientProposalsClosedSummary(
          proposal.childName,
          formatMoney(l10n, proposal.monthlyFeeCents),
        ),
        trailing: ProposalOutcomeChip(outcome: proposal.outcome),
      ),
    );
  }
}

class ProposalOutcomeChip extends StatelessWidget {
  const ProposalOutcomeChip({required this.outcome, super.key});

  final ProposalOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = outcomeChipColors(outcome);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        formatProposalOutcome(AppLocalizations.of(context)!, outcome),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
