import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';

import '../drivers_fixtures.dart';

void main() {
  const loaded = DriversState(
    status: DriversStatus.loaded,
    drivers: testRecentDrivers,
  );

  test('visibleDrivers returns every driver when the query is empty', () {
    expect(loaded.visibleDrivers, hasLength(2));
  });

  test('visibleDrivers filters by name case-insensitively', () {
    final state = loaded.copyWith(query: 'carlos');

    expect(state.visibleDrivers, hasLength(1));
    expect(state.visibleDrivers.single.name, 'Carlos Souza');
  });

  test('visibleDrivers filters by city', () {
    final state = loaded.copyWith(query: 'ceilândia');

    expect(state.visibleDrivers.single.name, 'Ana Pereira');
  });

  test('visibleDrivers is empty when nothing matches', () {
    expect(loaded.copyWith(query: 'zzz').visibleDrivers, isEmpty);
  });

  test('copyWith clears the failure when omitted', () {
    final state = loaded.copyWith(status: DriversStatus.loaded);

    expect(state.failure, isNull);
  });
}
