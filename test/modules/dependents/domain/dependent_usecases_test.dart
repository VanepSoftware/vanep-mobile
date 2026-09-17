import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/create_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/set_default_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

void main() {
  late MockDependentRepository repository;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    repository = MockDependentRepository();
  });

  test('FindMyDependents returns what the repository returns', () async {
    when(repository.findMyDependents).thenAnswer(
      (_) async => const Ok<DependentFailure, List<Dependent>>([
        testHelenaDependent,
        testMiguelDependent,
      ]),
    );

    final result = await FindMyDependents(repository)();

    expect(result.valueOrNull, [testHelenaDependent, testMiguelDependent]);
  });

  test('FindMyDependents forwards a failure', () async {
    when(repository.findMyDependents).thenAnswer(
      (_) async =>
          const Err<DependentFailure, List<Dependent>>(
            DependentNetworkFailure(),
          ),
    );

    final result = await FindMyDependents(repository)();

    expect(result.errorOrNull, const DependentNetworkFailure());
  });

  test('CreateDependent sends the changes built from the draft', () async {
    when(() => repository.createDependent(any())).thenAnswer(
      (_) async => const Ok<DependentFailure, Dependent>(testMiguelDependent),
    );

    await CreateDependent(repository)(const DependentDraft(name: 'Miguel'));

    final captured =
        verify(() => repository.createDependent(captureAny())).captured.single
            as DependentChanges;
    expect(captured.touchedFields, {DependentField.name});
    expect(captured.draft.name, 'Miguel');
  });

  test('UpdateDependent sends only the changed fields', () async {
    when(
      () => repository.updateDependent(
        token: any(named: 'token'),
        changes: any(named: 'changes'),
      ),
    ).thenAnswer(
      (_) async => const Ok<DependentFailure, Dependent>(testHelenaDependent),
    );

    await UpdateDependent(repository)(
      snapshot: testHelenaDependent,
      draft: DependentDraft.fromDependent(testHelenaDependent).withName('Lena'),
    );

    final captured = verify(
      () => repository.updateDependent(
        token: 'dep-helena',
        changes: captureAny(named: 'changes'),
      ),
    ).captured.single as DependentChanges;
    expect(captured.touchedFields, {DependentField.name});
  });

  test('UpdateDependent sends nothing when the draft is unchanged', () async {
    final result = await UpdateDependent(repository)(
      snapshot: testHelenaDependent,
      draft: DependentDraft.fromDependent(testHelenaDependent),
    );

    expect(result, isNull);
    verifyNever(
      () => repository.updateDependent(
        token: any(named: 'token'),
        changes: any(named: 'changes'),
      ),
    );
  });

  test('SetDefaultDependent asks the repository for that token', () async {
    when(() => repository.markAsDefault(any())).thenAnswer(
      (_) async => const Ok<DependentFailure, Dependent>(testMiguelDependent),
    );

    await SetDefaultDependent(repository)('dep-miguel');

    verify(() => repository.markAsDefault('dep-miguel')).called(1);
  });
}
