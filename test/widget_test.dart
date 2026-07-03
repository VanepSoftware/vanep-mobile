import 'package:flutter_test/flutter_test.dart';

import 'package:vanep_mobile/app.dart';

void main() {
  testWidgets('HomePage shows Hello World', (WidgetTester tester) async {
    await tester.pumpWidget(const VanepApp());

    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('Vanep'), findsOneWidget);
  });
}
