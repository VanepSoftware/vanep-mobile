import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
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
    required this.cubit,
    required this.navigation,
    required this.enabled,
    this.sharingLocation = false,
  });

  final DriverHomeData data;
  final HomePhase phase;
  final DriverHomeCubit cubit;
  final DriverHomeNavigation navigation;
  final bool enabled;
  final bool sharingLocation;

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
        cubit: cubit,
        navigation: navigation,
        enabled: enabled,
        sharingLocation: sharingLocation,
      ),
    ),
    HomePhase.inProgress => VanepCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.transparent,
      child: DriverInProgressCard(
        data: data,
        cubit: cubit,
        navigation: navigation,
        enabled: enabled,
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
