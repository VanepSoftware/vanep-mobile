import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_state.dart';

import '../../ibge_locations/ibge_locations_mocks.dart';
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
    lookupCep: MockLookupCep(),
    listStates: MockListStates(),
    listCities: MockListCities(),
    dependent: dependent,
  );

  void createSucceeds() {
    when(() => createDependent(any())).thenAnswer(
      (_) async => const Ok<DependentFailure, Dependent>(testMiguelDependent),
    );
  }

  blocTest<DependentFormCubit, DependentFormState>(
    'a blank name blocks the request',
    build: buildCubit,
    act: (cubit) => cubit.save(),
    verify: (cubit) {
      expect(
        cubit.state.errorOf(DependentField.name),
        const LocalDependentFieldError(DependentDraftError.nameRequired),
      );
      verifyNever(() => createDependent(any()));
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'a future birth date blocks the request',
    build: buildCubit,
    act: (cubit) async {
      cubit.changeName('Helena');
      cubit.changeBirthDate('2999-01-01');
      await cubit.save();
    },
    verify: (cubit) {
      expect(
        cubit.state.errorOf(DependentField.birthDate),
        const LocalDependentFieldError(DependentDraftError.birthDateInFuture),
      );
      verifyNever(() => createDependent(any()));
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'typing a name clears its error',
    build: buildCubit,
    act: (cubit) async {
      await cubit.save();
      cubit.changeName('Helena');
    },
    verify: (cubit) {
      expect(cubit.state.errorOf(DependentField.name), isNull);
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'a valid create reaches the use case and lands on saved',
    setUp: createSucceeds,
    build: buildCubit,
    act: (cubit) async {
      cubit.changeName('Miguel');
      cubit.changeGender(Gender.male);
      await cubit.save();
    },
    verify: (cubit) {
      expect(cubit.state.status, DependentFormStatus.saved);
      final draft =
          verify(() => createDependent(captureAny())).captured.single
              as DependentDraft;
      expect(draft.name, 'Miguel');
      expect(draft.gender, Gender.male);
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'editing sends the snapshot and the draft to the update use case',
    setUp: () {
      when(
        () => updateDependent(
          snapshot: any(named: 'snapshot'),
          draft: any(named: 'draft'),
        ),
      ).thenAnswer(
        (_) async => const Ok<DependentFailure, Dependent>(testHelenaDependent),
      );
    },
    build: () => buildCubit(dependent: testHelenaDependent),
    act: (cubit) async {
      cubit.changeName('Lena');
      await cubit.save();
    },
    verify: (cubit) {
      expect(cubit.state.status, DependentFormStatus.saved);
      final draft =
          verify(
                () => updateDependent(
                  snapshot: testHelenaDependent,
                  draft: captureAny(named: 'draft'),
                ),
              ).captured.single
              as DependentDraft;
      expect(draft.name, 'Lena');
      expect(draft.gender, Gender.female);
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'saving an untouched dependent closes the form without a request',
    setUp: () {
      when(
        () => updateDependent(
          snapshot: any(named: 'snapshot'),
          draft: any(named: 'draft'),
        ),
      ).thenAnswer((_) async => null);
    },
    build: () => buildCubit(dependent: testHelenaDependent),
    act: (cubit) => cubit.save(),
    verify: (cubit) {
      expect(cubit.state.status, DependentFormStatus.saved);
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'a backend field error lands on the matching field',
    setUp: () {
      when(() => createDependent(any())).thenAnswer(
        (_) async => const Err<DependentFailure, Dependent>(
          DependentValidationFailure(
            messagesByField: {DependentField.name: 'Nome muito longo.'},
          ),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.changeName('Helena');
      await cubit.save();
    },
    verify: (cubit) {
      expect(
        cubit.state.errorOf(DependentField.name),
        const BackendDependentFieldError('Nome muito longo.'),
      );
      expect(cubit.state.status, DependentFormStatus.editing);
    },
  );

  blocTest<DependentFormCubit, DependentFormState>(
    'a network failure keeps the form open with the draft intact',
    setUp: () {
      when(() => createDependent(any())).thenAnswer(
        (_) async =>
            const Err<DependentFailure, Dependent>(DependentNetworkFailure()),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.changeName('Helena');
      cubit.changeBirthDate('2015-03-22');
      await cubit.save();
    },
    verify: (cubit) {
      expect(cubit.state.status, DependentFormStatus.editing);
      expect(cubit.state.failure, const DependentNetworkFailure());
      expect(cubit.state.draft.name, 'Helena');
      expect(cubit.state.draft.birthDate, '2015-03-22');
    },
  );
}
