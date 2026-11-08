import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_vans_repository_impl.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  test('wraps the overview of the data source in Ok', () async {
    final dataSource = MockAssistantVansDataSource();
    when(
      () => dataSource.findVansOverview(),
    ).thenAnswer((_) async => testAssistantVansOverview);
    final repository = AssistantVansRepositoryImpl(dataSource: dataSource);

    final result = await repository.findVansOverview();

    expect(result.valueOrNull, testAssistantVansOverview);
  });
}
