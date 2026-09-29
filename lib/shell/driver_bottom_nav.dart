import 'package:flutter/material.dart';

import '../core/ui/vanep_bottom_nav.dart';
import '../l10n/app_localizations.dart';

class DriverBottomNav extends StatelessWidget {
  const DriverBottomNav({
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
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment_rounded,
          label: l10n.navProposals,
        ),
        VanepNavItem(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups_rounded,
          label: l10n.navStudents,
        ),
      ],
    );
  }
}
