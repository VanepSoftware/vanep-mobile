import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
          ? context.palette.warningSurface
          : context.palette.avatarGraySurface,
      foreground: isUrgent
          ? context.palette.warningText
          : context.palette.avatarGrayText,
    );
  }
}
