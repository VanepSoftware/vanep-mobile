import 'package:flutter/painting.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

const studentAvatarTones = [
  (VanepColors.actionSurface, VanepColors.action),
  (VanepColors.warningSurface, VanepColors.warning),
  (VanepColors.successSurface, VanepColors.success),
  (VanepColors.avatarPlaceholder, VanepColors.textSecondary),
];

(Color, Color) studentAvatarToneOf(String token) {
  final hash = token.codeUnits.fold(0, (sum, unit) => sum + unit);
  return studentAvatarTones[hash % studentAvatarTones.length];
}

String assistantRosterTabLabel(AppLocalizations l10n, AssistantVan van) {
  final shift = assistantVansShiftLabel(l10n, van.shift);
  final name = firstNameOf(van.driverName);
  return shift.isEmpty ? name : '$name$vanSubtitleSeparator$shift';
}
