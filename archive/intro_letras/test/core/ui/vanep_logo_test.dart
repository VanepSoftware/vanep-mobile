import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_frame.dart';
import 'package:vanep_mobile/core/ui/vanep_logo.dart';
import 'package:vanep_mobile/core/ui/vanep_logo_glyphs.dart';

import 'localized_harness.dart';

Finder logoCanvas() {
  return find.descendant(
    of: find.byType(VanepLogo),
    matching: find.byType(CustomPaint),
  );
}

void main() {
  testWidgets('announces the brand name to screen readers', (tester) async {
    await tester.pumpWidget(
      localizedHarness(const Center(child: VanepLogo(width: 200))),
    );

    expect(find.bySemanticsLabel('Vanep'), findsOneWidget);
  });

  testWidgets('keeps the wordmark proportions for the requested width', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedHarness(const Center(child: VanepLogo(width: 200))),
    );

    final size = tester.getSize(logoCanvas());
    expect(size.width, 200);
    expect(size.height, closeTo(200 * vanepLogoHeight / vanepLogoWidth, 0.01));
  });

  testWidgets('paints letters that are still hidden without failing', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedHarness(
        Center(
          child: VanepLogo(
            width: 200,
            letterReveals: VanepIntroFrame.at(0.2).letterReveals,
          ),
        ),
      ),
    );

    expect(logoCanvas(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('repaints only when the colour or the reveal changes', () {
    final painter = VanepLogoPainter(
      color: VanepColors.onBrand,
      letterReveals: vanepLogoFullyRevealed,
    );

    expect(
      painter.shouldRepaint(
        VanepLogoPainter(
          color: VanepColors.onBrand,
          letterReveals: vanepLogoFullyRevealed,
        ),
      ),
      isFalse,
    );
    expect(
      painter.shouldRepaint(
        VanepLogoPainter(
          color: VanepColors.textPrimary,
          letterReveals: vanepLogoFullyRevealed,
        ),
      ),
      isTrue,
    );
    expect(
      painter.shouldRepaint(
        VanepLogoPainter(
          color: VanepColors.onBrand,
          letterReveals: VanepIntroFrame.at(0.2).letterReveals,
        ),
      ),
      isTrue,
    );
  });
}
