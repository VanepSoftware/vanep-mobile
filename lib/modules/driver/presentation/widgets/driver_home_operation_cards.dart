import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/driver_home_localizations.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_main_card.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_primitives.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/slide_stop_confirmation.dart';

// TODO(VAN-66): Show departure time, stop/absence counts and the assigned assistant once the
// driver trip summary endpoint returns them. Until then only DriverHomeData values are rendered.
class DriverBeforeDepartureCard extends StatelessWidget {
  const DriverBeforeDepartureCard({
    required this.data,
    required this.navigation,
    required this.enabled,
    required this.sharingLocation,
    this.onLocationSharingChanged,
    this.onStartRoute,
    super.key,
  });

  final DriverHomeData data;
  final DriverHomeNavigation navigation;
  final bool enabled;
  final bool sharingLocation;
  final ValueChanged<bool>? onLocationSharingChanged;
  final VoidCallback? onStartRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trip = data.todayTrip!;
    return DriverNavyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Semantics(
                  label: l10n.driverHomeBeforeDeparture,
                  child: Text(
                    l10n
                        .driverHomeTripShiftOverline(
                          localizeDriverShift(l10n, trip.label),
                        )
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.72,
                      color: Color(0xFF8EC5FF),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: enabled ? () => navigation.openChecklist(trip.id) : null,
                borderRadius: BorderRadius.circular(DriverHomeTokens.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    l10n.driverHomeChecklist,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8EC5FF),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.driverHomeBeforeDeparture,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          DriverNavyStatBox(
            value: '${data.studentCount}',
            label: l10n.driverHomeStatActiveStudents,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
              border: Border.all(color: const Color(0x24FFFFFF)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.my_location_outlined,
                  color: Color(0xFF8EC5FF),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.driverHomeLocationTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10n.driverHomeLocationSubtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xB3FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: sharingLocation,
                  onChanged: onLocationSharingChanged,
                  activeThumbColor: DriverHomeTokens.brand,
                  activeTrackColor: const Color(0xFF8EC5FF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            label: l10n.driverHomeStartRoute,
            child: DriverStartRouteSlideButton(
              label: l10n.driverHomeSlideToStartRoute,
              enabled: enabled && onStartRoute != null,
              onTrigger: () => onStartRoute?.call(),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverNavyStatBox extends StatelessWidget {
  const DriverNavyStatBox({
    required this.value,
    required this.label,
    super.key,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0x17FFFFFF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x24FFFFFF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xB8FFFFFF),
          ),
        ),
      ],
    ),
  );
}

// TODO(VAN-66): Show on-board progress, stop address and ETA once the active trip tracking
// endpoint provides them. The next-stop block only renders when the API supplies nextConfirmation.
class DriverInProgressCard extends StatelessWidget {
  const DriverInProgressCard({
    required this.data,
    required this.navigation,
    required this.enabled,
    this.onConfirmStop,
    super.key,
  });

  final DriverHomeData data;
  final DriverHomeNavigation navigation;
  final bool enabled;
  final Future<void> Function(StopConfirmation confirmation)? onConfirmStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trip = data.todayTrip!;
    final next = data.nextConfirmation;
    return DriverNavyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8EC5FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n
                        .driverHomeInProgressShiftOverline(
                          localizeDriverShift(l10n, trip.label),
                        )
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.72,
                      color: Color(0xFF8EC5FF),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.my_location_outlined,
                    size: 16,
                    color: Color(0xD9FFFFFF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.driverHomeParentsSeeVan,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xD9FFFFFF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: enabled ? () => navigation.openChecklist(trip.id) : null,
              child: Text(
                l10n.driverHomeChecklist,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8EC5FF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (next != null) ...[
                  Text(
                    l10n.driverHomeNextStopLabel.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.66,
                      color: DriverHomeTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    next.studentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DriverHomeTokens.textPrimary,
                      letterSpacing: -0.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SlideStopConfirmation(
                    key: ValueKey((
                      next.tripId,
                      next.stopId,
                      next.studentId,
                      next.action,
                    )),
                    confirmation: next,
                    enabled: enabled && onConfirmStop != null,
                    onConfirmed: () => onConfirmStop!(next),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DriverHomeTokens.textPrimary,
                            side: const BorderSide(
                              color: DriverHomeTokens.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: enabled
                              ? () => navigation.openShortcut(Shortcut.absences)
                              : null,
                          icon: const Icon(
                            Icons.person_off_outlined,
                            size: 18,
                            color: DriverHomeTokens.textPrimary,
                          ),
                          label: Text(
                            l10n.driverHomeExceptionAction,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DriverHomeTokens.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DriverHomeTokens.textPrimary,
                            side: const BorderSide(
                              color: DriverHomeTokens.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: enabled
                              ? () => navigation.openShortcut(Shortcut.route)
                              : null,
                          icon: const Icon(
                            Icons.navigation_outlined,
                            size: 18,
                            color: DriverHomeTokens.textPrimary,
                          ),
                          label: Text(
                            l10n.driverHomeWazeAction,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DriverHomeTokens.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (data.contactLabel != null) ...[
                  const SizedBox(height: 8),
                  VanepSecondaryButton(
                    label: l10n.driverHomeCall(data.contactLabel!),
                    onPressed: enabled
                        ? () => navigation.callContact(trip.id)
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TODO(VAN-66): Show end time, delivered students and duration KPIs once the completed trip
// summary endpoint returns them.
class DriverShiftCompletedCard extends StatelessWidget {
  const DriverShiftCompletedCard({
    required this.data,
    required this.navigation,
    super.key,
  });

  final DriverHomeData data;
  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shift = data.todayTrip == null
        ? null
        : localizeDriverShift(l10n, data.todayTrip!.label);
    final nextShiftLabel = data.laterShiftLabel == null
        ? null
        : l10n.driverHomeNextShift(
            localizeDriverShift(l10n, data.laterShiftLabel!),
          );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FAF5),
        borderRadius: BorderRadius.circular(DriverHomeTokens.radiusLg),
        border: Border.all(color: const Color(0xFFC6E6D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: DriverHomeTokens.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.done_all,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (shift != null) ...[
                      Text(
                        shift.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.72,
                          color: DriverHomeTokens.success,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      l10n.driverHomeCompleted,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: DriverHomeTokens.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (nextShiftLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        nextShiftLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: DriverHomeTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => navigation.openShortcut(Shortcut.route),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.driverHomeSeeTripReport,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DriverHomeTokens.action,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: DriverHomeTokens.action,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TODO(VAN-66): Show the next scheduled operating day once the driver calendar endpoint
// returns it.
class DriverNoRouteTodayCard extends StatelessWidget {
  const DriverNoRouteTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverHomeTokens.surface,
        borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
        border: Border.all(color: DriverHomeTokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: DriverHomeTokens.actionSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.weekend_outlined,
              color: DriverHomeTokens.action,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverHomeNoRouteTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: DriverHomeTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TODO(VAN-66): Show the open invoice amount and due date once the driver billing endpoint
// provides them.
class DriverBlockedCard extends StatelessWidget {
  const DriverBlockedCard({
    required this.data,
    required this.navigation,
    super.key,
  });

  final DriverHomeData data;
  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3F1),
        borderRadius: BorderRadius.circular(DriverHomeTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEFC9C3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: DriverHomeTokens.danger,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card_off_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: l10n.driverHomeBlockedTitle,
                      child: Text(
                        l10n.driverHomeBlockedTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.72,
                          color: DriverHomeTokens.danger,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.driverHomeBlockedHeadline,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: DriverHomeTokens.textPrimary,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.blockReason.localize(l10n),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: DriverHomeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          VanepPrimaryButton(
            label: l10n.driverHomeRegularize,
            onPressed: navigation.openRegularization,
          ),
          if (data.subscriptionBlocked) ...[
            const SizedBox(height: 8),
            VanepSecondaryButton(
              label: l10n.driverHomeSeeInvoice,
              onPressed: navigation.openRegularization,
            ),
          ],
        ],
      ),
    );
  }
}
