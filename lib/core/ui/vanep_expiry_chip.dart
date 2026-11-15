import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';

const expiryUrgentDays = 2;

bool isExpiryUrgent(DateTime now, DateTime expiresAt) {
  return calendarDaysBetween(now, expiresAt.toLocal()) <= expiryUrgentDays;
}

class VanepExpiryChip extends StatelessWidget {
  const VanepExpiryChip({
    required this.label,
    required this.isUrgent,
    super.key,
  });

  final String label;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return VanepChip(
      label: label,
      icon: Icons.schedule,
      background: isUrgent
          ? VanepColors.warningSurface
          : VanepColors.avatarGraySurface,
      foreground: isUrgent
          ? VanepColors.warningText
          : VanepColors.avatarGrayText,
    );
  }
}
