import 'package:flutter/painting.dart';

import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

List<(Color, Color)> studentAvatarTonesOf(VanepPalette palette) => [
  (palette.actionSurface, palette.action),
  (palette.warningSurface, palette.warning),
  (palette.successSurface, palette.success),
  (palette.avatarPlaceholder, palette.textSecondary),
];

(Color, Color) studentAvatarToneOf(VanepPalette palette, String token) {
  final tones = studentAvatarTonesOf(palette);
  final hash = token.codeUnits.fold(0, (sum, unit) => sum + unit);
  return tones[hash % tones.length];
}

String assistantRosterTabLabel(AppLocalizations l10n, AssistantVan van) {
  final shift = assistantVansShiftLabel(l10n, van.shift);
  final name = firstNameOf(van.driverName);
  return shift.isEmpty ? name : '$name$vanSubtitleSeparator$shift';
}
