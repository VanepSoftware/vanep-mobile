import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_menu_card.dart';
import '../../../../l10n/app_localizations.dart';

class DriverVansTab extends StatelessWidget {
  const DriverVansTab({required this.onOpenServiceAreas, super.key});

  final VoidCallback onOpenServiceAreas;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(l10n.navVans, style: VanepTypography.pageTitle),
          const SizedBox(height: 20),
          VanepMenuCard(
            items: [
              VanepMenuItem(
                label: l10n.driverVansMyVans,
                icon: Icons.airport_shuttle_outlined,
                enabled: false,
              ),
              VanepMenuItem(
                label: l10n.serviceAreasTitle,
                icon: Icons.map_outlined,
                onTap: onOpenServiceAreas,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
