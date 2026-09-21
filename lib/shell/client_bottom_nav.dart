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
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications_rounded,
          label: l10n.navNotifications,
        ),
        VanepNavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person_rounded,
          label: l10n.navProfile,
        ),
      ],
    );
  }
}
