import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';

class DriverInviteRow extends StatelessWidget {
  const DriverInviteRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HomeRowsCard(
      rows: [
        HomeRowTile(
          leading: const HomeIconBubble(icon: Icons.mark_email_unread_outlined),
          title: l10n.clientHomeDriverInviteTitle,
          subtitle: l10n.clientHomeDriverInviteMessage,
          onTap: () =>
              openUnavailableFeature(context, l10n.clientHomeDriverInviteTitle),
        ),
      ],
    );
  }
}

class HowVanepWorksStep {
  const HowVanepWorksStep({
    required this.icon,
    required this.title,
    required this.hint,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String hint;
  final bool highlighted;
}

List<HowVanepWorksStep> howVanepWorksSteps(AppLocalizations l10n) => [
  HowVanepWorksStep(
    icon: Icons.send_outlined,
    title: l10n.clientHomeHowItWorksRequest,
    hint: l10n.clientHomeHowItWorksRequestHint,
  ),
  HowVanepWorksStep(
    icon: Icons.request_quote_outlined,
    title: l10n.clientHomeHowItWorksProposal,
    hint: l10n.clientHomeHowItWorksProposalHint,
  ),
  HowVanepWorksStep(
    icon: Icons.draw_outlined,
    title: l10n.clientHomeHowItWorksContract,
    hint: l10n.clientHomeHowItWorksContractHint,
  ),
  HowVanepWorksStep(
    icon: Icons.near_me_outlined,
    title: l10n.clientHomeHowItWorksLive,
    hint: l10n.clientHomeHowItWorksLiveHint,
    highlighted: true,
  ),
];

class HowVanepWorksCard extends StatelessWidget {
  const HowVanepWorksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: Column(
        children: [
          for (final step in howVanepWorksSteps(l10n))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeIconBubble(
                    icon: step.icon,
                    size: 32,
                    background: step.highlighted
                        ? VanepColors.warningSurface
                        : VanepColors.actionSurface,
                    foreground: step.highlighted
                        ? VanepColors.warning
                        : VanepColors.action,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: VanepTypography.cardTitle.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        Text(step.hint, style: VanepTypography.cardSubtitle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
