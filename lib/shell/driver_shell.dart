import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/vanep_colors.dart';
import '../core/ui/vanep_coming_soon.dart';
import '../core/ui/vanep_coming_soon_page.dart';
import '../l10n/app_localizations.dart';
import '../modules/auth/domain/entities/user_profile.dart';
import '../modules/auth/domain/value_objects/onboarding_step.dart';
import '../modules/auth/presentation/cubit/auth_cubit.dart';
import '../modules/driver/domain/entities/driver_home_data.dart';
import '../modules/driver/presentation/pages/driver_home_tab.dart';
import '../modules/driver/presentation/widgets/driver_home_main_card.dart';
import '../modules/driver/presentation/pages/driver_vans_tab.dart';
import '../modules/driver_service_areas/presentation/widgets/service_areas_onboarding_banner.dart';
import 'driver_bottom_nav.dart';
import 'shell_account_drawer.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({
    required this.profile,
    required this.openServiceAreas,
    required this.openMyVans,
    this.homeNavigation,
    super.key,
  });

  final UserProfile profile;
  final DriverHomeNavigation? homeNavigation;

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
                  navigation:
                      widget.homeNavigation ??
                      _DriverShellHomeNavigation(
                        context: context,
                        onSelectTab: selectShellTab,
                      ),
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

class _DriverShellHomeNavigation implements DriverHomeNavigation {
  const _DriverShellHomeNavigation({
    required this.context,
    required this.onSelectTab,
  });

  static const int _studentsTabIndex = 3;

  final BuildContext context;
  final ValueChanged<int> onSelectTab;

  void _openComingSoon(String title) {
    openComingSoonPage(
      context,
      title: title,
      message: AppLocalizations.of(context)!.comingSoon,
    );
  }

  @override
  void openShortcut(Shortcut shortcut) {
    switch (shortcut) {
      case Shortcut.students:
        onSelectTab(_studentsTabIndex);
      case Shortcut.route:
        _openComingSoon('Rota e paradas');
      case Shortcut.absences:
        _openComingSoon('Ausências e ajustes');
      case Shortcut.financial:
        _openComingSoon('Financeiro');
      case Shortcut.assistants:
        _openComingSoon('Auxiliares');
      case Shortcut.documents:
        _openComingSoon('Documentos');
    }
  }

  @override
  void openRegularization() => _openComingSoon('Regularização');

  @override
  void correctAndResubmit() => openShortcut(Shortcut.documents);

  @override
  void openChecklist(String tripId) => _openComingSoon('Checklist');

  @override
  void callContact(String tripId) => _openComingSoon('Contato da parada');
}
