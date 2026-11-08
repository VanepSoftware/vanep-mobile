import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepFeedback {
  const VanepFeedback._();

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      background: context.palette.danger,
      foreground: context.palette.onAction,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message,
      background: context.palette.textPrimary,
      foreground: context.palette.card,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color background,
    required Color foreground,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: context.typography.body.copyWith(color: foreground),
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
