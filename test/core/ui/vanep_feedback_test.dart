import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';

Widget _host(void Function(BuildContext) onTap) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => onTap(context),
          child: const Text('tap'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('showError renders the message in a snackbar', (tester) async {
    await tester.pumpWidget(_host((c) => VanepFeedback.showError(c, 'boom')));
    await tester.tap(find.text('tap'));
    await tester.pump();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('showInfo renders the message in a snackbar', (tester) async {
    await tester.pumpWidget(_host((c) => VanepFeedback.showInfo(c, 'hello')));
    await tester.tap(find.text('tap'));
    await tester.pump();

    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('showInfoWithAction runs the action when tapped', (tester) async {
    var undone = 0;
    await tester.pumpWidget(
      _host(
        (c) => VanepFeedback.showInfoWithAction(
          c,
          'saved',
          actionLabel: 'Undo',
          onAction: () => undone++,
        ),
      ),
    );
    await tester.tap(find.text('tap'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));

    expect(find.text('saved'), findsOneWidget);
    expect(undone, 1);
  });
}
