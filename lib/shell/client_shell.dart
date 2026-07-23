import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/vanep_colors.dart';
import '../core/ui/vanep_coming_soon.dart';
import '../l10n/app_localizations.dart';
import '../modules/auth/domain/entities/user_profile.dart';
import '../modules/auth/presentation/pages/profile_page.dart';
import '../modules/drivers/presentation/pages/drivers_home_tab.dart';
import '../modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'client_bottom_nav.dart';

const clientShellProfileTabIndex = 3;

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
          BlocBuilder<ProfileSummaryCubit, ProfileSummaryState>(
            builder: (context, summaryState) {
              return ProfilePage(
                profile: widget.profile,
                photoUrl: summaryState.photoUrl,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: ClientBottomNav(
        currentIndex: selectedIndex,
        onDestinationSelected: selectShellTab,
      ),
    );
  }

  void selectShellTab(int index) {
    setState(() => selectedIndex = index);
    if (index != clientShellProfileTabIndex) return;
    context.read<ProfileSummaryCubit>().loadSummaryIfNeeded(
      widget.profile.type,
    );
  }
}
