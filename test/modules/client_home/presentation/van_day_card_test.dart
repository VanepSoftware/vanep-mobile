import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/van_day_cards.dart';

import '../../../core/ui/localized_harness.dart';

VanDay apiVan({
  String? vehicleModel = 'Sprinter',
  String? plate = 'SDF4E21',
  VanSchedule schedule = const VanSchedule(),
}) {
  return VanDay(
    driverName: 'Carlos',
    vehicleModel: vehicleModel,
    plate: plate,
    shift: SchoolShift.morning,
    departureAt: DateTime(2027, 3, 1, 6, 20),
    riders: const [VanRider(name: 'Ana')],
    schedule: schedule,
  );
}

void main() {
  Future<void> pump(WidgetTester tester, VanDay van) {
    return tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: SingleChildScrollView(child: VanDayCard(van: van)),
        ),
      ),
    );
  }

  testWidgets('shows a dash for the school arrival the API does not know', (
    tester,
  ) async {
    await pump(
      tester,
      apiVan(
        schedule: VanSchedule(
          boardingStartAt: DateTime(2027, 3, 1, 6, 40),
          boardingEndAt: DateTime(2027, 3, 1, 6, 50),
          schoolDepartureAt: DateTime(2027, 3, 1, 12, 30),
        ),
      ),
    );

    expect(find.text('Chegada'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.textContaining('Sprinter SDF4E21'), findsOneWidget);
  });

  testWidgets('a boarding window is joined by an en dash', (tester) async {
    await pump(
      tester,
      apiVan(
        schedule: VanSchedule(
          boardingStartAt: DateTime(2027, 3, 1, 6, 40),
          boardingEndAt: DateTime(2027, 3, 1, 6, 50),
        ),
      ),
    );

    expect(find.textContaining('6h40\u20136h50'), findsOneWidget);
  });

  testWidgets('a single boarding time is not shown as a window', (
    tester,
  ) async {
    final pickup = DateTime(2027, 3, 1, 6, 40);
    await pump(
      tester,
      apiVan(
        schedule: VanSchedule(boardingStartAt: pickup, boardingEndAt: pickup),
      ),
    );

    expect(find.textContaining('–'), findsNothing);
  });

  testWidgets('leaves the vehicle out when the driver has none', (
    tester,
  ) async {
    await pump(tester, apiVan(vehicleModel: null, plate: null));

    expect(find.textContaining('Sai às'), findsOneWidget);
    expect(find.textContaining('Sprinter'), findsNothing);
    expect(find.text('—'), findsNWidgets(3));
  });
}
