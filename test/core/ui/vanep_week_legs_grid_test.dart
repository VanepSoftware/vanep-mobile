import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';

import 'localized_host.dart';

enum TestLeg { outbound, homebound }

List<VanepWeekLegsRow<TestLeg>> rowsOn(
  List<Weekday> days, {
  Set<Weekday> homeboundOff = const {},
  Set<Weekday> homeboundNotAllowed = const {},
}) {
  return [
    VanepWeekLegsRow(
      leg: TestLeg.outbound,
      label: 'Ida',
      cells: {
        for (final day in days) day: const VanepWeekLegCell(isSelected: true),
      },
    ),
    VanepWeekLegsRow(
      leg: TestLeg.homebound,
      label: 'Volta',
      cells: {
        for (final day in days)
          day: VanepWeekLegCell(
            isSelected: !homeboundOff.contains(day),
            isEnabled: !homeboundNotAllowed.contains(day),
          ),
      },
    ),
  ];
}

Finder cellOf(String label) => find.bySemanticsLabel(label);

void main() {
  testWidgets('a read-only grid shows the week and each leg', (tester) async {
    await tester.pumpWidget(
      localizedHost(
        VanepWeekLegsGrid<TestLeg>(
          rows: rowsOn(
            weekdaysMondayToFriday,
            homeboundOff: {Weekday.wednesday},
          ),
        ),
      ),
    );

    for (final day in ['Seg', 'Ter', 'Qua', 'Qui', 'Sex']) {
      expect(find.text(day), findsOneWidget);
    }
    expect(find.text('Sáb'), findsNothing);
    expect(find.text('Ida'), findsOneWidget);
    expect(find.text('Volta'), findsOneWidget);
    expect(
      tester.getSemantics(cellOf('Quarta, Volta')),
      matchesSemantics(label: 'Quarta, Volta', hasToggledState: true),
    );
    expect(
      tester.getSemantics(cellOf('Quarta, Ida')),
      matchesSemantics(
        label: 'Quarta, Ida',
        hasToggledState: true,
        isToggled: true,
      ),
    );
  });

  testWidgets('an editable grid toggles the leg of the day tapped', (
    tester,
  ) async {
    final toggled = <(TestLeg, Weekday)>[];
    await tester.pumpWidget(
      localizedHost(
        VanepWeekLegsGrid<TestLeg>(
          rows: rowsOn(weekdaysMondayToFriday),
          onToggled: (leg, day) => toggled.add((leg, day)),
        ),
      ),
    );

    await tester.tap(cellOf('Quarta, Volta'));

    expect(toggled, [(TestLeg.homebound, Weekday.wednesday)]);
    expect(
      tester.getSemantics(cellOf('Quarta, Volta')),
      matchesSemantics(
        label: 'Quarta, Volta',
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isButton: true,
      ),
    );
  });

  testWidgets('a leg that is not allowed is disabled and ignores taps', (
    tester,
  ) async {
    final toggled = <(TestLeg, Weekday)>[];
    await tester.pumpWidget(
      localizedHost(
        VanepWeekLegsGrid<TestLeg>(
          rows: rowsOn(
            weekdaysMondayToFriday,
            homeboundOff: {Weekday.friday},
            homeboundNotAllowed: {Weekday.friday},
          ),
          onToggled: (leg, day) => toggled.add((leg, day)),
        ),
      ),
    );

    await tester.tap(cellOf('Sexta, Volta'), warnIfMissed: false);

    expect(toggled, isEmpty);
    expect(
      tester.getSemantics(cellOf('Sexta, Volta')),
      matchesSemantics(
        label: 'Sexta, Volta',
        hasToggledState: true,
        hasEnabledState: true,
        isButton: true,
      ),
    );
  });

  testWidgets('a weekday without a cell shows as not allowed', (tester) async {
    final toggled = <(TestLeg, Weekday)>[];
    await tester.pumpWidget(
      localizedHost(
        VanepWeekLegsGrid<TestLeg>(
          rows: rowsOn([Weekday.monday, Weekday.wednesday]),
          onToggled: (leg, day) => toggled.add((leg, day)),
        ),
      ),
    );

    expect(find.text('Ter'), findsOneWidget);
    await tester.tap(cellOf('Terça, Ida'), warnIfMissed: false);

    expect(toggled, isEmpty);
  });

  testWidgets('the weekend shows only when a leg falls on it', (tester) async {
    await tester.pumpWidget(
      localizedHost(
        VanepWeekLegsGrid<TestLeg>(
          rows: rowsOn([...weekdaysMondayToFriday, Weekday.saturday]),
        ),
      ),
    );

    expect(find.text('Sáb'), findsOneWidget);
    expect(find.text('Dom'), findsNothing);
  });
}
