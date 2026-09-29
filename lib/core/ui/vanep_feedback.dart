import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_theme.dart';
import '../design_system/vanep_typography.dart';

class VanepFeedback {
  const VanepFeedback._();

  static void showError(BuildContext context, String message) {
    _show(context, message, background: VanepColors.danger);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, background: VanepColors.textPrimary);
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
            style: VanepTypography.body.copyWith(color: VanepColors.card),
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VanepTheme.controlRadius),
          ),
        ),
      );
  }
}
