import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';

abstract class AssistantAbsencesDataSource {
  Future<List<AssistantAbsence>> findAbsences(String vanToken);
}

// TODO(VAN-72): mocked absences and stop changes of the prototype (frame
// aux-rota-3-ausencias). `absence` and `stop_change_request` are modeled in
// vanep-dbdiagram but not implemented in vanep-api-java (backend B12); the read
// for the assistant still needs an endpoint. Delete this class and its
// registration in assistant_container.dart when it is wired.
class MockedAssistantAbsencesDataSource implements AssistantAbsencesDataSource {
  const MockedAssistantAbsencesDataSource({this.clock = DateTime.now});

  final DateTime Function() clock;

  @override
  Future<List<AssistantAbsence>> findAbsences(String vanToken) async {
    final now = clock();
    final today = DateTime(now.year, now.month, now.day);
    DateTime todayAt(int hour, int minute) =>
        today.add(Duration(hours: hour, minutes: minute));
    AssistantAbsence absence(
      String name,
      DateTime date,
      DateTime notifiedAt, {
      AbsenceKind kind = AbsenceKind.notGoing,
      String? contractToken,
      String? stopChangeLabel,
    }) => AssistantAbsence(
      passengerToken: 'mock-passenger-${name.split(' ').first.toLowerCase()}',
      passengerName: name,
      date: date,
      kind: kind,
      source: AbsenceSource.client,
      notifiedAt: notifiedAt,
      contractToken: contractToken,
      stopChangeLabel: stopChangeLabel,
    );

    return [
      absence('Ana Oliveira', today, todayAt(6, 2)),
      absence('Lucas Prado', today, todayAt(-4, 0)),
      absence(
        'Pedro Oliveira',
        today,
        todayAt(5, 40),
        kind: AbsenceKind.stopChange,
        stopChangeLabel: 'casa da avó, QNL 7',
      ),
      absence('Sofia Lima', today.add(const Duration(days: 2)), todayAt(5, 0)),
      for (final sibling in ['Helena Reis', 'Davi Reis'])
        absence(
          sibling,
          today.add(const Duration(days: 5)),
          todayAt(5, 0),
          kind: AbsenceKind.outboundOnly,
          contractToken: 'mock-contract-reis',
        ),
    ];
  }
}
