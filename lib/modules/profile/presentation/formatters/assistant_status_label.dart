import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/assistant_status.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';

String? assistantStatusLabel(AppLocalizations l10n, AssistantStatus? status) {
  return switch (status) {
    AssistantStatus.unlinked => l10n.profileAssistantStatusUnlinked,
    AssistantStatus.pending => l10n.profileAssistantStatusPending,
    AssistantStatus.active => l10n.profileAssistantStatusActive,
    AssistantStatus.inactive => l10n.profileAssistantStatusInactive,
    null => null,
  };
}

Color? assistantStatusColor(VanepPalette palette, AssistantStatus? status) {
  return switch (status) {
    AssistantStatus.active => palette.success,
    AssistantStatus.pending => VanepColors.ratingStar,
    AssistantStatus.unlinked => palette.textMuted,
    AssistantStatus.inactive => palette.danger,
    null => null,
  };
}
