import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';

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

            style: const TextStyle(color: VanepColors.foreground),
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
