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

  static void showInfoWithAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    _show(
      context,
      message,
      background: context.palette.textPrimary,
      foreground: context.palette.card,
      action: SnackBarAction(
        label: actionLabel,
        textColor: context.palette.card,
        onPressed: onAction,
      ),
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color background,
    required Color foreground,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: context.typography.body.copyWith(color: foreground),
          ),
          action: action,
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
