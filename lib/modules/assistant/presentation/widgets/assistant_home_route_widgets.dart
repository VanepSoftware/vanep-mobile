import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/core/ui/vanep_swipe_to_confirm.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

// TODO(VAN-67): "Ligar p/ motorista" waits on the driver phone being exposed
// to the assistant (backend B6). Replace the call site and delete this
// function.
void openAssistantScreenNotBuiltYet() {}

class AssistantStopConfirmationCard extends StatefulWidget {
  const AssistantStopConfirmationCard({
    required this.link,
    required this.route,
    required this.stop,
    required this.isConfirming,
    required this.onConfirm,
    super.key,
  });

  final AssistantVanLink link;
  final AssistantRouteSnapshot route;
  final AssistantRouteStop stop;
  final bool isConfirming;
  final ValueChanged<Set<String>> onConfirm;

  @override
  State<AssistantStopConfirmationCard> createState() =>
      _AssistantStopConfirmationCardState();
}

class _AssistantStopConfirmationCardState
    extends State<AssistantStopConfirmationCard> {
  late Set<String> selectedTokens = allTokensToConfirm();

  Set<String> allTokensToConfirm() => {
    for (final passenger in widget.route.passengersToConfirmAt(widget.stop))
      passenger.token,
  };

  @override
  void didUpdateWidget(AssistantStopConfirmationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stop.token != widget.stop.token) {
      selectedTokens = allTokensToConfirm();
    }
  }

  void togglePassenger(String token, bool isSelected) {
    setState(() {
      isSelected ? selectedTokens.add(token) : selectedTokens.remove(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;
    final palette = context.palette;
    final languageCode = Localizations.localeOf(context).languageCode;
    final route = widget.route;
    final stop = widget.stop;
    final leg = stop.kind.leg;
    final isBoarding = stop.kind.isBoarding;
    final counts = route.boardingCountsOf(leg);
    final startedAt = route.startedAt;
    final toConfirm = route.passengersToConfirmAt(stop);
    final continuing = route.passengersContinuingAfter(stop);
    final count = selectedTokens.length;

    return VanepCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.assistantHomeOnRouteSince(
              firstNameOf(widget.link.van.driverName),
              tripLegLabel(l10n, leg),
              startedAt == null
                  ? ''
                  : formatClockTime(startedAt, languageCode: languageCode),
            ),
            style: typography.cardSubtitle,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  stopKindTitle(l10n, stop.kind),
                  style: typography.overline,
                ),
              ),
              Text(
                isBoarding
                    ? l10n.assistantHomeOnBoardOfTotal(
                        counts[BoardingStatus.boarded]!,
                        route.expectedPassengerCountOf(leg),
                      )
                    : l10n.assistantHomeOnBoard(
                        counts[BoardingStatus.boarded]!,
                      ),
                style: typography.ratingLabel,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                l10n.assistantHomeStopNumber(
                  route.currentStopNumber ?? 0,
                  route.stopCountOf(leg),
                ),
                style: typography.cardSubtitle,
              ),
              const Spacer(),
              VanepChip(
                label: stop.kind.isAtSchool
                    ? l10n.assistantHomeAtSchool
                    : l10n.assistantHomeVanArriving,
                background: palette.actionSurface,
                foreground: palette.action,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(stop.label, style: typography.pageTitle),
          if (!isBoarding) ...[
            const SizedBox(height: 4),
            Text(
              l10n.assistantHomeGettingOffHere(toConfirm.length),
              style: typography.body,
            ),
            if (continuing.isNotEmpty)
              Text(
                l10n.assistantHomeContinuingTo(
                  continuing.length,
                  joinFirstNames(l10n, [
                    for (final passenger in continuing) passenger.name,
                  ]),
                  continuing.first.schoolName,
                ),
                style: typography.cardSubtitle,
              ),
          ],
          const SizedBox(height: assistantHomeItemSpacing),
          Text(
            isBoarding
                ? l10n.assistantHomeDeselectNotBoarded
                : l10n.assistantHomeDeselectNotDroppedOff,
            style: typography.cardSubtitle,
          ),
          for (final passenger in toConfirm)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: selectedTokens.contains(passenger.token),
              onChanged: widget.isConfirming
                  ? null
                  : (isSelected) =>
                        togglePassenger(passenger.token, isSelected ?? false),
              secondary: VanepInitialAvatar(
                name: passenger.name,
                seed: passenger.token,
                size: 36,
              ),
              title: Text(passenger.name, style: typography.cardTitle),
              subtitle: Text(
                passenger.schoolName,
                style: typography.cardSubtitle,
              ),
            ),
          const SizedBox(height: 8),
          VanepSwipeToConfirm(
            label: l10n.assistantHomeSwipeToConfirm(count),
            semanticsLabel: isBoarding
                ? l10n.assistantHomeConfirmBoardingSemantics(count)
                : l10n.assistantHomeConfirmDropOffSemantics(count),
            isLoading: widget.isConfirming,
            onConfirmed: toConfirm.isEmpty
                ? null
                : () => widget.onConfirm({...selectedTokens}),
          ),
        ],
      ),
    );
  }
}

