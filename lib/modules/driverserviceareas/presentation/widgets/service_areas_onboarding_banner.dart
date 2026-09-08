import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_glass_card.dart';
import '../../../../l10n/app_localizations.dart';

class ServiceAreasOnboardingBanner extends StatelessWidget {
  const ServiceAreasOnboardingBanner({
    required this.onStart,
    required this.onSkip,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: VanepGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.serviceAreasOnboardingTitle,
              style: VanepTypography.cardTitle,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.serviceAreasOnboardingBody,
              style: VanepTypography.cardSubtitle,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: Text(l10n.serviceAreasOnboardingSkip),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onStart,
                  child: Text(l10n.serviceAreasOnboardingStart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
