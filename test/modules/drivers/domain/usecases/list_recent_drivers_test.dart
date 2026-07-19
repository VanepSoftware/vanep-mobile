import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/domain/usecases/list_recent_drivers.dart';

import '../../drivers_fixtures.dart';
import '../../drivers_mocks.dart';

void main() {
  late MockDriverRepository repository;
  late ListRecentDrivers usecase;

  setUp(() {
    repository = MockDriverRepository();
    usecase = ListRecentDrivers(repository);
  });

  test('delegates to the repository with the default limit of 3', () async {
    when(
      () => repository.fetchRecentDrivers(limit: any(named: 'limit')),
    ).thenAnswer(
      (_) async => const Ok<DriverFailure, List<Driver>>(testRecentDrivers),
    );

    await usecase();

    verify(() => repository.fetchRecentDrivers(limit: 3)).called(1);
  });

  test('forwards an explicit limit', () async {
    when(
      () => repository.fetchRecentDrivers(limit: any(named: 'limit')),
    ).thenAnswer(
      (_) async => const Ok<DriverFailure, List<Driver>>(testRecentDrivers),
    );

    await usecase(limit: 10);

    verify(() => repository.fetchRecentDrivers(limit: 10)).called(1);
  });
}
