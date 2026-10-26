import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_vans.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  late MockAssistantVansRepository repository;
  late FindAssistantVans findAssistantVans;

  setUp(() {
    repository = MockAssistantVansRepository();
    findAssistantVans = FindAssistantVans(repository);
  });

  test('returns the overview from the repository', () async {
    when(
      () => repository.findVansOverview(),
    ).thenAnswer((_) async => Ok(testAssistantVansOverview));

    final result = await findAssistantVans();

    expect(result.valueOrNull, testAssistantVansOverview);
  });

  test('returns the failure from the repository', () async {
    when(
      () => repository.findVansOverview(),
    ).thenAnswer((_) async => const Err(AssistantFailure.network));

    final result = await findAssistantVans();

    expect(result.errorOrNull, AssistantFailure.network);
  });
}
