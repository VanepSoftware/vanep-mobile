import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';

void main() {
  testWidgets('applies maxLength and hides the character counter', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepTextField(
            label: 'Nome',
            controller: controller,
            onChanged: (_) {},
            maxLength: 255,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLength, 255);
    expect(field.decoration?.counterText, '');
  });

  testWidgets('has no maxLength by default', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepTextField(
            label: 'Nome',
            controller: controller,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLength, isNull);
  });
}
