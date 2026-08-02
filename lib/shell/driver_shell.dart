import 'package:flutter/material.dart';

import '../core/ui/vanep_coming_soon.dart';
import '../core/ui/vanep_screen_background.dart';
import '../l10n/app_localizations.dart';
import '../modules/auth/domain/entities/user_profile.dart';
import '../modules/driver/presentation/pages/driver_home_tab.dart';
import 'driver_bottom_nav.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<DriverShell> createState() => DriverShellState();
}

class DriverShellState extends State<DriverShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = widget.profile.name ?? widget.profile.email ?? '';

    return VanepScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: selectedIndex,
          children: [
            DriverHomeTab(displayName: displayName),
            VanepComingSoon(title: l10n.navProposals, message: l10n.comingSoon),
            VanepComingSoon(title: l10n.navStudents, message: l10n.comingSoon),
            VanepComingSoon(title: l10n.navProfile, message: l10n.comingSoon),
          ],
        ),
        bottomNavigationBar: DriverBottomNav(
          currentIndex: selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => selectedIndex = index),
        ),
      ),
    );
  }
}
