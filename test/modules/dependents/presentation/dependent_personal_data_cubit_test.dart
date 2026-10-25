import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/create_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_field_error.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_state.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

const pedro = TestDependent(
  token: 'dep-pedro',
  name: 'Pedro Oliveira',
  birthDate: '2014-05-10',
  gender: Gender.male,
  document: '52998224725',
);

void main() {
  late MockDependentRepository repository;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    repository = MockDependentRepository();
  });

  DependentPersonalDataCubit buildCubit({Dependent? dependent}) {
    return DependentPersonalDataCubit(
      createDependent: CreateDependent(repository),
      updateDependent: UpdateDependent(repository),
      dependent: dependent,
    );
  }

  void updateReturns(Result<DependentFailure, Dependent> result) {
    when(
      () => repository.updateDependent(
        token: any(named: 'token'),
        changes: any(named: 'changes'),
      ),
    ).thenAnswer((_) async => result);
  }

  DependentChanges sentChanges() {
    return verify(
          () => repository.updateDependent(
            token: 'dep-pedro',
            changes: captureAny(named: 'changes'),
          ),
        ).captured.single
        as DependentChanges;
  }

  group('creating', () {
    test('starts blank and can save', () {
      final cubit = buildCubit();

      expect(cubit.state.draft, const DependentDraft());
      expect(cubit.state.canSave, isTrue);
    });

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'saving posts the filled fields and hands back the created dependent',
      setUp: () {
        when(
          () => repository.createDependent(any()),
        ).thenAnswer((_) async => const Ok<DependentFailure, Dependent>(pedro));
      },
      build: buildCubit,
      act: (cubit) async {
        cubit
          ..changeName('Pedro Oliveira')
          ..changeDocument('529.982.247-25');
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentEditorStatus.saved);
        expect(cubit.state.saved, pedro);
        final changes =
            verify(() => repository.createDependent(captureAny()))
                    .captured
                    .single
                as DependentChanges;
        expect(changes.touchedFields, {
          DependentField.name,
          DependentField.document,
        });
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'a blank name blocks the request',
      build: buildCubit,
      act: (cubit) => cubit.save(),
      verify: (cubit) {
        expect(
          cubit.state.errorOf(DependentField.name),
          const LocalDependentFieldError(DependentDraftError.nameRequired),
        );
        verifyNever(() => repository.createDependent(any()));
      },
    );
  });

  group('editing', () {
    test('starts from the dependent and cannot save while nothing changed', () {
      final cubit = buildCubit(dependent: pedro);

      expect(cubit.state.draft, DependentDraft.fromDependent(pedro));
      expect(cubit.state.canSave, isFalse);
    });

    test('changing a field back to the saved value disables saving again', () {
      final cubit = buildCubit(dependent: pedro)..changeName('Pedro O.');
      expect(cubit.state.canSave, isTrue);

      cubit.changeName('Pedro Oliveira');

      expect(cubit.state.canSave, isFalse);
    });

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'changing only the name patches only the name',
      setUp: () => updateReturns(const Ok(pedro)),
      build: () => buildCubit(dependent: pedro),
      act: (cubit) async {
        cubit.changeName('Pedro Oliveira Lima');
        await cubit.save();
      },
      verify: (cubit) {
        final changes = sentChanges();
        expect(changes.touchedFields, {DependentField.name});
        expect(changes.draft.name, 'Pedro Oliveira Lima');
        expect(cubit.state.status, DependentEditorStatus.saved);
        expect(cubit.state.saved, pedro);
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'clearing the CPF patches the document as cleared',
      setUp: () => updateReturns(const Ok(pedro)),
      build: () => buildCubit(dependent: pedro),
      act: (cubit) async {
        cubit.changeDocument('');
        await cubit.save();
      },
      verify: (_) {
        final changes = sentChanges();
        expect(changes.touchedFields, {DependentField.document});
        expect(normalizeDocument(changes.draft.document), isNull);
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'choosing not to inform the gender patches it as null',
      setUp: () => updateReturns(const Ok(pedro)),
      build: () => buildCubit(dependent: pedro),
      act: (cubit) async {
        cubit.changeGender(null);
        await cubit.save();
      },
      verify: (_) {
        final changes = sentChanges();
        expect(changes.touchedFields, {DependentField.gender});
        expect(changes.draft.gender, isNull);
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'an invalid CPF blocks the request',
      build: () => buildCubit(dependent: pedro),
      act: (cubit) async {
        cubit.changeDocument('111.111.111-11');
        await cubit.save();
      },
      verify: (cubit) {
        expect(
          cubit.state.errorOf(DependentField.document),
          const LocalDependentFieldError(DependentDraftError.documentInvalid),
        );
        verifyNever(
          () => repository.updateDependent(
            token: any(named: 'token'),
            changes: any(named: 'changes'),
          ),
        );
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'a future birth date blocks the request',
      build: () => buildCubit(dependent: pedro),
      act: (cubit) async {
        cubit.changeBirthDate('2999-01-01');
        await cubit.save();
      },
      verify: (cubit) {
        expect(
          cubit.state.errorOf(DependentField.birthDate),
          const LocalDependentFieldError(DependentDraftError.birthDateInFuture),
        );
        verifyNever(
          () => repository.updateDependent(
            token: any(named: 'token'),
            changes: any(named: 'changes'),
          ),
        );
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'a CPF used by another dependent keeps the draft and the back message',
      setUp: () => updateReturns(
        const Err(
          DependentRejectedFailure(
            detail: 'Já existe um dependente cadastrado com este documento.',
          ),
        ),
      ),
      build: () => buildCubit(dependent: pedro),
      act: (cubit) async {
        cubit.changeDocument('390.533.447-05');
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentEditorStatus.editing);
        expect(cubit.state.draft.document, '390.533.447-05');
        expect(
          cubit.state.failure,
          const DependentRejectedFailure(
            detail: 'Já existe um dependente cadastrado com este documento.',
          ),
        );
        expect(cubit.state.saved, isNull);
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'a backend field error lands on the matching field',
      setUp: () => updateReturns(
        const Err(
          DependentValidationFailure(
            messagesByField: {DependentField.name: 'Nome muito longo.'},
          ),
        ),
      ),
      build: () => buildCubit(dependent: pedro),
      act: (cubit) async {
        cubit.changeName('Pedro Oliveira Lima');
        await cubit.save();
      },
      verify: (cubit) {
        expect(
          cubit.state.errorOf(DependentField.name),
          const BackendDependentFieldError('Nome muito longo.'),
        );
      },
    );
  });

  group('field messages', () {
    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'leaving a field shows its error',
      build: () => buildCubit(dependent: pedro),
      act: (cubit) {
        cubit
          ..changeName('  ')
          ..validateField(DependentField.name);
      },
      verify: (cubit) {
        expect(
          cubit.state.errorOf(DependentField.name),
          const LocalDependentFieldError(DependentDraftError.nameRequired),
        );
        expect(cubit.state.errorOf(DependentField.document), isNull);
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'leaving a valid field clears its error',
      build: () => buildCubit(dependent: pedro),
      act: (cubit) {
        cubit
          ..changeDocument('111.111.111-11')
          ..validateField(DependentField.document)
          ..changeDocument('390.533.447-05')
          ..validateField(DependentField.document);
      },
      verify: (cubit) {
        expect(cubit.state.errorOf(DependentField.document), isNull);
      },
    );

    blocTest<DependentPersonalDataCubit, DependentPersonalDataState>(
      'typing clears the error of the field',
      build: buildCubit,
      act: (cubit) async {
        await cubit.save();
        cubit.changeName('Helena');
      },
      verify: (cubit) {
        expect(cubit.state.errorOf(DependentField.name), isNull);
      },
    );
  });
}
