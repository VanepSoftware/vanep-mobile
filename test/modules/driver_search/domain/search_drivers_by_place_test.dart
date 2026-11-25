import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_page.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';
import 'package:vanep_mobile/modules/driver_search/domain/repositories/driver_search_repository.dart';
import 'package:vanep_mobile/modules/driver_search/domain/usecases/search_drivers_by_place.dart';

class MockDriverSearchRepository extends Mock implements DriverSearchRepository {}

void main() {
  late MockDriverSearchRepository repository;
  late SearchDriversByPlace useCase;

  setUp(() {
    repository = MockDriverSearchRepository();
    useCase = SearchDriversByPlace(repository);
  });

  test('delegates searchByPlace to repository', () async {
    const page = DriverSearchPage(
      drivers: [DriverSearchResult(token: 'd1', name: 'Motorista')],
      isLast: true,
    );
    when(
      () => repository.searchByPlace(
        'place-1',
        'session-1',
        page: 0,
      ),
    ).thenAnswer((_) async => const Ok(page));

    final result = await useCase('place-1', sessionToken: 'session-1', page: 0);

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.drivers.length, 1);
    verify(
      () => repository.searchByPlace(
        'place-1',
        'session-1',
        page: 0,
      ),
    ).called(1);
  });

  test('returns failure when repository fails', () async {
    when(
      () => repository.searchByPlace(
        'place-1',
        null,
        page: 0,
      ),
    ).thenAnswer((_) async => const Err(DriverSearchFailure.network));

    final result = await useCase('place-1', page: 0);

    expect(result.errorOrNull, DriverSearchFailure.network);
  });
}
