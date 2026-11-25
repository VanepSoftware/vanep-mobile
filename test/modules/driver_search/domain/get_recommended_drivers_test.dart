import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_page.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';
import 'package:vanep_mobile/modules/driver_search/domain/repositories/driver_search_repository.dart';
import 'package:vanep_mobile/modules/driver_search/domain/usecases/get_recommended_drivers.dart';

class MockDriverSearchRepository extends Mock implements DriverSearchRepository {}

void main() {
  late MockDriverSearchRepository repository;
  late GetRecommendedDrivers useCase;

  setUp(() {
    repository = MockDriverSearchRepository();
    useCase = GetRecommendedDrivers(repository);
  });

  test('calls fetchRecommended on repository and returns page', () async {
    const page = DriverSearchPage(
      drivers: [DriverSearchResult(token: 'd1', name: 'Motorista')],
      isLast: true,
    );
    when(() => repository.fetchRecommended(page: 0)).thenAnswer(
      (_) async => const Ok(page),
    );

    final result = await useCase(page: 0);

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.drivers.length, 1);
    verify(() => repository.fetchRecommended(page: 0)).called(1);
  });

  test('returns failure when repository fails', () async {
    when(() => repository.fetchRecommended(page: 0)).thenAnswer(
      (_) async => const Err(DriverSearchFailure.network),
    );

    final result = await useCase(page: 0);

    expect(result.errorOrNull, DriverSearchFailure.network);
  });
}
