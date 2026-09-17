import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_state.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

void main() {
  late MockCreateDependent createDependent;
  late MockUpdateDependent updateDependent;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    createDependent = MockCreateDependent();
    updateDependent = MockUpdateDependent();
  });

  DependentFormCubit buildCubit({Dependent? dependent}) => DependentFormCubit(
    createDependent: createDependent,
    updateDependent: updateDependent,
    dependent: dependent,
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'choosing a place stores the placeId and the session token',
    build: buildCubit,
    act: (cubit) => cubit.choosePlace(
      placeId: 'place-qnl5',
      sessionToken: 'session-1',
      label: 'QNL 5 Conjunto A',
    ),
    verify: (cubit) {
      final address = cubit.state.draft.address!;
      expect(address.placeId, 'place-qnl5');
      expect(address.sessionToken, 'session-1');
      expect(address.label, 'QNL 5 Conjunto A');
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'the number survives picking a different place',
    build: buildCubit,
    act: (cubit) {
      cubit.choosePlace(
        placeId: 'place-a',
        sessionToken: 'session-1',
        label: 'Rua A',
      );
      cubit.changeAddressNumber('340');
      cubit.choosePlace(
        placeId: 'place-b',
        sessionToken: 'session-2',
        label: 'Rua B',
      );
    },
    verify: (cubit) {
      expect(cubit.state.draft.address!.placeId, 'place-b');
      expect(cubit.state.draft.address!.number, '340');
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'removing the address clears it from the draft',
    build: () => buildCubit(
      dependent: const TestDependent(
        token: 'dep-1',
        name: 'Helena',
        address: TestDependentAddress(),
      ),
    ),
    act: (cubit) => cubit.removeAddress(),
    verify: (cubit) {
      expect(cubit.state.draft.address, isNull);
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'typing a number with no address selected does nothing',
    build: buildCubit,
    act: (cubit) => cubit.changeAddressNumber('340'),
    verify: (cubit) {
      expect(cubit.state.draft.address, isNull);
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'a place the backend cannot resolve lands on the address field',
    setUp: () {
      when(() => createDependent(any())).thenAnswer(
        (_) async => const Err<DependentFailure, Dependent>(
          DependentValidationFailure(
            detail: 'Não foi possível interpretar este endereço.',
            messagesByField: {
              DependentField.address:
                  'Não foi possível interpretar este endereço.',
            },
          ),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.changeName('Helena');
      cubit.changeBirthDate('2015-03-22');
      cubit.choosePlace(
        placeId: 'place-qnl5',
        sessionToken: 'session-1',
        label: 'QNL 5',
      );
      await cubit.save();
    },
    verify: (cubit) {
      expect(
        cubit.state.errorOf(DependentField.address),
        const BackendDependentFieldError(
          'Não foi possível interpretar este endereço.',
        ),
      );
      expect(cubit.state.draft.name, 'Helena');
      expect(cubit.state.draft.birthDate, '2015-03-22');
      expect(cubit.state.status, DependentFormStatus.editing);
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'a dependent saves without an address',
    setUp: () {
      when(() => createDependent(any())).thenAnswer(
        (_) async => const Ok<DependentFailure, Dependent>(testMiguelDependent),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.changeName('Miguel');
      await cubit.save();
    },
    verify: (cubit) {
      expect(cubit.state.status, DependentFormStatus.saved);
      final draft =
          verify(() => createDependent(captureAny())).captured.single
              as DependentDraft;
      expect(draft.address, isNull);
    },
  );
}
