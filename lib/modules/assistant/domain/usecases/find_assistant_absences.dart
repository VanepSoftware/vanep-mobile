import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_absences_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absences_overview.dart';

class FindAssistantAbsences {
  const FindAssistantAbsences(this.repository);

  final AssistantAbsencesRepository repository;

  Future<Result<AssistantFailure, List<AssistantAbsence>>> call(
    String vanToken,
  ) {
    return repository.findAbsences(vanToken);
  }
}

DateTime dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

AssistantAbsencesOverview groupAssistantAbsences(
  List<AssistantAbsence> absences, {
  required DateTime now,
}) {
  final today = dayOf(now);
  final fromFamily =
      absences
          .where(
            (absence) =>
                absence.source == AbsenceSource.client &&
                !dayOf(absence.date).isBefore(today),
          )
          .toList()
        ..sort((first, second) => first.date.compareTo(second.date));

  final rowsByItem =
      <(String, DateTime, AbsenceKind, String?), AssistantAbsenceRow>{};
  for (final absence in fromFamily) {
    final item = (
      absence.contractToken ?? absence.passengerToken,
      dayOf(absence.date),
      absence.kind,
      absence.stopChangeLabel,
    );
    final row = rowsByItem[item];
    rowsByItem[item] = AssistantAbsenceRow(
      passengerNames: [...?row?.passengerNames, absence.passengerName],
      passengerTokens: [...?row?.passengerTokens, absence.passengerToken],
      date: absence.date,
      kind: absence.kind,
      source: absence.source,
      notifiedAt: row?.notifiedAt ?? absence.notifiedAt,
      stopChangeLabel: absence.stopChangeLabel,
    );
  }

  final rows = rowsByItem.values;
  return AssistantAbsencesOverview(
    today: rows.where((row) => dayOf(row.date) == today).toList(),
    upcoming: rows.where((row) => dayOf(row.date).isAfter(today)).toList(),
  );
}
