import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driversearch/domain/entities/driver_search_page.dart';
import 'package:vanep_mobile/modules/driversearch/domain/entities/driver_search_result.dart';
import 'package:vanep_mobile/modules/driversearch/domain/failures/driver_search_failure.dart';
import 'package:vanep_mobile/modules/driversearch/domain/usecases/search_drivers_by_place.dart';
import 'package:vanep_mobile/modules/driversearch/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driversearch/presentation/cubit/driver_search_state.dart';

class MockSearchDriversByPlace extends Mock implements SearchDriversByPlace {}

const firstPage = DriverSearchPage(
  drivers: [DriverSearchResult(token: 'd1', name: 'Primeiro')],
  isLast: false,
);

const lastPage = DriverSearchPage(
  drivers: [DriverSearchResult(token: 'd2', name: 'Segundo')],
  isLast: true,
);

void main() {
  late MockSearchDriversByPlace searchDriversByPlace;

  setUp(() => searchDriversByPlace = MockSearchDriversByPlace());

  DriverSearchCubit buildCubit() =>
      DriverSearchCubit(searchDriversByPlace: searchDriversByPlace);

  void stubPage(int page, DriverSearchPage result) {
    when(
      () => searchDriversByPlace(
        any(),
        sessionToken: any(named: 'sessionToken'),
        page: page,
      ),
    ).thenAnswer((_) async => Ok(result));
  }

  blocTest<DriverSearchCubit, DriverSearchState>(
    'a first search knows there is more to load',
    setUp: () => stubPage(0, firstPage),
    build: buildCubit,
    act: (cubit) => cubit.searchPlace('place-1', label: 'QNL 5'),
    expect: () => [
      isA<DriverSearchState>().having(
        (s) => s.status,
        'status',
        DriverSearchStatus.searching,
      ),
      isA<DriverSearchState>()
          .having((s) => s.results, 'results', hasLength(1))
          .having((s) => s.hasMore, 'hasMore', isTrue)
          .having((s) => s.nextPage, 'nextPage', 1),
    ],
  );

  blocTest<DriverSearchCubit, DriverSearchState>(
    'loading more appends instead of replacing',
    setUp: () {
      stubPage(0, firstPage);
      stubPage(1, lastPage);
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.searchPlace('place-1', label: 'QNL 5');
      await cubit.loadMore();
    },
    skip: 2,
    expect: () => [
      isA<DriverSearchState>().having(
        (s) => s.status,
        'status',
        DriverSearchStatus.loadingMore,
      ),
      isA<DriverSearchState>()
          .having((s) => s.results, 'results', hasLength(2))
          .having((s) => s.hasMore, 'hasMore', isFalse),
    ],
  );

  blocTest<DriverSearchCubit, DriverSearchState>(
    'does not ask for more once the last page arrived',
    setUp: () => stubPage(0, lastPage),
    build: buildCubit,
    act: (cubit) async {
      await cubit.searchPlace('place-1', label: 'QNL 5');
      await cubit.loadMore();
    },
    verify: (_) => verifyNever(
      () => searchDriversByPlace(any(), sessionToken: any(named: 'sessionToken'), page: 1),
    ),
  );

  blocTest<DriverSearchCubit, DriverSearchState>(
    'a failed page keeps the results already loaded',
    setUp: () {
      stubPage(0, firstPage);
      when(
        () => searchDriversByPlace(
          any(),
          sessionToken: any(named: 'sessionToken'),
          page: 1,
        ),
      ).thenAnswer((_) async => const Err(DriverSearchFailure.network));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.searchPlace('place-1', label: 'QNL 5');
      await cubit.loadMore();
    },
    skip: 3,
    expect: () => [
      isA<DriverSearchState>()
          .having((s) => s.results, 'results', hasLength(1))
          .having((s) => s.failure, 'failure', DriverSearchFailure.network)
          .having((s) => s.canLoadMore, 'canLoadMore', isFalse),
    ],
  );

  blocTest<DriverSearchCubit, DriverSearchState>(
    'a failed page is not re-requested by the next scroll',
    setUp: () {
      stubPage(0, firstPage);
      when(
        () => searchDriversByPlace(
          any(),
          sessionToken: any(named: 'sessionToken'),
          page: 1,
        ),
      ).thenAnswer((_) async => const Err(DriverSearchFailure.network));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.searchPlace('place-1', label: 'QNL 5');
      await cubit.loadMore();
      await cubit.loadMore();
      await cubit.loadMore();
    },
    verify: (_) => verify(
      () => searchDriversByPlace(
        any(),
        sessionToken: any(named: 'sessionToken'),
        page: 1,
      ),
    ).called(1),
  );

  blocTest<DriverSearchCubit, DriverSearchState>(
    'an explicit retry resumes the pagination that failed',
    setUp: () {
      stubPage(0, firstPage);
      var attempts = 0;
      when(
        () => searchDriversByPlace(
          any(),
          sessionToken: any(named: 'sessionToken'),
          page: 1,
        ),
      ).thenAnswer((_) async {
        attempts += 1;
        if (attempts == 1) {
          return const Err<DriverSearchFailure, DriverSearchPage>(
            DriverSearchFailure.network,
          );
        }
        return const Ok<DriverSearchFailure, DriverSearchPage>(lastPage);
      });
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.searchPlace('place-1', label: 'QNL 5');
      await cubit.loadMore();
      await cubit.retryLoadMore();
    },
    verify: (cubit) {
      expect(cubit.state.status, DriverSearchStatus.loaded);
      expect(cubit.state.results, hasLength(2));
      expect(cubit.state.failure, isNull);
    },
  );

  blocTest<DriverSearchCubit, DriverSearchState>(
    'a new search starts the pagination over',
    setUp: () => stubPage(0, firstPage),
    build: buildCubit,
    act: (cubit) async {
      await cubit.searchPlace('place-1', label: 'QNL 5');
      await cubit.searchPlace('place-2', label: 'Taguatinga');
    },
    verify: (cubit) {
      expect(cubit.state.nextPage, 1);
      expect(cubit.state.results, hasLength(1));
    },
  );
}
