import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';

class NegotiatingCard extends StatelessWidget {
  const NegotiatingCard({
    required this.section,
    required this.onSearchVansTapped,
    super.key,
  });

  final NegotiatingSection section;
  final VoidCallback onSearchVansTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: Column(
        children: [
          Row(
            children: [
              AvatarStack(names: section.childNames),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.clientHomeNoVanYet(
                        joinNames(l10n, section.childNames),
                      ),
                      style: VanepTypography.cardTitle,
                    ),
                    Text(
                      l10n.clientHomeOpenNegotiations(section.openNegotiations),
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: VanepSecondaryButton(
                  label: l10n.clientHomeSeeProposals,
                  onPressed: () => openUnavailableFeature(
                    context,
                    l10n.clientHomeShortcutProposals,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VanepSecondaryButton(
                  label: l10n.clientHomeSearchVans,
                  icon: Icons.search,
                  onPressed: onSearchVansTapped,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
