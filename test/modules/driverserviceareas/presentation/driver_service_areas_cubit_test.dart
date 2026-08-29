import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driverserviceareas/domain/entities/service_area_draft.dart';
import 'package:vanep_mobile/modules/driverserviceareas/domain/failures/service_area_failure.dart';
import 'package:vanep_mobile/modules/driverserviceareas/presentation/cubit/driver_service_areas_cubit.dart';
import 'package:vanep_mobile/modules/driverserviceareas/presentation/cubit/driver_service_areas_state.dart';

import '../driver_service_areas_fixtures.dart';
import '../driver_service_areas_mocks.dart';

void main() {
  late MockFindMyServiceAreas findMyServiceAreas;
  late MockReplaceMyServiceAreas replaceMyServiceAreas;

  setUpAll(() => registerFallbackValue(<ServiceAreaDraft>[]));

  setUp(() {
    findMyServiceAreas = MockFindMyServiceAreas();
    replaceMyServiceAreas = MockReplaceMyServiceAreas();
  });

  DriverServiceAreasCubit buildCubit() {
    return DriverServiceAreasCubit(
      findMyServiceAreas: findMyServiceAreas,
      replaceMyServiceAreas: replaceMyServiceAreas,
    );
  }

  blocTest<DriverServiceAreasCubit, DriverServiceAreasState>(
    'loads the saved areas into editable drafts',
    setUp: () => when(findMyServiceAreas.call).thenAnswer(
      (_) async => const Ok([testQnl5Area]),
    ),
    build: buildCubit,
    act: (cubit) => cubit.loadMyAreas(),
    expect: () => [
      const DriverServiceAreasState(status: DriverServiceAreasStatus.loading),
      isA<DriverServiceAreasState>()
          .having((s) => s.status, 'status', DriverServiceAreasStatus.ready)
          .having((s) => s.saved, 'saved', [testQnl5Area])
          .having((s) => s.drafts.single.label, 'draft label', 'QNL 5'),
    ],
  );

  blocTest<DriverServiceAreasCubit, DriverServiceAreasState>(
    'adds a draft',
    build: buildCubit,
    act: (cubit) => cubit.addDraft(testQnl5Draft),
    expect: () => [
      isA<DriverServiceAreasState>().having(
        (s) => s.drafts,
        'drafts',
        [testQnl5Draft],
      ),
    ],
  );

  blocTest<DriverServiceAreasCubit, DriverServiceAreasState>(
    'ignores a place already in the list',
    build: buildCubit,
    act: (cubit) => cubit
      ..addDraft(testQnl5Draft)
      ..addDraft(testQnl5Draft),
    expect: () => [
      isA<DriverServiceAreasState>().having((s) => s.drafts, 'drafts', hasLength(1)),
    ],
  );

  blocTest<DriverServiceAreasCubit, DriverServiceAreasState>(
    'removes a draft',
    build: buildCubit,
    seed: () => const DriverServiceAreasState(
      drafts: [testQnl5Draft, testAguasClarasDraft],
    ),
    act: (cubit) => cubit.removeDraft('place-qnl5'),
    expect: () => [
      isA<DriverServiceAreasState>().having(
        (s) => s.drafts,
        'drafts',
        [testAguasClarasDraft],
      ),
    ],
  );

  test('stops accepting drafts at ten', () {
    final cubit = DriverServiceAreasCubit(
      findMyServiceAreas: findMyServiceAreas,
      replaceMyServiceAreas: replaceMyServiceAreas,
    );
    addTearDown(cubit.close);

    for (final draft in draftsOfSize(10)) {
      cubit.addDraft(draft);
    }
    expect(cubit.state.canAddMore, isFalse);

    cubit.addDraft(testQnl5Draft);

    expect(cubit.state.drafts, hasLength(10));
  });

  blocTest<DriverServiceAreasCubit, DriverServiceAreasState>(
    'saving replaces the set and reports success',
    setUp: () => when(() => replaceMyServiceAreas.call(any())).thenAnswer(
      (_) async => const Ok([testQnl5Area, testAguasClarasArea]),
    ),
    build: buildCubit,
    seed: () => const DriverServiceAreasState(drafts: [testQnl5Draft]),
    act: (cubit) => cubit.saveAreas(),
    expect: () => [
      isA<DriverServiceAreasState>().having(
        (s) => s.status,
        'status',
        DriverServiceAreasStatus.saving,
      ),
      isA<DriverServiceAreasState>()
          .having((s) => s.status, 'status', DriverServiceAreasStatus.saved)
          .having((s) => s.saved, 'saved', hasLength(2)),
    ],
  );

  /// A tela não pode perder o que o motorista digitou por causa de uma recusa.
  blocTest<DriverServiceAreasCubit, DriverServiceAreasState>(
    'a rejected save keeps the drafts on screen',
    setUp: () => when(() => replaceMyServiceAreas.call(any())).thenAnswer(
      (_) async => const Err(ServiceAreaFailure.districtRequired),
    ),
    build: buildCubit,
    seed: () => const DriverServiceAreasState(drafts: [testQnl5Draft]),
    act: (cubit) => cubit.saveAreas(),
    expect: () => [
      isA<DriverServiceAreasState>().having(
        (s) => s.status,
        'status',
        DriverServiceAreasStatus.saving,
      ),
      isA<DriverServiceAreasState>()
          .having((s) => s.status, 'status', DriverServiceAreasStatus.ready)
          .having((s) => s.failure, 'failure', ServiceAreaFailure.districtRequired)
          .having((s) => s.drafts, 'drafts', [testQnl5Draft]),
    ],
  );

  blocTest<DriverServiceAreasCubit, DriverServiceAreasState>(
    'a failed load leaves the screen usable with a failure',
    setUp: () => when(findMyServiceAreas.call).thenAnswer(
      (_) async => const Err(ServiceAreaFailure.network),
    ),
    build: buildCubit,
    act: (cubit) => cubit.loadMyAreas(),
    expect: () => [
      const DriverServiceAreasState(status: DriverServiceAreasStatus.loading),
      const DriverServiceAreasState(
        status: DriverServiceAreasStatus.ready,
        failure: ServiceAreaFailure.network,
      ),
    ],
  );
}
