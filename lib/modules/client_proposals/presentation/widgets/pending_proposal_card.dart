import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposal.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';

class PendingProposalCard extends StatelessWidget {
  const PendingProposalCard({
    required this.proposal,
    required this.now,
    super.key,
  });

  final PendingProposal proposal;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final driver = proposal.driver;

    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProposalPersonHeader(
            avatar: VanepPersonAvatar(name: driver.name),
            name: driver.name,
            subtitle: formatDriverReputation(l10n, driver),
            subtitleLeading: driver.isNewOnVanep
                ? null
                : const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: VanepColors.warning,
                  ),
          ),
          const SizedBox(height: 14),
          ProposalTermsBox(
            lines: [
              (
                Icons.person_outline,
                formatProposalChildAndSchool(l10n, proposal),
              ),
              (
                Icons.event_repeat_outlined,
                formatProposalSchedule(l10n, proposal),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: ProposalPrice(proposal: proposal)),
              const SizedBox(width: 12),
              ProposalStatusText(
                text: formatProposalExpiry(l10n, proposal.expiresAt, now),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: VanepSecondaryButton(
                  label: l10n.clientProposalsChat,
                  icon: Icons.chat_bubble_outline,
                  onPressed: () => openUnavailableProposalAction(
                    context,
                    l10n.clientProposalsChat,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VanepPrimaryButton(
                  label: l10n.clientProposalsSeeProposal,
                  onPressed: () => openUnavailableProposalAction(
                    context,
                    l10n.clientProposalsSeeProposal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProposalTermsBox extends StatelessWidget {
  const ProposalTermsBox({required this.lines, super.key});

  final List<(IconData, String)> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VanepColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, (icon, text)) in lines.indexed) ...[
            if (index > 0) const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, size: 17, color: VanepColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: VanepTypography.cardSubtitle.copyWith(
                      color: VanepColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ProposalPrice extends StatelessWidget {
  const ProposalPrice({required this.proposal, super.key});

  final PendingProposal proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previousFee = proposal.previousMonthlyFeeCents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: formatMoney(l10n, proposal.monthlyFeeCents),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: VanepColors.textPrimary,
                ),
              ),
              TextSpan(
                text: l10n.clientProposalsPerMonth,
                style: VanepTypography.cardSubtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (previousFee != null)
          Text(
            l10n.clientProposalsPreviousFee(formatMoney(l10n, previousFee)),
            style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
          ),
      ],
    );
  }
}
