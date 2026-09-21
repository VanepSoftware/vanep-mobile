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

  testWidgets('hides the text when obscureText is set', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepTextField(
            label: 'Senha',
            controller: controller,
            onChanged: (_) {},
            obscureText: true,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
  });

  testWidgets('a read-only field reports taps', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepTextField(
            label: 'Data',
            controller: controller,
            onChanged: (_) {},
            readOnly: true,
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));

    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    expect(taps, 1);
  });

  testWidgets('an optional field shows only its label', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepTextField(
            label: 'Bairro',
            controller: controller,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Bairro'), findsOneWidget);
    expect(find.text('*'), findsNothing);
  });

  testWidgets('a required field marks its label', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepTextField(
            label: 'CEP',
            isRequired: true,
            controller: controller,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('CEP'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
  });

  testWidgets('VanepFieldLabel marks required labels on its own', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: VanepFieldLabel(label: 'UF', isRequired: true)),
      ),
    );

    expect(find.text('UF'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
  });

  group('loading', () {
    Future<void> pumpField(
      WidgetTester tester, {
      bool isLoading = false,
      String? loadingLabel,
    }) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VanepTextField(
              label: 'CEP',
              controller: controller,
              onChanged: (_) {},
              isLoading: isLoading,
              loadingLabel: loadingLabel,
            ),
          ),
        ),
      );
    }

    testWidgets('shows a spinner only while loading', (tester) async {
      await pumpField(tester, isLoading: true);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await pumpField(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('the spinner announces the loading label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpField(tester, isLoading: true, loadingLabel: 'Consultando CEP');

      expect(find.bySemanticsLabel('Consultando CEP'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the field stays editable while loading', (tester) async {
      await pumpField(tester, isLoading: true);

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    });
  });
}
