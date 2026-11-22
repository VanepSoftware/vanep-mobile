import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';

AssistantAbsence testAbsence(
  String name, {
  required DateTime date,
  required DateTime notifiedAt,
  AbsenceKind kind = AbsenceKind.notGoing,
  AbsenceSource source = AbsenceSource.client,
  String? contractToken,
  String? stopChangeLabel,
}) {
  return AssistantAbsence(
    passengerToken: 'passenger-${name.split(' ').first.toLowerCase()}',
    passengerName: name,
    date: date,
    kind: kind,
    source: source,
    notifiedAt: notifiedAt,
    contractToken: contractToken,
    stopChangeLabel: stopChangeLabel,
  );
}

List<AssistantAbsence> testAbsencesOfTheWeek(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return [
    testAbsence(
      'Helena Reis',
      date: today.add(const Duration(days: 5)),
      notifiedAt: today,
      kind: AbsenceKind.outboundOnly,
      contractToken: 'contract-reis',
    ),
    testAbsence(
      'Ana Oliveira',
      date: today,
      notifiedAt: today.add(const Duration(hours: 6, minutes: 2)),
    ),
    testAbsence(
      'Lucas Prado',
      date: today,
      notifiedAt: today.subtract(const Duration(hours: 4)),
    ),
    testAbsence(
      'Pedro Oliveira',
      date: today,
      notifiedAt: today.add(const Duration(hours: 5)),
      kind: AbsenceKind.stopChange,
      stopChangeLabel: 'casa da avó, QNL 7',
    ),
    testAbsence(
      'Laura Mendes',
      date: today,
      notifiedAt: today.add(const Duration(hours: 6, minutes: 33)),
      source: AbsenceSource.assistant,
    ),
    testAbsence(
      'Sofia Lima',
      date: today.add(const Duration(days: 2)),
      notifiedAt: today,
    ),
    testAbsence(
      'Davi Reis',
      date: today.add(const Duration(days: 5)),
      notifiedAt: today,
      kind: AbsenceKind.outboundOnly,
      contractToken: 'contract-reis',
    ),
  ];
}
