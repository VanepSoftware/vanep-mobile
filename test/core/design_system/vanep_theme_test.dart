import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

void main() {
  test('dark theme is built from the brand seed', () {
    final theme = VanepTheme.dark();

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, VanepColors.backgroundDeep);
  });

  test('typography tokens expose the wordmark and button styles', () {
    expect(VanepTypography.wordmark.fontWeight, FontWeight.w800);
    expect(VanepTypography.button.fontWeight, FontWeight.w600);
    expect(VanepTypography.tagline.color, VanepColors.foreground);
    expect(VanepTypography.heading.fontSize, 24);
    expect(VanepTypography.body.fontSize, 15);
  });

  test('brand palette exposes the core tokens', () {
    expect(VanepColors.brand, const Color(0xFF5CBCD6));
    expect(VanepColors.foreground, const Color(0xFFEAF4FB));
  });
}
