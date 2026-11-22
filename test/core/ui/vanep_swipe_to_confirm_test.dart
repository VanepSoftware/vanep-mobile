import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_swipe_to_confirm.dart';

const swipeLabel = 'Deslize para confirmar (2)';
const swipeSemanticsLabel = 'Confirmar embarque de 2 alunos';

Widget swipeHarness({VoidCallback? onConfirmed, bool isLoading = false}) {
  return MaterialApp(
    theme: VanepTheme.light(),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: VanepSwipeToConfirm(
          label: swipeLabel,
          semanticsLabel: swipeSemanticsLabel,
          onConfirmed: onConfirmed,
          isLoading: isLoading,
        ),
      ),
    ),
  );
}

Finder findKnob() => find.byKey(vanepSwipeToConfirmKnobKey);

void main() {
  testWidgets('shows the label', (tester) async {
    await tester.pumpWidget(swipeHarness(onConfirmed: () {}));

    expect(find.text(swipeLabel), findsOneWidget);
  });

  testWidgets('a swipe to the end of the track confirms once', (tester) async {
    var confirmations = 0;
    await tester.pumpWidget(swipeHarness(onConfirmed: () => confirmations++));

    await tester.drag(findKnob(), const Offset(1000, 0));
    await tester.pumpAndSettle();

    expect(confirmations, 1);
  });

  testWidgets('a swipe released before the end does nothing and springs back', (
    tester,
  ) async {
    var confirmations = 0;
    await tester.pumpWidget(swipeHarness(onConfirmed: () => confirmations++));
    final start = tester.getTopLeft(findKnob());

    await tester.drag(findKnob(), const Offset(80, 0));
    await tester.pumpAndSettle();

    expect(confirmations, 0);
    expect(tester.getTopLeft(findKnob()), start);
  });

  testWidgets('a tap never confirms', (tester) async {
    var confirmations = 0;
    await tester.pumpWidget(swipeHarness(onConfirmed: () => confirmations++));

    await tester.tap(findKnob());
    await tester.tap(find.text(swipeLabel));
    await tester.pumpAndSettle();

    expect(confirmations, 0);
  });

  testWidgets('without a callback the control is disabled', (tester) async {
    await tester.pumpWidget(swipeHarness());
    final start = tester.getTopLeft(findKnob());

    await tester.drag(findKnob(), const Offset(1000, 0));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(findKnob()), start);
  });

  testWidgets('while loading it shows progress and ignores swipes', (
    tester,
  ) async {
    var confirmations = 0;
    await tester.pumpWidget(
      swipeHarness(onConfirmed: () => confirmations++, isLoading: true),
    );

    await tester.drag(findKnob(), const Offset(1000, 0));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(confirmations, 0);
  });

  testWidgets('screen readers confirm through the semantics action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var confirmations = 0;
    await tester.pumpWidget(swipeHarness(onConfirmed: () => confirmations++));

    tester.semantics.tap(find.semantics.byLabel(swipeSemanticsLabel));
    await tester.pump();

    expect(confirmations, 1);
    semantics.dispose();
  });

  testWidgets('screen readers get no action while disabled', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(swipeHarness());

    final node = tester.getSemantics(
      find.bySemanticsLabel(swipeSemanticsLabel),
    );

    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    semantics.dispose();
  });
}
