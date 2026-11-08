import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/ui/vanep_schedule_editor.dart';
import 'package:vanep_mobile/core/ui/vanep_leg_times_table.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';

import 'localized_host.dart';

void main() {
  testWidgets('disabled legs cannot toggle and allowed legs toggle both ways', (
    tester,
  ) async {
    final toggled = <(RouteLeg, Weekday)>[];
    await tester.pumpWidget(
      localizedHost(
        VanepScheduleEditor(
          isAllowed: (day, leg) => day == Weekday.monday,
          isSelected: (day, leg) => leg == RouteLeg.outbound,
          timeOf: (_, _) => null,
          onToggled: (leg, day) => toggled.add((leg, day)),
          onTimePicked: (_, _, _) {},
          onApplyToEveryDay: (_, _) {},
        ),
      ),
    );
    final cells = tester
        .widgetList<WeekLegCellButton>(find.byType(WeekLegCellButton))
        .toList();
    expect(cells[1].cell.isEnabled, isFalse);
    await tester.tap(find.byType(WeekLegCellButton).at(1));
    await tester.tap(find.byType(WeekLegCellButton).at(0));
    await tester.tap(find.byType(WeekLegCellButton).at(5));
    expect(toggled, [
      (RouteLeg.outbound, Weekday.monday),
      (RouteLeg.homebound, Weekday.monday),
    ]);
    expect(find.byType(VanepTimeButton), findsOneWidget);
  });

  testWidgets('time button announces its day, leg, value and tap action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      localizedHost(
        VanepScheduleEditor(
          isAllowed: (day, leg) => day == Weekday.monday,
          isSelected: (day, leg) =>
              day == Weekday.monday && leg == RouteLeg.outbound,
          timeOf: (_, _) => const ClockTime(hour: 6, minute: 40),
          onToggled: (_, _) {},
          onTimePicked: (_, _, _) {},
          onApplyToEveryDay: (_, _) {},
        ),
      ),
    );
    final node = tester.getSemantics(find.byType(VanepTimeButton));
    expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(node.label.toLowerCase(), contains('segunda'));
    expect(node.label.toLowerCase(), contains('ida'));
    expect(node.value, '06:40');
    expect(find.byIcon(Icons.copy_all_outlined), findsNothing);
    semantics.dispose();
  });
  testWidgets(
    'multiple selected days share their first time through the editor',
    (tester) async {
      final applied = <(RouteLeg, ClockTime)>[];
      await tester.pumpWidget(
        localizedHost(
          VanepScheduleEditor(
            isAllowed: (_, _) => true,
            isSelected: (day, leg) =>
                [Weekday.monday, Weekday.tuesday].contains(day) &&
                leg == RouteLeg.outbound,
            timeOf: (_, _) => const ClockTime(hour: 6, minute: 40),
            onToggled: (_, _) {},
            onTimePicked: (_, _, _) {},
            onApplyToEveryDay: (leg, time) => applied.add((leg, time)),
          ),
        ),
      );
      expect(find.byType(VanepTimeButton), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.copy_all_outlined));
      expect(applied, [
        (RouteLeg.outbound, const ClockTime(hour: 6, minute: 40)),
      ]);
    },
  );
}
