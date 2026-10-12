import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_frame.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_gate.dart';

import 'localized_harness.dart';

const Widget appBehindIntro = Scaffold(body: Text('app'));

Widget introGateHarness({bool disableAnimations = false}) {
  return localizedHarness(
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: const VanepIntroGate(child: appBehindIntro),
      ),
    ),
  );
}

void main() {
  testWidgets('plays the intro over the app that is already being built', (
    tester,
  ) async {
    await tester.pumpWidget(introGateHarness());

    expect(find.byType(VanepIntroOverlay), findsOneWidget);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('removes the intro once the animation completes', (
    tester,
  ) async {
    await tester.pumpWidget(introGateHarness());

    await tester.pump(vanepIntroDuration ~/ 2);
    expect(find.byType(VanepIntroOverlay), findsOneWidget);

    await tester.pump(vanepIntroDuration);
    await tester.pump();

    expect(find.byType(VanepIntroOverlay), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('skips the intro when the system asks for reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(introGateHarness(disableAnimations: true));

    expect(find.byType(VanepIntroOverlay), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });
}
