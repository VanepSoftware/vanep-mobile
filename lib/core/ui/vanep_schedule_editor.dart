import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/formatters/schedule_labels.dart';
import 'package:vanep_mobile/core/ui/vanep_leg_times_table.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class VanepScheduleEditor extends StatelessWidget {
  const VanepScheduleEditor({
    required this.isAllowed,
    required this.isSelected,
    required this.timeOf,
    required this.onToggled,
    required this.onTimePicked,
    required this.onApplyToEveryDay,
    this.defaultTimeOf,
    this.onDefaultTimeChanged,
    this.layoutBuilder,
    super.key,
  });

  final bool Function(Weekday, RouteLeg) isAllowed;
  final bool Function(Weekday, RouteLeg) isSelected;
  final ClockTime? Function(Weekday, RouteLeg) timeOf;
  final void Function(RouteLeg, Weekday) onToggled;
  final void Function(Weekday, RouteLeg, ClockTime) onTimePicked;
  final void Function(RouteLeg, ClockTime) onApplyToEveryDay;
  final ClockTime Function(RouteLeg leg)? defaultTimeOf;
  final void Function(RouteLeg leg, ClockTime time)? onDefaultTimeChanged;
  final Widget Function(Widget days, Widget? times)? layoutBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool isEnabled(Weekday day, RouteLeg leg) =>
        isAllowed(day, leg) && isSelected(day, leg);
    final days = VanepWeekLegsGrid<RouteLeg>(
      rows: [
        for (final leg in RouteLeg.values)
          VanepWeekLegsRow(
            leg: leg,
            label: routeLegLabel(l10n, leg),
            cells: {
              for (final day in Weekday.values)
                if (weekdaysMondayToFriday.contains(day) || isAllowed(day, leg))
                  day: isAllowed(day, leg)
                      ? VanepWeekLegCell(isSelected: isSelected(day, leg))
                      : VanepWeekLegCell.notAllowed,
            },
          ),
      ],
      onToggled: onToggled,
    );
    final hasTimes = Weekday.values.any(
      (day) => RouteLeg.values.any((leg) => isEnabled(day, leg)),
    );
    final defaultTimeOf = this.defaultTimeOf;
    final onDefaultTimeChanged = this.onDefaultTimeChanged;
    final defaults = defaultTimeOf == null || onDefaultTimeChanged == null
        ? null
        : VanepDefaultLegTimes(
            timeOf: defaultTimeOf,
            onTimePicked: onDefaultTimeChanged,
          );
    final dayTimes = hasTimes
        ? VanepLegTimesTable(
            isEnabled: isEnabled,
            timeOf: timeOf,
            onTimePicked: onTimePicked,
            onApplyToEveryDay: onApplyToEveryDay,
          )
        : null;
    final times = defaults == null && dayTimes == null
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?defaults,
              if (defaults != null && dayTimes != null)
                const SizedBox(height: 16),
              ?dayTimes,
            ],
          );
    return layoutBuilder?.call(days, times) ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [days, ?times],
        );
  }
}
