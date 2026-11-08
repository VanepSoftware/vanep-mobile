import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

Future<bool> showVanepConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
}) async {
  final confirmColor = isDestructive
      ? context.palette.danger
      : context.palette.action;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: context.palette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Text(title, style: context.typography.cardTitle),
        content: Text(
          message,
          style: context.typography.cardSubtitle.copyWith(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              cancelLabel,
              style: context.typography.cardTitle.copyWith(
                color: context.palette.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              confirmLabel,
              style: context.typography.cardTitle.copyWith(color: confirmColor),
            ),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
