import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absences_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';

String weekdayName(AppLocalizations l10n, DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => l10n.clientHomeWeekdayMonday,
    DateTime.tuesday => l10n.clientHomeWeekdayTuesday,
    DateTime.wednesday => l10n.clientHomeWeekdayWednesday,
    DateTime.thursday => l10n.clientHomeWeekdayThursday,
    DateTime.friday => l10n.clientHomeWeekdayFriday,
    DateTime.saturday => l10n.clientHomeWeekdaySaturday,
    _ => l10n.clientHomeWeekdaySunday,
  };
}

String absenceKindLabel(AppLocalizations l10n, AbsenceKind kind) {
  return switch (kind) {
    AbsenceKind.notGoing => l10n.assistantAbsenceKindNotGoing,
    AbsenceKind.outboundOnly => l10n.assistantAbsenceKindOutboundOnly,
    AbsenceKind.returnOnly => l10n.assistantAbsenceKindReturnOnly,
    AbsenceKind.stopChange => l10n.assistantAbsenceKindStopChange,
  };
}

(Color, Color) absenceKindTones(VanepPalette palette, AbsenceKind kind) {
  return switch (kind) {
    AbsenceKind.notGoing => (palette.dangerSurface, palette.danger),
    AbsenceKind.outboundOnly ||
    AbsenceKind.returnOnly => (palette.warningSurface, palette.warning),
    AbsenceKind.stopChange => (palette.actionSurface, palette.action),
  };
}

String absenceRowDetail(
  AppLocalizations l10n,
  AssistantAbsenceRow row, {
  required bool isToday,
  required DateTime now,
  required String languageCode,
}) {
  final place = row.stopChangeLabel;
  if (row.kind == AbsenceKind.stopChange && place != null) {
    return l10n.assistantAbsenceStopChange(place);
  }
  if (!isToday) {
    return l10n.assistantAbsenceDate(
      weekdayName(l10n, row.date),
      formatDayAndMonth(row.date),
    );
  }
  return noticeLine(
    l10n,
    source: row.source,
    notifiedAt: row.notifiedAt,
    now: now,
    languageCode: languageCode,
  );
}