class AssistantOnBoardRow extends StatelessWidget {
  const AssistantOnBoardRow({
    required this.route,
    required this.onTap,
    super.key,
  });

  final AssistantRouteSnapshot route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final leg = route.currentLeg ?? TripLeg.outbound;
    final counts = route.boardingCountsOf(leg);

    return VanepCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: palette.successSurface,
            child: Icon(Icons.groups, color: palette.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.assistantHomeOnBoardRowTitle,
                  style: context.typography.cardTitle,
                ),
                Text(
                  l10n.assistantHomeOnBoardRowSubtitle(
                    counts[BoardingStatus.boarded]!,
                    route.expectedPassengerCountOf(leg),
                    counts[BoardingStatus.pending]!,
                  ),
                  style: context.typography.cardSubtitle,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: palette.textMuted),
        ],
      ),
    );
  }
}

class AssistantStopsPreview extends StatelessWidget {
  const AssistantStopsPreview({
    required this.title,
    required this.stops,
    required this.onSeeAll,
    super.key,
  });

  final String title;
  final List<AssistantRouteStop> stops;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final typography = context.typography;

    return VanepSection(
      title: title,
      actionLabel: l10n.assistantHomeSeeAll,
      onAction: onSeeAll,
      child: Column(
        children: [
          for (final stop in stops)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: stop.kind.isAtSchool
                  ? const Icon(Icons.school)
                  : CircleAvatar(
                      radius: 14,
                      child: Text(
                        '${stop.sequence}',
                        style: typography.ratingLabel,
                      ),
                    ),
              title: Text(stop.label, style: typography.cardTitle),
              subtitle: Text(
                stopPassengersLine(l10n, stop),
                style: typography.cardSubtitle,
              ),
              trailing: stop.plannedArrivalAt == null
                  ? null
                  : Text(
                      '~${formatClockTime(stop.plannedArrivalAt!, languageCode: languageCode)}',
                      style: typography.cardSubtitle,
                    ),
            ),
        ],
      ),
    );
  }
}

class AssistantNotGoingTodayList extends StatelessWidget {
  const AssistantNotGoingTodayList({
    required this.route,
    required this.now,
    super.key,
  });

  final AssistantRouteSnapshot route;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return VanepSection(
      title: l10n.assistantHomeNotGoingToday,
      child: Column(
        children: [
          for (final absence in route.todayAbsences)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: VanepInitialAvatar(
                name: absence.passengerName,
                seed: absence.passengerToken,
                size: 36,
              ),
              title: Text(
                absence.passengerName,
                style: context.typography.cardTitle,
              ),
              subtitle: Text(
                absenceNoticeLine(
                  l10n,
                  absence,
                  now: now,
                  languageCode: languageCode,
                ),
                style: context.typography.cardSubtitle,
              ),
            ),
        ],
      ),
    );
  }
}

class AssistantHomeShortcuts extends StatelessWidget {
  const AssistantHomeShortcuts({
    required this.isEnabled,
    required this.onOpenRoute,
    required this.onOpenAbsences,
    super.key,
  });

  final bool isEnabled;
  final VoidCallback onOpenRoute;
  final VoidCallback onOpenAbsences;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shortcuts = [
      (Icons.route, l10n.assistantHomeShortcutRoute, isEnabled, onOpenRoute),
      (
        Icons.event_busy,
        l10n.assistantHomeShortcutAbsences,
        isEnabled,
        onOpenAbsences,
      ),
      (
        Icons.call,
        l10n.assistantHomeShortcutCallDriver,
        false,
        openAssistantScreenNotBuiltYet,
      ),
    ];

    return VanepSection(
      title: l10n.assistantHomeShortcuts,
      child: Row(
        children: [
          for (final (index, (icon, label, enabled, onOpen))
              in shortcuts.indexed) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(
              child: AssistantShortcutTile(
                icon: icon,
                label: label,
                onTap: enabled ? onOpen : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AssistantShortcutTile extends StatelessWidget {
  const AssistantShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEnabled = onTap != null;
    final color = isEnabled ? palette.action : palette.textMuted;

    return Semantics(
      button: true,
      enabled: isEnabled,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.45,
        child: VanepCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.typography.ratingLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
