import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_absences.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';

import '../../fixtures/assistant_absences_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  final now = DateTime(2026, 10, 14, 7);

  test('delegates to the repository', () async {
    final repository = MockAssistantAbsencesRepository();
    when(() => repository.findAbsences('van'))
        .thenAnswer((_) async => Ok(testAbsencesOfTheWeek(now)));

    final result = await FindAssistantAbsences(repository)('van');

    expect(result.valueOrNull, testAbsencesOfTheWeek(now));
  });

  group('groupAssistantAbsences', () {
    final overview = groupAssistantAbsences(
      testAbsencesOfTheWeek(now),
      now: now,
    );

    test('splits today from the next days', () {
      expect(overview.today, hasLength(3));
      expect(overview.upcoming, hasLength(2));
    });

    test('next days are in date order', () {
      expect(overview.upcoming.map((row) => row.passengerNames.first), [
        'Sofia Lima',
        'Helena Reis',
      ]);
    });

    test('siblings with the same item on the same day share a row', () {
      expect(overview.upcoming.last.passengerNames, [
        'Helena Reis',
        'Davi Reis',
      ]);
    });

    test('no-shows recorded by the driver or assistant are left out', () {
      final names = overview.today.expand((row) => row.passengerNames);
      expect(names, isNot(contains('Laura Mendes')));
    });

    test('past days are left out', () {
      final past = groupAssistantAbsences(
        testAbsencesOfTheWeek(now),
        now: now.add(const Duration(days: 30)),
      );
      expect(past.today, isEmpty);
      expect(past.upcoming, isEmpty);
    });

    test('a stop change keeps its new place', () {
      final change = overview.today.firstWhere(
        (row) => row.kind == AbsenceKind.stopChange,
      );
      expect(change.stopChangeLabel, 'casa da avó, QNL 7');
    });
  });
}
