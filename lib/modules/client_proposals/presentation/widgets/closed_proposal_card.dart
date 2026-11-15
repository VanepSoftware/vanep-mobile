import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

(Color, Color) outcomeChipColors(ClientTurn outcome) {
  return switch (outcome) {
    ClientTurn.accepted => (
      VanepColors.avatarGreenSurface,
      VanepColors.success,
    ),
    ClientTurn.expired => (VanepColors.warningSurface, VanepColors.warning),
    _ => (VanepColors.surface, VanepColors.textSecondary),
  };
}

class ClosedProposalCard extends StatelessWidget {
  const ClosedProposalCard({required this.request, super.key});

  final ClientServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: ProposalDriverHeader(
        request: request,
        subtitle: l10n.clientProposalsForChild(
          formatRequestChildren(l10n, request),
        ),
        trailing: ProposalOutcomeChip(outcome: clientTurnOf(request)),
      ),
    );
  }
}

class ProposalOutcomeChip extends StatelessWidget {
  const ProposalOutcomeChip({required this.outcome, super.key});

  final ClientTurn outcome;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = outcomeChipColors(outcome);
    return VanepChip(
      label: clientTurnLabel(AppLocalizations.of(context)!, outcome),
      background: background,
      foreground: foreground,
    );
  }
}
