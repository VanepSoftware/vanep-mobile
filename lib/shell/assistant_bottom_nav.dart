import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/ui/vanep_bottom_nav.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class AssistantBottomNav extends StatelessWidget {
  const AssistantBottomNav({
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
          icon: Icons.alt_route_outlined,
          selectedIcon: Icons.alt_route_rounded,
          label: l10n.navRoute,
        ),
        VanepNavItem(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups_rounded,
          label: l10n.navStudents,
        ),
        VanepNavItem(
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          label: l10n.navAssistantProfile,
        ),
      ],
    );
  }
}
