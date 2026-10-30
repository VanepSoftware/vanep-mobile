import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_students_repository_impl.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  test('wraps the overview of the data source in Ok', () async {
    final dataSource = MockAssistantStudentsDataSource();
    when(
      () => dataSource.findStudentsOverview(),
    ).thenAnswer((_) async => testAssistantStudentsOverview);
    final repository = AssistantStudentsRepositoryImpl(dataSource: dataSource);

    final result = await repository.findStudentsOverview();

    expect(result.valueOrNull, testAssistantStudentsOverview);
  });
}
