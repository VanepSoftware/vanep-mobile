import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';

class AwaitingRequestCard extends StatelessWidget {
  const AwaitingRequestCard({
    required this.request,
    required this.now,
    required this.onCancel,
    required this.onSeeRequest,
    required this.onSeeProposal,
    this.isCancelling = false,
    super.key,
  });

  final ClientServiceRequest request;
  final DateTime now;
  final VoidCallback onCancel;
  final VoidCallback onSeeRequest;
  final VoidCallback onSeeProposal;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proposal = request.currentProposal;
    final isAdjustment =
        clientTurnOf(request) == ClientTurn.adjustmentRequested &&
        proposal != null;

    return VanepCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProposalDriverHeader(
            request: request,
            subtitle: isAdjustment
                ? clientTurnLabel(l10n, ClientTurn.adjustmentRequested)
                : formatSentRequestSummary(l10n, request, now),
            trailing: ProposalStatusText(
              text: isAdjustment
                  ? formatProposalExpiry(l10n, proposal.validUntil, now)
                  : formatAnswerHoursLeft(l10n, request.expiresAt, now),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: isAdjustment
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!isAdjustment) ...[
                Flexible(
                  child: ProposalLinkButton(
                    label: l10n.clientProposalsCancelRequest,
                    color: VanepColors.danger,
                    onPressed: isCancelling ? null : onCancel,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: ProposalLinkButton(
                  label: isAdjustment
                      ? l10n.clientProposalsSeeProposal
                      : l10n.clientProposalsSeeRequest,
                  showsChevron: true,
                  onPressed: isAdjustment ? onSeeProposal : onSeeRequest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
