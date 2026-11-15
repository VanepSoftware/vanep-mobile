import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

enum VanepConfirmChoice { confirmed, declined, dismissed }

Future<bool> showVanepConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
}) async {
  final choice = await showVanepConfirmChoice(
    context: context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    isDestructive: isDestructive,
  );
  return choice == VanepConfirmChoice.confirmed;
}

Future<VanepConfirmChoice> showVanepConfirmChoice({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
}) async {
  final confirmColor = isDestructive ? VanepColors.danger : VanepColors.action;
  final choice = await showDialog<VanepConfirmChoice>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: VanepColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Text(title, style: VanepTypography.cardTitle),
        content: Text(
          message,
          style: VanepTypography.cardSubtitle.copyWith(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(VanepConfirmChoice.declined),
            child: Text(
              cancelLabel,
              style: VanepTypography.cardTitle.copyWith(
                color: VanepColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(VanepConfirmChoice.confirmed),
            child: Text(
              confirmLabel,
              style: VanepTypography.cardTitle.copyWith(color: confirmColor),
            ),
          ),
        ],
      );
    },
  );
  return choice ?? VanepConfirmChoice.dismissed;
}
