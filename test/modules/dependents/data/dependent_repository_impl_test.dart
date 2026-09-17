import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/dependents/data/repositories/dependent_repository_impl.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

DioException dioFailure(int? status, {Object? body}) {
  final requestOptions = RequestOptions(path: '/api/dependent');
  return DioException(
    requestOptions: requestOptions,
    response: status == null
        ? null
        : Response<Object?>(
            requestOptions: requestOptions,
            statusCode: status,
            data: body,
          ),
  );
}

void main() {
  late MockDependentRemoteDataSource remote;
  late DependentRepositoryImpl repository;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    remote = MockDependentRemoteDataSource();
    repository = DependentRepositoryImpl(remote: remote);
  });

  test('a successful list is returned as Ok', () async {
    when(remote.fetchMyDependents).thenAnswer(
      (_) async => <Dependent>[testHelenaDependent, testMiguelDependent],
    );

    final result = await repository.findMyDependents();

    expect(result.valueOrNull, hasLength(2));
  });

  test('no response maps to a network failure', () async {
    when(remote.fetchMyDependents).thenThrow(dioFailure(null));

    final result = await repository.findMyDependents();

    expect(result.errorOrNull, const DependentNetworkFailure());
  });

  test('404 maps to not found', () async {
    when(() => remote.markAsDefault(any())).thenThrow(dioFailure(404));

    final result = await repository.markAsDefault('dep-helena');

    expect(result.errorOrNull, const DependentNotFoundFailure());
  });

  test('500 maps to unexpected', () async {
    when(remote.fetchMyDependents).thenThrow(dioFailure(500));

    final result = await repository.findMyDependents();

    expect(result.errorOrNull, const DependentUnexpectedFailure());
  });

  test('400 carries the backend detail', () async {
    when(() => remote.createDependent(any())).thenThrow(
      dioFailure(400, body: const {'detail': 'O nome não pode ficar em branco.'}),
    );

    final result = await repository.createDependent(
      buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
    );

    final failure = result.errorOrNull! as DependentValidationFailure;
    expect(failure.detail, 'O nome não pode ficar em branco.');
    expect(failure.isAttributedToAField, isFalse);
  });

  test('400 naming a known field attributes the message to it', () async {
    when(() => remote.createDependent(any())).thenThrow(
      dioFailure(
        400,
        body: const {'detail': 'Nome muito longo.', 'field': 'name'},
      ),
    );

    final result = await repository.createDependent(
      buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
    );

    final failure = result.errorOrNull! as DependentValidationFailure;
    expect(failure.messagesByField[DependentField.name], 'Nome muito longo.');
  });

  test('400 naming an unknown field stays unattributed', () async {
    when(() => remote.createDependent(any())).thenThrow(
      dioFailure(
        400,
        body: const {'detail': 'Documento duplicado.', 'field': 'document'},
      ),
    );

    final result = await repository.createDependent(
      buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
    );

    final failure = result.errorOrNull! as DependentValidationFailure;
    expect(failure.isAttributedToAField, isFalse);
    expect(failure.detail, 'Documento duplicado.');
  });

  test('an unreadable payload maps to unexpected', () async {
    when(
      () => remote.updateDependent(
        token: any(named: 'token'),
        changes: any(named: 'changes'),
      ),
    ).thenThrow(const FormatException('Empty dependent payload.'));

    final result = await repository.updateDependent(
      token: 'dep-helena',
      changes: buildDependentChangesForCreate(
        const DependentDraft(name: 'Helena'),
      ),
    );

    expect(result.errorOrNull, const DependentUnexpectedFailure());
  });
}
