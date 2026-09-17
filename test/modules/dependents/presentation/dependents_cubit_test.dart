import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

void main() {
  late MockFindMyDependents findMyDependents;
  late MockSetDefaultDependent setDefaultDependent;
  late Completer<Result<DependentFailure, Dependent>> defaultChangeInFlight;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    findMyDependents = MockFindMyDependents();
    setDefaultDependent = MockSetDefaultDependent();
  });

  DependentsCubit buildCubit() => DependentsCubit(
    findMyDependents: findMyDependents,
    setDefaultDependent: setDefaultDependent,
  );

  void listReturns(List<Dependent> dependents) {
    when(findMyDependents.call).thenAnswer(
      (_) async => Ok<DependentFailure, List<Dependent>>(dependents),
    );
  }

  blocTest<DependentsCubit, DependentsState>(
    'loading fills the list and lands on ready',
    setUp: () => listReturns([testHelenaDependent, testMiguelDependent]),
    build: buildCubit,
    act: (cubit) => cubit.loadDependents(),
    expect: () => [
      const DependentsState(status: DependentsStatus.loading),
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
    ],
  );

  blocTest<DependentsCubit, DependentsState>(
    'an empty list is ready and empty, not a failure',
    setUp: () => listReturns(const []),
    build: buildCubit,
    act: (cubit) => cubit.loadDependents(),
    verify: (cubit) {
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.hasLoadFailed, isFalse);
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'a failed load is retryable and keeps no dependents',
    setUp: () {
      when(findMyDependents.call).thenAnswer(
        (_) async => const Err<DependentFailure, List<Dependent>>(
          DependentNetworkFailure(),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.loadDependents(),
    verify: (cubit) {
      expect(cubit.state.hasLoadFailed, isTrue);
      expect(cubit.state.isEmpty, isFalse);
      expect(cubit.state.failure, const DependentNetworkFailure());
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'choosing a default patches it and reloads',
    setUp: () {
      listReturns([testHelenaDependent, testMiguelDependent]);
      when(() => setDefaultDependent(any())).thenAnswer(
        (_) async => const Ok<DependentFailure, Dependent>(testMiguelDependent),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadDependents();
      await cubit.chooseDefault('dep-miguel');
    },
    verify: (_) {
      verify(() => setDefaultDependent('dep-miguel')).called(1);
      verify(findMyDependents.call).called(2);
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'a single dependent cannot have its default changed',
    setUp: () => listReturns([testHelenaDependent]),
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadDependents();
      await cubit.chooseDefault('dep-helena');
    },
    verify: (cubit) {
      expect(cubit.state.canChooseDefault, isFalse);
      verifyNever(() => setDefaultDependent(any()));
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'a failed default change keeps the previous default',
    setUp: () {
      listReturns([testHelenaDependent, testMiguelDependent]);
      when(() => setDefaultDependent(any())).thenAnswer(
        (_) async =>
            const Err<DependentFailure, Dependent>(DependentNetworkFailure()),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadDependents();
      await cubit.chooseDefault('dep-miguel');
    },
    verify: (cubit) {
      expect(cubit.state.defaultToken, 'dep-helena');
      expect(cubit.state.failure, const DependentNetworkFailure());
      verify(findMyDependents.call).called(1);
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'reloading a ready list does not go back to a full-page loading',
    setUp: () => listReturns([testHelenaDependent, testMiguelDependent]),
    seed: () => const DependentsState(
      status: DependentsStatus.ready,
      dependents: [testHelenaDependent, testMiguelDependent],
    ),
    build: buildCubit,
    act: (cubit) => cubit.loadDependents(),
    expect: () => <DependentsState>[],
    verify: (cubit) {
      expect(cubit.state.status, DependentsStatus.ready);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'a second default choice while one is in flight is ignored',
    setUp: () {
      defaultChangeInFlight = Completer<Result<DependentFailure, Dependent>>();
      listReturns([testHelenaDependent, testMiguelDependent]);
      when(
        () => setDefaultDependent(any()),
      ).thenAnswer((_) => defaultChangeInFlight.future);
    },
    seed: () => const DependentsState(
      status: DependentsStatus.ready,
      dependents: [testHelenaDependent, testMiguelDependent],
    ),
    build: buildCubit,
    act: (cubit) async {
      final first = cubit.chooseDefault('dep-miguel');
      await cubit.chooseDefault('dep-miguel');
      defaultChangeInFlight.complete(
        const Ok<DependentFailure, Dependent>(testMiguelDependent),
      );
      await first;
    },
    verify: (_) {
      verify(() => setDefaultDependent('dep-miguel')).called(1);
    },
  );
}
