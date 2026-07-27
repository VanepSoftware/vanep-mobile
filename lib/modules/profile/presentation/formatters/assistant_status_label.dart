import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/assistant_status.dart';

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
    AssistantStatus.active => VanepColors.brand,
    AssistantStatus.pending => VanepColors.ratingStar,
    AssistantStatus.unlinked => VanepColors.textMuted,
    AssistantStatus.inactive => VanepColors.danger,
    null => null,
  };
}
