import 'package:flutter/material.dart';

import 'vanep_colors.dart';
import 'vanep_typography.dart';

class VanepTheme {
  const VanepTheme._();

  static const double controlRadius = 10;
  static const double cardRadius = 12;

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme(),
      scaffoldBackgroundColor: VanepColors.surface,
      canvasColor: VanepColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: VanepColors.card,
        foregroundColor: VanepColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: VanepColors.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: VanepColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: VanepColors.cardBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: VanepColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: VanepColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(style: filledButtonStyle()),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: outlinedButtonStyle(),
      ),
      switchTheme: switchStyle(),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: VanepColors.action,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: VanepColors.textPrimary,
        contentTextStyle: VanepTypography.body.copyWith(
          color: VanepColors.card,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
    );
  }

  static ColorScheme lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: VanepColors.action,
      brightness: Brightness.light,
    ).copyWith(
      primary: VanepColors.action,
      onPrimary: VanepColors.card,
      surface: VanepColors.surface,
      onSurface: VanepColors.textPrimary,
      surfaceContainerHighest: VanepColors.card,
      outline: VanepColors.inputBorder,
      outlineVariant: VanepColors.cardBorder,
      error: VanepColors.danger,
      onError: VanepColors.card,
    );
  }

  static ButtonStyle filledButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: VanepColors.action,
      foregroundColor: VanepColors.card,
      disabledBackgroundColor: VanepColors.inputBorder,
      disabledForegroundColor: VanepColors.textMuted,
      elevation: 0,
      textStyle: VanepTypography.button,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(controlRadius),
      ),
    );
  }

  static ButtonStyle textButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: VanepColors.action,
      disabledForegroundColor: VanepColors.textMuted,
      textStyle: VanepTypography.button,
    );
  }

  static ButtonStyle outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: VanepColors.textPrimary,
      disabledForegroundColor: VanepColors.textMuted,
      backgroundColor: VanepColors.card,
      side: const BorderSide(color: VanepColors.inputBorder),
      textStyle: VanepTypography.button,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(controlRadius),
      ),
    );
  }

  static SwitchThemeData switchStyle() {
    return SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(VanepColors.card),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? VanepColors.action
            : VanepColors.inputBorder,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? VanepColors.action
            : VanepColors.inputBorder,
      ),
    );
  }
}
