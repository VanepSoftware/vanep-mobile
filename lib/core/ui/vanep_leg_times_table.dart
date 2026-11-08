import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/formatters/schedule_labels.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/core/ui/vanep_link_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

const legTimesDayColumnWidth = 44.0;

const legTimesColumnGap = 12.0;

class VanepLegTimesTable extends StatelessWidget {
  const VanepLegTimesTable({
    required this.isEnabled,
    required this.timeOf,
    required this.onTimePicked,
    required this.onApplyToEveryDay,
    super.key,
  });

  final bool Function(Weekday weekday, RouteLeg leg) isEnabled;
  final ClockTime? Function(Weekday weekday, RouteLeg leg) timeOf;
  final void Function(Weekday weekday, RouteLeg leg, ClockTime time)
  onTimePicked;
  final void Function(RouteLeg leg, ClockTime time) onApplyToEveryDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weekdays = [
      for (final weekday in Weekday.values)
        if (RouteLeg.values.any((leg) => isEnabled(weekday, leg))) weekday,
    ];
    if (weekdays.isEmpty) return const SizedBox.shrink();
    final legs = [
      for (final leg in RouteLeg.values)
        if (weekdays.any((weekday) => isEnabled(weekday, leg))) leg,
    ];
    final firstTimes = {
      for (final leg in legs)
        leg: ?timeOf(
          weekdays.firstWhere((weekday) => isEnabled(weekday, leg)),
          leg,
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VanepLegTimesRow(
            leading: const SizedBox.shrink(),
            cells: [
              for (final leg in legs)
                Text(
                  routeLegLabel(l10n, leg),
                  textAlign: TextAlign.center,
                  style: VanepTypography.cardTitle,
                ),
            ],
          ),
          for (final weekday in weekdays)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: VanepLegTimesRow(
                leading: Text(
                  weekdayShortLabel(l10n, weekday),
                  style: VanepTypography.cardSubtitle,
                ),
                cells: [
                  for (final leg in legs)
                    if (isEnabled(weekday, leg))
                      VanepTimeButton(
                        semanticLabel: l10n.proposalComposerTimeLabel(
                          routeLegLabel(l10n, leg),
                          weekdayLabel(l10n, weekday),
                        ),
                        time: timeOf(weekday, leg),
                        onPicked: (time) => onTimePicked(weekday, leg, time),
                      )
                    else
                      Text(
                        '—',
                        textAlign: TextAlign.center,
                        style: VanepTypography.cardSubtitle.copyWith(
                          color: VanepColors.textMuted,
                        ),
                      ),
                ],
              ),
            ),
          if (weekdays.length > 1 && firstTimes.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: VanepLinkButton(
                label: l10n.proposalComposerApplyToAll,
                leadingIcon: Icons.copy_all_outlined,
                onPressed: () {
                  for (final MapEntry(key: leg, value: time)
                      in firstTimes.entries) {
                    onApplyToEveryDay(leg, time);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class VanepLegTimesRow extends StatelessWidget {
  const VanepLegTimesRow({
    required this.leading,
    required this.cells,
    super.key,
  });

  final Widget leading;
  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: legTimesDayColumnWidth, child: leading),
        for (final cell in cells) ...[
          const SizedBox(width: legTimesColumnGap),
          Expanded(child: cell),
        ],
      ],
    );
  }
}

TimeOfDay timeOfDayOf(ClockTime? time) {
  return time == null
      ? const TimeOfDay(hour: 7, minute: 0)
      : TimeOfDay(hour: time.hour, minute: time.minute);
}

class VanepTimeButton extends StatelessWidget {
  const VanepTimeButton({
    required this.semanticLabel,
    required this.time,
    required this.onPicked,
    super.key,
  });

  final String semanticLabel;
  final ClockTime? time;
  final ValueChanged<ClockTime> onPicked;

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: timeOfDayOf(time),
    );
    if (picked != null) {
      onPicked(ClockTime(hour: picked.hour, minute: picked.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final time = this.time;
    return Semantics(
      label: semanticLabel,
      value: time == null
          ? l10n.proposalComposerSetTime
          : formatClockTime(time),
      button: true,
      excludeSemantics: true,
      onTap: () => pickTime(context),
      child: OutlinedButton(
        onPressed: () => pickTime(context),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(72, 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: time == null
              ? VanepColors.action
              : VanepColors.textPrimary,
          side: const BorderSide(color: VanepColors.inputBorder),
        ),
        child: Text(
          time == null ? l10n.proposalComposerSetTime : formatClockTime(time),
          style: VanepTypography.cardSubtitle.copyWith(
            fontWeight: FontWeight.w700,
            color: time == null ? VanepColors.action : VanepColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
