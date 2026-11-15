import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

class VanepTheme {
  const VanepTheme._();

  static const double controlRadius = 10;
  static const double cardRadius = 12;

  static ThemeData light() =>
      buildTheme(VanepPalette.light, brightness: Brightness.light);

  static ThemeData dark() =>
      buildTheme(VanepPalette.dark, brightness: Brightness.dark);

  static ThemeData buildTheme(
    VanepPalette palette, {
    required Brightness brightness,
  }) {
    final typography = VanepTypography(palette);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: buildColorScheme(palette, brightness: brightness),
      extensions: [palette],
      scaffoldBackgroundColor: palette.surface,
      canvasColor: palette.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.card,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: buildFilledButtonStyle(palette, typography),
      ),
      textButtonTheme: TextButtonThemeData(
        style: buildTextButtonStyle(palette, typography),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: buildOutlinedButtonStyle(palette, typography),
      ),
      switchTheme: buildSwitchTheme(palette),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.action),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.textPrimary,
        contentTextStyle: typography.body.copyWith(color: palette.card),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
    );
  }

  static ColorScheme buildColorScheme(
    VanepPalette palette, {
    required Brightness brightness,
  }) {
    return ColorScheme.fromSeed(
      seedColor: palette.action,
      brightness: brightness,
    ).copyWith(
      primary: palette.action,
      onPrimary: palette.onAction,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      surfaceContainerHighest: palette.card,
      outline: palette.inputBorder,
      outlineVariant: palette.cardBorder,
      error: palette.danger,
      onError: palette.onAction,
    );
  }

  static ButtonStyle buildFilledButtonStyle(
    VanepPalette palette,
    VanepTypography typography,
  ) {
    return FilledButton.styleFrom(
      backgroundColor: palette.action,
      foregroundColor: palette.onAction,
      disabledBackgroundColor: palette.inputBorder,
      disabledForegroundColor: palette.textMuted,
      elevation: 0,
      textStyle: typography.button,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(controlRadius),
      ),
    );
  }

  static ButtonStyle buildTextButtonStyle(
    VanepPalette palette,
    VanepTypography typography,
  ) {
    return TextButton.styleFrom(
      foregroundColor: palette.action,
      disabledForegroundColor: palette.textMuted,
      textStyle: typography.button,
    );
  }

  static ButtonStyle buildOutlinedButtonStyle(
    VanepPalette palette,
    VanepTypography typography,
  ) {
    return OutlinedButton.styleFrom(
      foregroundColor: palette.textPrimary,
      disabledForegroundColor: palette.textMuted,
      backgroundColor: palette.card,
      side: BorderSide(color: palette.inputBorder),
      textStyle: typography.button,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(controlRadius),
      ),
    );
  }

  static SwitchThemeData buildSwitchTheme(VanepPalette palette) {
    return SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(palette.onAction),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.action
            : palette.inputBorder,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.action
            : palette.inputBorder,
      ),
    );
  }
}
