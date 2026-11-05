import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/assistant_status.dart';

String? assistantStatusLabel(AppLocalizations l10n, AssistantStatus? status) {
  return switch (status) {
    AssistantStatus.unlinked => l10n.profileAssistantStatusUnlinked,
    AssistantStatus.pending => l10n.profileAssistantStatusPending,
    AssistantStatus.active => l10n.profileAssistantStatusActive,
    AssistantStatus.inactive => l10n.profileAssistantStatusInactive,
    null => null,
  };
}

Color? assistantStatusColor(AssistantStatus? status) {
  return switch (status) {
    AssistantStatus.active => VanepColors.success,
    AssistantStatus.pending => VanepColors.ratingStar,
    AssistantStatus.unlinked => VanepColors.textMuted,
    AssistantStatus.inactive => VanepColors.danger,
    null => null,
  };
}
