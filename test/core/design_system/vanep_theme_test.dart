import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

void main() {
  test('light theme is built from the light palette', () {
    final theme = VanepTheme.light();

    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, VanepPalette.light.surface);
    expect(theme.colorScheme.primary, VanepPalette.light.action);
    expect(theme.extension<VanepPalette>(), VanepPalette.light);
  });

  test('dark theme is built from the dark palette', () {
    final theme = VanepTheme.dark();

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, VanepPalette.dark.surface);
    expect(theme.colorScheme.primary, VanepPalette.dark.action);
    expect(theme.colorScheme.onPrimary, VanepPalette.dark.onAction);
    expect(theme.extension<VanepPalette>(), VanepPalette.dark);
  });

  test('theme flattens the shared surfaces', () {
    final theme = VanepTheme.light();

    expect(theme.appBarTheme.backgroundColor, VanepPalette.light.card);
    expect(theme.appBarTheme.elevation, 0);
    expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.snackBarTheme.elevation, 0);
  });

  test('light palette keeps the original light values', () {
    expect(VanepPalette.light.action, const Color(0xFF0B6BD3));
    expect(VanepPalette.light.textPrimary, const Color(0xFF0B2038));
    expect(VanepPalette.light.surface, const Color(0xFFF4F6F8));
    expect(VanepPalette.light.card, const Color(0xFFFFFFFF));
    expect(VanepPalette.light.onAction, const Color(0xFFFFFFFF));
    expect(VanepPalette.light.raisedSurface, const Color(0xFFFFFFFF));
  });

  test('dark palette darkens surfaces and lightens text', () {
    final dark = VanepPalette.dark;

    expect(
      dark.surface.computeLuminance(),
      lessThan(VanepPalette.light.surface.computeLuminance()),
    );
    expect(
      dark.textPrimary.computeLuminance(),
      greaterThan(dark.card.computeLuminance()),
    );
    expect(dark.onAction, const Color(0xFFFFFFFF));
    expect(
      dark.raisedSurface.computeLuminance(),
      greaterThan(dark.divider.computeLuminance()),
    );
  });

  test('lerp interpolates between palettes', () {
    final halfway = VanepPalette.light.lerp(VanepPalette.dark, 0.5);

    expect(
      halfway.surface,
      Color.lerp(VanepPalette.light.surface, VanepPalette.dark.surface, 0.5),
    );
    expect(VanepPalette.light.lerp(VanepPalette.dark, 0), VanepPalette.light);
    expect(VanepPalette.light.lerp(null, 0.5), VanepPalette.light);
  });

  test('typography takes its colors from the palette', () {
    const light = VanepTypography(VanepPalette.light);
    const dark = VanepTypography(VanepPalette.dark);

    expect(light.cardTitle.color, VanepPalette.light.textPrimary);
    expect(dark.cardTitle.color, VanepPalette.dark.textPrimary);
    expect(dark.cardSubtitle.color, VanepPalette.dark.textSecondary);
    expect(dark.linkAction.color, VanepPalette.dark.action);
    expect(dark.cardTitle.fontSize, light.cardTitle.fontSize);
    expect(light.wordmark.fontWeight, FontWeight.w800);
    expect(light.button.fontWeight, FontWeight.w600);
    expect(light.heading.fontSize, 24);
    expect(light.body.fontSize, 15);
  });

  testWidgets('context exposes the active palette and typography', (
    tester,
  ) async {
    late VanepPalette palette;
    late VanepTypography typography;
    await tester.pumpWidget(
      MaterialApp(
        theme: VanepTheme.dark(),
        home: Builder(
          builder: (context) {
            palette = context.palette;
            typography = context.typography;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(palette, VanepPalette.dark);
    expect(typography.body.color, VanepPalette.dark.textPrimary);
  });

  testWidgets('surface overlay style keeps status bar icons legible', (
    tester,
  ) async {
    Future<SystemUiOverlayStyle> overlayStyleUnder(ThemeData theme) async {
      late SystemUiOverlayStyle style;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              style = context.surfaceOverlayStyle;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      return style;
    }

    final styles = [
      await overlayStyleUnder(VanepTheme.light()),
      await overlayStyleUnder(VanepTheme.dark()),
    ];

    expect(styles, [SystemUiOverlayStyle.dark, SystemUiOverlayStyle.light]);
  });

  testWidgets('context falls back to the light palette without the theme', (
    tester,
  ) async {
    late VanepPalette palette;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            palette = context.palette;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(palette, VanepPalette.light);
  });
}
