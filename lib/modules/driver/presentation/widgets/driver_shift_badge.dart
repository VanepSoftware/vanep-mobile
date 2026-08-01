import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../l10n/app_localizations.dart';

class DriverShiftBadge extends StatelessWidget {
  const DriverShiftBadge({required this.onShift, super.key});

  final bool onShift;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = onShift ? l10n.driverShiftOn : l10n.driverShiftOff;
    final dotColor = onShift ? VanepColors.brand : VanepColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: VanepColors.searchField,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: VanepColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
