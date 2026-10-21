import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

const helenaNotDefault = TestDependent(
  token: 'dep-helena',
  name: 'Helena Souza',
  birthDate: '2015-03-22',
  gender: Gender.female,
);

const miguelAsDefault = TestDependent(
  token: 'dep-miguel',
  name: 'Miguel Souza',
  birthDate: '2018-11-04',
  gender: Gender.male,
  isDefault: true,
);

const helenaMissingSchool = ContractReadiness(
  ready: false,
  gaps: [
    ReadinessGap(
      subject: ContractReadinessSubject.client,
      field: ContractReadinessField.phone,
    ),
    ReadinessGap(
      subject: ContractReadinessSubject.dependent,
      dependentToken: 'dep-helena',
      field: ContractReadinessField.school,
    ),
  ],
);

const everyoneReady = ContractReadiness(ready: true, gaps: []);

void main() {
  late MockFindMyDependents findMyDependents;
  late MockSetDefaultDependent setDefaultDependent;
  late MockRemoveDependent removeDependent;
  late MockFindContractReadiness findContractReadiness;
  late Completer<Result<DependentFailure, Dependent>> defaultChangeInFlight;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    findMyDependents = MockFindMyDependents();
    setDefaultDependent = MockSetDefaultDependent();
    removeDependent = MockRemoveDependent();
    findContractReadiness = MockFindContractReadiness();
    when(() => findContractReadiness(any())).thenAnswer(
      (_) async =>
          const Ok<ContractReadinessFailure, ContractReadiness>(everyoneReady),
    );
  });

  DependentsCubit buildCubit() => DependentsCubit(
    findMyDependents: findMyDependents,
    setDefaultDependent: setDefaultDependent,
    deleteDependent: removeDependent,
    findContractReadiness: findContractReadiness,
  );

  void listReturns(List<Dependent> dependents) {
    when(findMyDependents.call).thenAnswer(
      (_) async => Ok<DependentFailure, List<Dependent>>(dependents),
    );
  }

  void readinessReturns(ContractReadiness readiness) {
    when(() => findContractReadiness(any())).thenAnswer(
      (_) async => Ok<ContractReadinessFailure, ContractReadiness>(readiness),
    );
  }

  blocTest<DependentsCubit, DependentsState>(
    'loading fills the list with its readiness and lands on ready',
    setUp: () {
      listReturns([testHelenaDependent, testMiguelDependent]);
      readinessReturns(helenaMissingSchool);
    },
    build: buildCubit,
    act: (cubit) => cubit.loadDependents(),
    expect: () => [
      const DependentsState(status: DependentsStatus.loading),
      const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
        readinessByToken: {
          'dep-helena': {ContractReadinessField.school},
          'dep-miguel': {},
        },
      ),
    ],
    verify: (cubit) {
      verify(() => findContractReadiness(['dep-helena', 'dep-miguel']))
          .called(1);
      expect(cubit.state.isIncomplete('dep-helena'), isTrue);
      expect(cubit.state.isIncomplete('dep-miguel'), isFalse);
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'an empty list is ready and empty, and asks for no readiness',
    setUp: () => listReturns(const []),
    build: buildCubit,
    act: (cubit) => cubit.loadDependents(),
    verify: (cubit) {
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.hasLoadFailed, isFalse);
      verifyNever(() => findContractReadiness(any()));
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'a failed readiness keeps the list loaded and the readiness unavailable',
    setUp: () {
      listReturns([testHelenaDependent, testMiguelDependent]);
      when(() => findContractReadiness(any())).thenAnswer(
        (_) async => const Err<ContractReadinessFailure, ContractReadiness>(
          ContractReadinessFailure.network,
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.loadDependents(),
    verify: (cubit) {
      expect(cubit.state.status, DependentsStatus.ready);
      expect(cubit.state.dependents, hasLength(2));
      expect(cubit.state.readinessByToken, isNull);
      expect(cubit.state.gapsOf('dep-helena'), isNull);
      expect(cubit.state.isIncomplete('dep-helena'), isFalse);
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
      verifyNever(() => findContractReadiness(any()));
    },
  );

  blocTest<DependentsCubit, DependentsState>(
    'choosing a default patches it and both rows show the new default',
    setUp: () {
      final lists = [
        [testHelenaDependent, testMiguelDependent],
        [helenaNotDefault, miguelAsDefault],
      ];
      when(findMyDependents.call).thenAnswer(
        (_) async => Ok<DependentFailure, List<Dependent>>(lists.removeAt(0)),
      );
      when(() => setDefaultDependent(any())).thenAnswer(
        (_) async => const Ok<DependentFailure, Dependent>(miguelAsDefault),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.loadDependents();
      await cubit.chooseDefault('dep-miguel');
    },
    verify: (cubit) {
      verify(() => setDefaultDependent('dep-miguel')).called(1);
      expect(cubit.state.defaultToken, 'dep-miguel');
      expect(cubit.state.dependentOf('dep-helena')!.isDefault, isFalse);
      expect(cubit.state.dependentOf('dep-miguel')!.isDefault, isTrue);
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
      readinessByToken: {'dep-helena': {}, 'dep-miguel': {}},
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
      when(() => setDefaultDependent(any()))
          .thenAnswer((_) => defaultChangeInFlight.future);
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

  group('changes from the editors', () {
    const miguelRenamed = TestDependent(
      token: 'dep-miguel',
      name: 'Miguel S. Souza',
    );

    blocTest<DependentsCubit, DependentsState>(
      'replaceDependent swaps the row in place',
      seed: () => const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testMiguelDependent, testHelenaDependent],
      ),
      build: buildCubit,
      act: (cubit) => cubit.replaceDependent(miguelRenamed),
      expect: () => [
        const DependentsState(
          status: DependentsStatus.ready,
          dependents: [miguelRenamed, testHelenaDependent],
        ),
      ],
    );

    blocTest<DependentsCubit, DependentsState>(
      'addDependent puts the new dependent at the end, as the back does',
      seed: () => const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent],
      ),
      build: buildCubit,
      act: (cubit) => cubit.addDependent(testMiguelDependent),
      expect: () => [
        const DependentsState(
          status: DependentsStatus.ready,
          dependents: [testHelenaDependent, testMiguelDependent],
        ),
      ],
    );

    blocTest<DependentsCubit, DependentsState>(
      'addDependent leaves the empty state',
      seed: () => const DependentsState(status: DependentsStatus.ready),
      build: buildCubit,
      act: (cubit) => cubit.addDependent(testHelenaDependent),
      verify: (cubit) {
        expect(cubit.state.isEmpty, isFalse);
        expect(cubit.state.dependents, [testHelenaDependent]);
      },
    );

    blocTest<DependentsCubit, DependentsState>(
      'refreshReadiness asks again for every row after a change',
      setUp: () => readinessReturns(everyoneReady),
      seed: () => const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
        readinessByToken: {
          'dep-helena': {ContractReadinessField.school},
          'dep-miguel': {},
        },
      ),
      build: buildCubit,
      act: (cubit) => cubit.refreshReadiness(),
      expect: () => [
        const DependentsState(
          status: DependentsStatus.ready,
          dependents: [testHelenaDependent, testMiguelDependent],
          readinessByToken: {'dep-helena': {}, 'dep-miguel': {}},
        ),
      ],
      verify: (_) {
        verify(() => findContractReadiness(['dep-helena', 'dep-miguel']))
            .called(1);
      },
    );
  });

  group('removeDependent', () {
    blocTest<DependentsCubit, DependentsState>(
      'deletes and reloads to show the default the back promoted',
      setUp: () {
        when(() => removeDependent(any()))
            .thenAnswer((_) async => const Ok<DependentFailure, void>(null));
        listReturns([miguelAsDefault]);
      },
      seed: () => const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
      build: buildCubit,
      act: (cubit) async {
        expect(await cubit.removeDependent('dep-helena'), isNull);
      },
      verify: (cubit) {
        verify(() => removeDependent('dep-helena')).called(1);
        expect(cubit.state.dependents, [miguelAsDefault]);
        expect(cubit.state.defaultToken, 'dep-miguel');
      },
    );

    blocTest<DependentsCubit, DependentsState>(
      'a failure is returned and the list stays as it was',
      setUp: () {
        when(() => removeDependent(any())).thenAnswer(
          (_) async => const Err<DependentFailure, void>(
            DependentRejectedFailure(detail: 'Pedido de orçamento aberto.'),
          ),
        );
      },
      seed: () => const DependentsState(
        status: DependentsStatus.ready,
        dependents: [testHelenaDependent, testMiguelDependent],
      ),
      build: buildCubit,
      act: (cubit) async {
        expect(
          await cubit.removeDependent('dep-helena'),
          const DependentRejectedFailure(detail: 'Pedido de orçamento aberto.'),
        );
      },
      expect: () => <DependentsState>[],
      verify: (_) {
        verifyNever(findMyDependents.call);
      },
    );
  });
}
