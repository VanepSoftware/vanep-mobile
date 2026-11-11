import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/presentation/driver_home_localizations.dart';
import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/slide_stop_confirmation.dart';

// Destinos do card são injetados pela navegação; regras ficam no domínio.
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
  });
  final DriverHomeData data;
  final HomePhase phase;
  final DriverHomeCubit cubit;
  final DriverHomeNavigation navigation;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trip = data.todayTrip;
    final (title, description) = switch (phase) {
      HomePhase.blocked => (
        l10n.driverHomeBlockedTitle,
        data.blockReason.localize(l10n),
      ),
      HomePhase.incomplete => (
        l10n.driverHomeIncompleteTitle,
        l10n.driverHomeIncompleteDescription,
      ),
      HomePhase.underReview => (
        l10n.driverHomeReviewTitle,
        l10n.driverHomeReviewDescription,
      ),
      HomePhase.rejected => (
        l10n.driverHomeRejectedTitle,
        data.rejectionReason ?? l10n.driverHomeRejectedDescription,
      ),
      HomePhase.inProgress => (
        l10n.driverHomeInProgress,
        localizeDriverShift(l10n, trip!.label),
      ),
      HomePhase.beforeDeparture => (
        l10n.driverHomeBeforeDeparture,
        localizeDriverShift(l10n, trip!.label),
      ),
      HomePhase.shiftCompleted => (
        l10n.driverHomeCompleted,
        l10n.driverHomeNextShift(
          localizeDriverShift(l10n, data.laterShiftLabel!),
        ),
      ),
      HomePhase.buildingRoute => (
        l10n.driverHomeBuildingTitle,
        l10n.driverHomeBuildingDescription,
      ),
      HomePhase.noRouteToday => (
        l10n.driverHomeNoRouteTitle,
        l10n.driverHomeNoRouteDescription,
      ),
    };
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(description),
        const SizedBox(height: 16),
        ...switch (phase) {
          HomePhase.blocked => <Widget>[
            VanepPrimaryButton(
              label: l10n.driverHomeRegularize,
              onPressed: navigation.openRegularization,
            ),
          ],
          HomePhase.incomplete => <Widget>[
            VanepPrimaryButton(
              label: l10n.driverHomeCompleteRegistration,
              onPressed: () => navigation.openShortcut(Shortcut.documents),
            ),
          ],
          HomePhase.rejected => <Widget>[
            VanepPrimaryButton(
              label: l10n.driverHomeResubmit,
              onPressed: navigation.correctAndResubmit,
            ),
          ],
          HomePhase.beforeDeparture => <Widget>[
            VanepSecondaryButton(
              label: l10n.driverHomeChecklist,
              onPressed: enabled
                  ? () => navigation.openChecklist(trip!.id)
                  : null,
            ),
            const SizedBox(height: 8),
            VanepPrimaryButton(
              label: l10n.driverHomeStartRoute,
              onPressed: enabled ? cubit.startRoute : null,
            ),
          ],
          HomePhase.inProgress => <Widget>[
            VanepSecondaryButton(
              label: l10n.driverHomeChecklist,
              onPressed: enabled
                  ? () => navigation.openChecklist(trip!.id)
                  : null,
            ),
            if (data.contactLabel != null) ...[
              const SizedBox(height: 8),
              VanepSecondaryButton(
                label: l10n.driverHomeCall(data.contactLabel!),
                onPressed: enabled
                    ? () => navigation.callContact(trip!.id)
                    : null,
              ),
            ],
            if (data.nextConfirmation case final StopConfirmation next) ...[
              const SizedBox(height: 16),
              SlideStopConfirmation(
                key: ValueKey((
                  next.tripId,
                  next.stopId,
                  next.studentId,
                  next.action,
                )),
                confirmation: next,
                enabled: enabled,
                onConfirmed: () => cubit.confirmBySlide(next),
              ),
            ],
          ],
          HomePhase.buildingRoute => <Widget>[
            VanepPrimaryButton(
              label: l10n.driverHomeAddStudents,
              onPressed: () => navigation.openShortcut(Shortcut.students),
            ),
          ],
          _ => <Widget>[],
        },
      ],
    );
    return VanepCard(isError: phase == HomePhase.rejected, child: content);
  }
}
