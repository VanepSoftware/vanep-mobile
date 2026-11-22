import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_boarding_history.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_absences_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';

String historyDayTitle(AppLocalizations l10n, DateTime date) {
  return l10n.assistantAbsenceDate(
    weekdayName(l10n, date),
    formatDayAndMonth(date),
  );
}

String legRecordLine(
  AppLocalizations l10n,
  AssistantLegRecord? record, {
  required String languageCode,
}) {
  if (record == null) return l10n.assistantHistoryNoRecord;
  String clock(DateTime time) =>
      formatClockTime(time, languageCode: languageCode);
  final boardedAt = record.boardedAt;
  final droppedOffAt = record.droppedOffAt;

  return switch (record.status) {
    BoardingStatus.droppedOff when boardedAt != null && droppedOffAt != null =>
      l10n.assistantHistoryBoardedAndDropped(
        clock(boardedAt),
        clock(droppedOffAt),
      ),
    BoardingStatus.boarded || BoardingStatus.droppedOff
        when boardedAt != null =>
      l10n.assistantHistoryBoarded(clock(boardedAt)),
    BoardingStatus.noShow => l10n.assistantHistoryNoShow(
      skipReasonLine(l10n, record.noShowReason, record.skipNotes),
    ),
    BoardingStatus.notGoingToday => l10n.assistantHistoryNotGoing,
    _ => l10n.assistantHistoryNoRecord,
  };
}
