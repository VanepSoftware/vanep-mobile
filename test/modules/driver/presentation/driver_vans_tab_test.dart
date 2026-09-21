import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_vans_tab.dart';

import '../../../core/ui/localized_harness.dart';

void main() {
  testWidgets('lists my vans disabled and where you operate enabled', (
    tester,
  ) async {
    var serviceAreasOpened = 0;
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: DriverVansTab(onOpenServiceAreas: () => serviceAreasOpened++),
        ),
      ),
    );

    expect(find.text('Vans'), findsOneWidget);
    expect(find.text('Minhas vans'), findsOneWidget);
    expect(find.text('Onde você atende'), findsOneWidget);

    await tester.tap(find.text('Minhas vans'));
    expect(serviceAreasOpened, 0);

    await tester.tap(find.text('Onde você atende'));
    expect(serviceAreasOpened, 1);
  });
}
