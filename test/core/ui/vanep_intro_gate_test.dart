import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_gate.dart';
import 'package:vanep_mobile/core/ui/vanep_van_intro.dart';
import 'package:vanep_mobile/core/ui/vanep_van_intro_timeline.dart';

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
  testWidgets('plays the van intro over the app that is already being built', (
    tester,
  ) async {
    await tester.pumpWidget(introGateHarness());

    expect(find.byType(VanepVanIntroOverlay), findsOneWidget);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('removes the intro once the van has driven by', (tester) async {
    await tester.pumpWidget(introGateHarness());

    await tester.pump(vanepVanIntroDuration ~/ 2);
    expect(find.byType(VanepVanIntroOverlay), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(vanepVanIntroDuration);
    await tester.pump();

    expect(find.byType(VanepVanIntroOverlay), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('skips the intro when the system asks for reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(introGateHarness(disableAnimations: true));

    expect(find.byType(VanepVanIntroOverlay), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });
}
