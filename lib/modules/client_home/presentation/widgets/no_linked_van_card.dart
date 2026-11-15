import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
            decoration: BoxDecoration(
              color: context.palette.actionSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.airport_shuttle_outlined,
              color: context.palette.action,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.clientHomeNoLinkedVanTitle,
            style: context.typography.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.clientHomeNoLinkedVanMessage,
            style: context.typography.cardSubtitle,
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
