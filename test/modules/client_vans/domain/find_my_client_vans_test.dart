import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';
import 'package:vanep_mobile/modules/client_vans/domain/usecases/find_my_client_vans.dart';

import '../fixtures/client_vans_fixture.dart';
import '../mocks/client_vans_mocks.dart';

void main() {
  late MockClientVansRepository repository;
  late FindMyClientVans useCase;

  setUp(() {
    repository = MockClientVansRepository();
    useCase = FindMyClientVans(repository);
  });

  test('returns list of client vans on success', () async {
    when(() => repository.findMyVans()).thenAnswer(
      (_) async => Ok([testClientVan]),
    );

    final result = await useCase();

    expect(result.valueOrNull, [testClientVan]);
    verify(() => repository.findMyVans()).called(1);
  });

  test('returns failure on error', () async {
    when(() => repository.findMyVans()).thenAnswer(
      (_) async => const Err(ClientVansFailure.network),
    );

    final result = await useCase();

    expect(result.errorOrNull, ClientVansFailure.network);
    verify(() => repository.findMyVans()).called(1);
  });
}
