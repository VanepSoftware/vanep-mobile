import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposal.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';

class SentRequestCard extends StatelessWidget {
  const SentRequestCard({required this.request, required this.now, super.key});

  final SentRequest request;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProposalPersonHeader(
            avatar: VanepPersonAvatar(name: request.driverName),
            name: request.driverName,
            subtitle: formatSentRequestSummary(l10n, request, now),
            trailing: ProposalStatusText(
              text: formatAnswerHoursLeft(l10n, request.answerBy, now),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: () => openUnavailableProposalAction(
                    context,
                    l10n.clientProposalsCancelRequest,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: VanepColors.danger,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 44),
                  ),
                  child: Text(
                    l10n.clientProposalsCancelRequest,
                    style: VanepTypography.linkAction.copyWith(
                      fontSize: 14,
                      color: VanepColors.danger,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton(
                  onPressed: () => openUnavailableProposalAction(
                    context,
                    l10n.clientProposalsSeeRequest,
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 44),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.clientProposalsSeeRequest,
                          style: VanepTypography.linkAction.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
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
