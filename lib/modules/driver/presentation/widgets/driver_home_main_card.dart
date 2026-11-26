import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_onboarding_cards.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_operation_cards.dart';

abstract interface class DriverHomeNavigation {
  void openShortcut(Shortcut shortcut);
  void openRegularization();
  void correctAndResubmit();
  void openChecklist(String tripId);
  void callContact(String tripId);
}

class DriverHomeMainCard extends StatelessWidget {
  const DriverHomeMainCard({
    super.key,
    required this.data,
    required this.phase,
    required this.navigation,
    required this.enabled,
    this.sharingLocation = false,
    this.onLocationSharingChanged,
    this.onStartRoute,
    this.onConfirmStop,
  });

  final DriverHomeData data;
  final HomePhase phase;
  final DriverHomeNavigation navigation;
  final bool enabled;
  final bool sharingLocation;
  final ValueChanged<bool>? onLocationSharingChanged;
  final VoidCallback? onStartRoute;
  final Future<void> Function(StopConfirmation confirmation)? onConfirmStop;

  @override
  Widget build(BuildContext context) => switch (phase) {
    HomePhase.incomplete => VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverIncompleteCard(navigation: navigation),
    ),
    HomePhase.underReview => VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverUnderReviewCard(navigation: navigation),
    ),
    HomePhase.rejected => VanepCard(
      isError: true,
      padding: const EdgeInsets.all(20),
      child: DriverRejectedCard(data: data, navigation: navigation),
    ),
    HomePhase.buildingRoute => VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverBuildingRouteCard(navigation: navigation),
    ),
    HomePhase.beforeDeparture => VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverBeforeDepartureCard(
        data: data,
        navigation: navigation,
        enabled: enabled,
        sharingLocation: sharingLocation,
        onLocationSharingChanged: onLocationSharingChanged,
        onStartRoute: onStartRoute,
      ),
    ),
    HomePhase.inProgress => VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverInProgressCard(
        data: data,
        navigation: navigation,
        enabled: enabled,
        onConfirmStop: onConfirmStop,
      ),
    ),
    HomePhase.shiftCompleted => VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverShiftCompletedCard(data: data, navigation: navigation),
    ),
    HomePhase.noRouteToday => const VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverNoRouteTodayCard(),
    ),
    HomePhase.blocked => VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverBlockedCard(data: data, navigation: navigation),
    ),
  };
}
