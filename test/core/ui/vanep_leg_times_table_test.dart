import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/ui/vanep_leg_times_table.dart';

import 'localized_host.dart';

const morning = ClockTime(hour: 6, minute: 40);

Widget tableOf({
  required Set<(Weekday, RouteLeg)> enabled,
  Map<(Weekday, RouteLeg), ClockTime> times = const {},
  void Function(Weekday, RouteLeg, ClockTime)? onTimePicked,
  void Function(RouteLeg, ClockTime)? onApplyToEveryDay,
}) {
  return localizedHost(
    VanepLegTimesTable(
      isEnabled: (weekday, leg) => enabled.contains((weekday, leg)),
      timeOf: (weekday, leg) => times[(weekday, leg)],
      onTimePicked: onTimePicked ?? (_, _, _) {},
      onApplyToEveryDay: onApplyToEveryDay ?? (_, _) {},
    ),
  );
}

void main() {
  testWidgets('shows nothing without an enabled leg', (tester) async {
    await tester.pumpWidget(tableOf(enabled: const {}));

    expect(find.byType(VanepTimeButton), findsNothing);
  });

  testWidgets('one time button per enabled leg and a dash elsewhere', (
    tester,
  ) async {
    await tester.pumpWidget(
      tableOf(
        enabled: const {
          (Weekday.monday, RouteLeg.outbound),
          (Weekday.monday, RouteLeg.homebound),
          (Weekday.tuesday, RouteLeg.outbound),
        },
        times: const {(Weekday.monday, RouteLeg.outbound): morning},
      ),
    );

    expect(find.byType(VanepTimeButton), findsNWidgets(3));
    expect(find.text('06:40'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Seg'), findsOneWidget);
    expect(find.text('Ter'), findsOneWidget);
  });

  testWidgets('applying to every day sends the first day time of each leg', (
    tester,
  ) async {
    final applied = <(RouteLeg, ClockTime)>[];
    await tester.pumpWidget(
      tableOf(
        enabled: const {
          (Weekday.monday, RouteLeg.outbound),
          (Weekday.tuesday, RouteLeg.outbound),
        },
        times: const {(Weekday.monday, RouteLeg.outbound): morning},
        onApplyToEveryDay: (leg, time) => applied.add((leg, time)),
      ),
    );

    await tester.tap(find.byIcon(Icons.copy_all_outlined));

    expect(applied, [(RouteLeg.outbound, morning)]);
  });

  testWidgets('a single day has no apply to every day', (tester) async {
    await tester.pumpWidget(
      tableOf(
        enabled: const {(Weekday.monday, RouteLeg.outbound)},
        times: const {(Weekday.monday, RouteLeg.outbound): morning},
      ),
    );

    expect(find.byIcon(Icons.copy_all_outlined), findsNothing);
  });

  testWidgets('picking a time reports the day and the leg', (tester) async {
    final picked = <(Weekday, RouteLeg, ClockTime)>[];
    await tester.pumpWidget(
      tableOf(
        enabled: const {(Weekday.monday, RouteLeg.outbound)},
        times: const {(Weekday.monday, RouteLeg.outbound): morning},
        onTimePicked: (weekday, leg, time) => picked.add((weekday, leg, time)),
      ),
    );

    await tester.tap(find.text('06:40'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(picked, [(Weekday.monday, RouteLeg.outbound, morning)]);
  });
}
