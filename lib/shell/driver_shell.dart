import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/onboarding_step.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_home_tab.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_vans_tab.dart';
import 'package:vanep_mobile/modules/driver_service_areas/presentation/widgets/service_areas_onboarding_banner.dart';
import 'package:vanep_mobile/shell/driver_bottom_nav.dart';
import 'package:vanep_mobile/shell/shell_account_drawer.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({
    required this.profile,
    required this.openServiceAreas,
    required this.openMyVans,
    super.key,
  });

  final UserProfile profile;

  final Future<void> Function(BuildContext context) openServiceAreas;

  final Future<void> Function(BuildContext context) openMyVans;

  @override
  State<DriverShell> createState() => DriverShellState();
}

class DriverShellState extends State<DriverShell> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  bool onboardingDismissed = false;

  bool get shouldOfferServiceAreas =>
      !onboardingDismissed &&
      widget.profile.pendingOnboardingSteps.contains(
        OnboardingStep.serviceArea,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = widget.profile.name ?? widget.profile.email ?? '';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VanepColors.surface,
      drawer: ShellAccountDrawer(profile: widget.profile),
      onDrawerChanged: (isOpened) => refreshAccountWhenDrawerOpens(
        context,
        widget.profile,
        isOpened: isOpened,
      ),
      body: Column(
        children: [
          if (shouldOfferServiceAreas)
            ServiceAreasOnboardingBanner(
              onStart: () => openServiceAreasAndRefreshProfile(context),
              onSkip: () => setState(() => onboardingDismissed = true),
            ),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                DriverHomeTab(
                  displayName: displayName,
                  onMenuTapped: () => scaffoldKey.currentState?.openDrawer(),
                  onNotificationsTapped: () => openNotifications(context),
                ),
                DriverVansTab(
                  onOpenMyVans: () => widget.openMyVans(context),
                  onOpenServiceAreas: () =>
                      openServiceAreasAndRefreshProfile(context),
                ),
                VanepComingSoon(
                  title: l10n.navProposalsAndContracts,
                  message: l10n.comingSoon,
                ),
                VanepComingSoon(
                  title: l10n.navStudents,
                  message: l10n.comingSoon,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: DriverBottomNav(
        currentIndex: selectedIndex,
        onDestinationSelected: selectShellTab,
      ),
    );
  }

  Future<void> openServiceAreasAndRefreshProfile(BuildContext context) async {
    await widget.openServiceAreas(context);
    if (!mounted) return;
    await this.context.read<AuthCubit>().refreshSessionProfile();
  }

  void selectShellTab(int index) {
    setState(() => selectedIndex = index);
  }
}
