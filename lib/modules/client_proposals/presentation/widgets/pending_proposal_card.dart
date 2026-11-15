import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_installment_price.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/request_schools.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';

class PendingProposalCard extends StatelessWidget {
  const PendingProposalCard({
    required this.request,
    required this.now,
    required this.onSeeProposal,
    this.onChat,
    super.key,
  });

  final ClientServiceRequest request;
  final DateTime now;
  final VoidCallback onSeeProposal;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proposal = request.currentProposal;
    final onChat = this.onChat;

    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProposalDriverHeader(request: request),
          const SizedBox(height: 14),
          ProposalTermsBox(
            lines: [
              for (final group in groupItemsBySchool(request.items))
                (Icons.person_outline, formatSchoolGroupLine(l10n, group)),
              if (proposal != null)
                (
                  Icons.event_repeat_outlined,
                  formatRequestedDaysAndStart(l10n, request, proposal.startsOn),
                ),
            ],
          ),
          if (proposal != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: VanepInstallmentPrice(
                    amountCents: proposal.installmentAmountCents,
                    installments: proposal.installments,
                    amountStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: VanepColors.textPrimary,
                    ),
                    countStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: VanepColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ProposalStatusText(
                  text: formatProposalExpiry(l10n, proposal.validUntil, now),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (onChat != null) ...[
                Expanded(
                  child: VanepSecondaryButton(
                    label: l10n.clientProposalsChat,
                    icon: Icons.chat_bubble_outline,
                    onPressed: onChat,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: VanepPrimaryButton(
                  label: l10n.clientProposalsSeeProposal,
                  onPressed: onSeeProposal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
