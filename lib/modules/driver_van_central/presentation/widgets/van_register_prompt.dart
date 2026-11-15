import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanRegisterPrompt extends StatelessWidget {
  const VanRegisterPrompt({required this.onRegisterVan, super.key});

  final VoidCallback onRegisterVan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepCard(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: VanepColors.brandNavy,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.airport_shuttle,
              size: 48,
              color: VanepColors.onBrand,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.vanCentralRegisterTitle,
            textAlign: TextAlign.center,
            style: context.typography.cardTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.vanCentralRegisterHint,
            textAlign: TextAlign.center,
            style: context.typography.cardSubtitle,
          ),
          const SizedBox(height: 18),
          VanepPrimaryButton(
            label: l10n.vanCentralRegisterAction,
            onPressed: onRegisterVan,
          ),
        ],
      ),
    );
  }
}
