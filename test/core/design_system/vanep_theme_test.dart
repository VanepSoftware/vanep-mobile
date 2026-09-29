import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

void main() {
  test('light theme is built from the action seed', () {
    final theme = VanepTheme.light();

    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, VanepColors.surface);
    expect(theme.colorScheme.primary, VanepColors.action);
  });

  test('theme flattens the shared surfaces', () {
    final theme = VanepTheme.light();

    expect(theme.appBarTheme.backgroundColor, VanepColors.card);
    expect(theme.appBarTheme.elevation, 0);
    expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.snackBarTheme.elevation, 0);
  });

  test('typography tokens expose the wordmark and button styles', () {
    expect(VanepTypography.wordmark.fontWeight, FontWeight.w800);
    expect(VanepTypography.button.fontWeight, FontWeight.w600);
    expect(VanepTypography.tagline.color, VanepColors.textSecondary);
    expect(VanepTypography.heading.fontSize, 24);
    expect(VanepTypography.body.fontSize, 15);
  });

  test('palette exposes the action tokens and drops the legacy blue', () {
    expect(VanepColors.action, const Color(0xFF0B6BD3));
    expect(VanepColors.textPrimary, const Color(0xFF0B2038));
    expect(VanepColors.surface, const Color(0xFFF4F6F8));
  });
}
