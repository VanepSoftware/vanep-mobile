import 'package:flutter/material.dart';

import '../core/design_system/vanep_colors.dart';
import '../core/ui/vanep_coming_soon.dart';
import '../l10n/app_localizations.dart';
import '../modules/auth/domain/entities/user_profile.dart';
import '../modules/auth/presentation/pages/profile_page.dart';
import '../modules/drivers/presentation/pages/drivers_home_tab.dart';
import 'client_bottom_nav.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<ClientShell> createState() => ClientShellState();
}

class ClientShellState extends State<ClientShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = widget.profile.name ?? widget.profile.email ?? '';

    return Scaffold(
      backgroundColor: VanepColors.surface,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          DriversHomeTab(displayName: displayName),
          VanepComingSoon(title: l10n.navVans, message: l10n.comingSoon),
          VanepComingSoon(
            title: l10n.navNotifications,
            message: l10n.comingSoon,
          ),
          ProfilePage(profile: widget.profile),
        ],
      ),
      bottomNavigationBar: ClientBottomNav(
        currentIndex: selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => selectedIndex = index),
      ),
    );
  }
}
