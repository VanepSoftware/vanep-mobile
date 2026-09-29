import 'package:flutter/material.dart';

import '../core/ui/vanep_bottom_nav.dart';
import '../l10n/app_localizations.dart';

class ClientBottomNav extends StatelessWidget {
  const ClientBottomNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepBottomNav(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      items: [
        VanepNavItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: l10n.navHome,
        ),
        VanepNavItem(
          icon: Icons.airport_shuttle_outlined,
          selectedIcon: Icons.airport_shuttle_rounded,
          label: l10n.navVans,
        ),
        VanepNavItem(
          icon: Icons.description_outlined,
          selectedIcon: Icons.description_rounded,
          label: l10n.navContracts,
        ),
        VanepNavItem(
          icon: Icons.family_restroom_outlined,
          selectedIcon: Icons.family_restroom_rounded,
          label: l10n.navDependents,
        ),
      ],
    );
  }
}
