import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';

import 'driver_home_preview.dart';

void main() {
  testWidgets('preview identifies test data and switches state and locale', (
    tester,
  ) async {
    await tester.pumpWidget(const DriverHomePreview());
    await tester.pumpAndSettle();
    expect(find.text('Prévia de teste — dados simulados'), findsOneWidget);
    expect(find.text('Antes de sair'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<HomePhase>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('rejected').last);
    await tester.pumpAndSettle();
    expect(find.text('Cadastro rejeitado'), findsOneWidget);
    expect(find.text('CNH ilegível'), findsOneWidget);
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Test preview — simulated data'), findsOneWidget);
    expect(find.text('Registration rejected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
