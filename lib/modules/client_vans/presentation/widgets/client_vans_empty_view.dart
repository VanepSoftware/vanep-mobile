import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class ClientVansEmptyView extends StatelessWidget {
  const ClientVansEmptyView({
    required this.onFindVanTapped,
    super.key,
  });

  final VoidCallback onFindVanTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.palette.actionSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.airport_shuttle_outlined,
              color: context.palette.action,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.clientVansEmptyTitle,
            style: context.typography.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.clientVansEmptyMessage,
            style: context.typography.cardSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          VanepPrimaryButton(
            label: l10n.clientVansFindVanButton,
            onPressed: onFindVanTapped,
          ),
        ],
      ),
    );
  }
}
