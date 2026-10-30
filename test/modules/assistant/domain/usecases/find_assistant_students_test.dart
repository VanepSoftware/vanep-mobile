import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_students.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  test('returns the overview of the repository', () async {
    final repository = MockAssistantStudentsRepository();
    when(
      () => repository.findStudentsOverview(),
    ).thenAnswer((_) async => const Ok(testAssistantStudentsOverview));

    final result = await FindAssistantStudents(repository)();

    expect(result.valueOrNull, testAssistantStudentsOverview);
  });
}
