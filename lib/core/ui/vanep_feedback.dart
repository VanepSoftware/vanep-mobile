import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';

/// Single shared surface for transient user feedback (constitution R10).
///
/// Presentation code calls these instead of building ad-hoc SnackBars.
class VanepFeedback {
  const VanepFeedback._();

  static void showError(BuildContext context, String message) {
    _show(context, message, background: Colors.redAccent.shade200);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, background: VanepColors.backgroundSoft);
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color background,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            // Both backgrounds are dark (navy / red); force light text so the
            // message stays legible instead of the theme's dark default.
            style: const TextStyle(color: VanepColors.foreground),
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
