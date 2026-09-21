import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_card.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';

class NoLinkedVanCard extends StatelessWidget {
  const NoLinkedVanCard({required this.onFindVanTapped, super.key});

  final VoidCallback onFindVanTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: VanepColors.actionSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.airport_shuttle_outlined,
              color: VanepColors.action,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.clientHomeNoLinkedVanTitle,
            style: VanepTypography.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.clientHomeNoLinkedVanMessage,
            style: VanepTypography.cardSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          VanepPrimaryButton(
            label: l10n.clientHomeFindVanButton,
            onPressed: onFindVanTapped,
          ),
        ],
      ),
    );
  }
}
