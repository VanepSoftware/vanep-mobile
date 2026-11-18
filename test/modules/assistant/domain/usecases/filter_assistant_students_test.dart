import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/filter_assistant_students.dart';

import '../../fixtures/assistant_fixtures.dart';

void main() {
  const students = [
    testAssistantStudentLais,
    testAssistantStudentAna,
    testAssistantStudentBeatriz,
  ];

  test('sorts alphabetically when the query is empty', () {
    final result = filterAssistantStudents(students, '');

    expect(result.map((student) => student.name), [
      'Ana Oliveira',
      'Beatriz Santos',
      'Laís Teixeira',
    ]);
  });

  test('ignores case and accents', () {
    final result = filterAssistantStudents(students, 'LAIS');

    expect(result, [testAssistantStudentLais]);
  });

  test('matches any part of the name', () {
    final result = filterAssistantStudents(students, 'santos');

    expect(result, [testAssistantStudentBeatriz]);
  });

  test('ignores surrounding spaces', () {
    final result = filterAssistantStudents(students, '  ana ');

    expect(result, [testAssistantStudentAna]);
  });

  test('returns nothing when no name matches', () {
    expect(filterAssistantStudents(students, 'zzz'), isEmpty);
  });
}
