import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_read_only_field.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows the label above the value', (tester) async {
    await tester.pumpWidget(
      host(
        const VanepReadOnlyField(label: 'Documento', value: '123.456.789-01'),
      ),
    );

    expect(find.text('Documento'), findsOneWidget);
    expect(find.text('123.456.789-01'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
  });

  testWidgets('follows a new value', (tester) async {
    await tester.pumpWidget(
      host(const VanepReadOnlyField(label: 'Data', value: '01/01/1990')),
    );
    await tester.pumpWidget(
      host(const VanepReadOnlyField(label: 'Data', value: '02/02/1991')),
    );

    expect(find.text('01/01/1990'), findsNothing);
    expect(find.text('02/02/1991'), findsOneWidget);
  });

  testWidgets('an enabled field reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        VanepReadOnlyField(
          label: 'E-mail',
          value: 'ana@vanep.com.br',
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text('ana@vanep.com.br'));

    expect(taps, 1);
  });

  testWidgets('a disabled field ignores taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        VanepReadOnlyField(
          label: 'E-mail',
          value: 'ana@vanep.com.br',
          enabled: false,
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text('ana@vanep.com.br'), warnIfMissed: false);

    expect(taps, 0);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });
}
