import 'package:flutter/material.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class DriverShiftBadge extends StatelessWidget {
  const DriverShiftBadge({required this.onShift, super.key});

  final bool onShift;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = onShift ? l10n.driverShiftOn : l10n.driverShiftOff;
    final dotColor = onShift
        ? context.palette.success
        : context.palette.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.palette.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
