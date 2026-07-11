import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vanep_mobile/app.dart';

void main() {
  testWidgets('SplashScreen shows the vanep wordmark', (WidgetTester tester) async {
    await tester.pumpWidget(const VanepApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.textSpan?.toPlainText() == 'vanep.',
      ),
      findsOneWidget,
    );
  });
}
