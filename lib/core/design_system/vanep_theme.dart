import 'package:flutter/material.dart';

import 'vanep_colors.dart';

/// Builds the single application [ThemeData] for Vanep (constitution R10).
class VanepTheme {
  const VanepTheme._();

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: VanepColors.brand,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: VanepColors.backgroundDeep,
    );
  }
}
