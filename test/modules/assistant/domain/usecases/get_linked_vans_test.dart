import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_linked_vans.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  late MockAssistantRepository repository;
  late GetLinkedVans usecase;

  setUp(() {
    repository = MockAssistantRepository();
    usecase = GetLinkedVans(repository);
  });

  test('returns list of linked vans on success', () async {
    final expectedVans = [
      testAssistantVanPrimary,
      testAssistantVanSecondary,
    ];

    when(() => repository.getLinkedVans()).thenAnswer(
      (_) async => Ok<AssistantFailure, List<AssistantVan>>(expectedVans),
    );

    final result = await usecase();

    expect(result, Ok<AssistantFailure, List<AssistantVan>>(expectedVans));
    verify(() => repository.getLinkedVans()).called(1);
  });

  test('returns failure when network or server fails', () async {
    when(() => repository.getLinkedVans()).thenAnswer(
      (_) async => const Err<AssistantFailure, List<AssistantVan>>(
        AssistantFailure.network,
      ),
    );

    final result = await usecase();

    expect(
      result,
      const Err<AssistantFailure, List<AssistantVan>>(AssistantFailure.network),
    );
    verify(() => repository.getLinkedVans()).called(1);
  });
}
