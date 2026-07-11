import 'package:flutter/material.dart';

/// Vanep brand palette — navy gradient + teal accent (from vanep-frontend).
///
/// Single source of truth for brand colors (constitution R06a/R10). Widgets and
/// the theme derive from these tokens; never hardcode hex values elsewhere.
class VanepColors {
  const VanepColors._();

  static const Color backgroundDeep = Color(0xFF071D37);
  static const Color backgroundMid = Color(0xFF0A2C50);
  static const Color backgroundSoft = Color(0xFF103E6E);
  static const Color foreground = Color(0xFFEAF4FB);
  static const Color brand = Color(0xFF5CBCD6);

  /// Teal glow, upper-right (radial-gradient at 72% 38% in the web wordmark).
  static const Color glowPrimary = Color(0x335CBCD6);
  static const Color glowPrimaryFade = Color(0x005CBCD6);

  /// Softer glow, lower-left (radial-gradient at 8% 88%).
  static const Color glowSecondary = Color(0x2445A9C6);
  static const Color glowSecondaryFade = Color(0x0045A9C6);
}
