import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/ui/vanep_coming_soon.dart';
import '../core/ui/vanep_screen_background.dart';
import '../l10n/app_localizations.dart';
import '../modules/auth/domain/entities/user_profile.dart';
import '../modules/auth/domain/value_objects/onboarding_step.dart';
import '../modules/auth/presentation/cubit/auth_cubit.dart';
import '../modules/auth/presentation/pages/profile_page.dart';
import '../modules/driver/presentation/pages/driver_home_tab.dart';
import '../modules/driverserviceareas/presentation/widgets/service_areas_onboarding_banner.dart';
import '../modules/profile/presentation/cubit/profile_summary_cubit.dart';
import '../modules/profile/presentation/formatters/assistant_status_label.dart';
import 'driver_bottom_nav.dart';

const driverShellProfileTabIndex = 3;

class DriverShell extends StatefulWidget {
  const DriverShell({
    required this.profile,
    required this.openServiceAreas,
    super.key,
  });

  final UserProfile profile;

  final Future<void> Function(BuildContext context) openServiceAreas;

  @override
  State<DriverShell> createState() => DriverShellState();
}

class DriverShellState extends State<DriverShell> {
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

    return VanepScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            if (shouldOfferServiceAreas)
              ServiceAreasOnboardingBanner(
                onStart: () => startServiceAreasOnboarding(context),
                onSkip: () => setState(() => onboardingDismissed = true),
              ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  DriverHomeTab(displayName: displayName),
                  VanepComingSoon(
                    title: l10n.navProposals,
                    message: l10n.comingSoon,
                  ),
                  VanepComingSoon(
                    title: l10n.navStudents,
                    message: l10n.comingSoon,
                  ),
                  BlocBuilder<ProfileSummaryCubit, ProfileSummaryState>(
                    builder: (context, summaryState) {
                      return ProfilePage(
                        profile: widget.profile,
                        photoUrl: summaryState.photoUrl,
                        rating: summaryState.rating,
                        city: summaryState.city,
                        statusLabel: assistantStatusLabel(
                          l10n,
                          summaryState.assistantStatus,
                        ),
                        statusColor: assistantStatusColor(
                          summaryState.assistantStatus,
                        ),
                        onRefresh: refreshProfileTab,
                      );
                    },
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
      ),
    );
  }

  Future<void> startServiceAreasOnboarding(BuildContext context) async {
    await widget.openServiceAreas(context);
    if (!mounted) return;
    await this.context.read<AuthCubit>().refreshSessionProfile();
  }

  void selectShellTab(int index) {
    setState(() => selectedIndex = index);
    if (index != driverShellProfileTabIndex) return;
    refreshProfileTab();
  }

  Future<void> refreshProfileTab() {
    return Future.wait<void>([
      context.read<AuthCubit>().refreshSessionProfile(),
      context.read<ProfileSummaryCubit>().refresh(widget.profile.type),
    ]);
  }
}
