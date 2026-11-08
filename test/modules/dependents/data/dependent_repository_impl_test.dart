import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/dependents/data/repositories/dependent_repository_impl.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

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

  test(
    '400 with the generic Spring detail is not attributed to a field',
    () async {
      when(() => remote.createDependent(any())).thenThrow(
        dioFailure(400, body: const {'detail': 'Invalid request content.'}),
      );

      final result = await repository.createDependent(
        buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
      );

      final failure = result.errorOrNull! as DependentValidationFailure;
      expect(failure.isAttributedToAField, isFalse);
    },
  );

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
        body: const {'detail': 'Telefone muito longo.', 'field': 'phone'},
      ),
    );

    final result = await repository.createDependent(
      buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
    );

    final failure = result.errorOrNull! as DependentValidationFailure;
    expect(failure.isAttributedToAField, isFalse);
  });

  test('a placeId field is no longer attributed to the address', () async {
    when(() => remote.createDependent(any())).thenThrow(
      dioFailure(
        400,
        body: const {'detail': 'placeId inválido.', 'field': 'placeId'},
      ),
    );

    final result = await repository.createDependent(
      buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
    );

    final failure = result.errorOrNull! as DependentValidationFailure;
    expect(failure.isAttributedToAField, isFalse);
  });

  group('404', () {
    const cityNotFoundProblem = {
      'detail': 'Cidade não encontrada.',
      'code': 'city.not_found',
    };
    const dependentNotFoundProblem = {
      'detail': 'Dependente não encontrado.',
      'code': 'dependent.not_found',
    };

    Future<DependentFailure?> patchWith(Object? body) async {
      when(
        () => remote.updateDependent(
          token: any(named: 'token'),
          changes: any(named: 'changes'),
        ),
      ).thenThrow(dioFailure(404, body: body));
      final result = await repository.updateDependent(
        token: 'dep-helena',
        changes: buildDependentChangesForCreate(
          const DependentDraft(name: 'Helena'),
        ),
      );
      return result.errorOrNull;
    }

    test('on create is always the city', () async {
      when(
        () => remote.createDependent(any()),
      ).thenThrow(dioFailure(404, body: dependentNotFoundProblem));

      final result = await repository.createDependent(
        buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
      );

      expect(result.errorOrNull, const DependentCityNotFoundFailure());
    });

    test('on update with the city code is the city', () async {
      expect(
        await patchWith(cityNotFoundProblem),
        const DependentCityNotFoundFailure(),
      );
    });

    test('on update without the city code is the dependent', () async {
      expect(
        await patchWith(dependentNotFoundProblem),
        const DependentNotFoundFailure(),
      );
    });

    test('on update without a body is the dependent', () async {
      expect(await patchWith(null), const DependentNotFoundFailure());
    });
  });

  test('409 carries the detail of the back', () async {
    when(() => remote.createDependent(any())).thenThrow(
      dioFailure(
        409,
        body: const {
          'detail': 'Já existe um dependente cadastrado com este documento.',
        },
      ),
    );

    final result = await repository.createDependent(
      buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
    );

    expect(
      result.errorOrNull,
      const DependentRejectedFailure(
        detail: 'Já existe um dependente cadastrado com este documento.',
      ),
    );
  });

  test('409 without a detail maps to unexpected', () async {
    when(() => remote.createDependent(any())).thenThrow(dioFailure(409));

    final result = await repository.createDependent(
      buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
    );

    expect(result.errorOrNull, const DependentUnexpectedFailure());
  });

  group('removeDependent', () {
    test('a removal is returned as Ok', () async {
      when(() => remote.removeDependent(any())).thenAnswer((_) async {});

      final result = await repository.removeDependent('dep-helena');

      expect(result.isOk, isTrue);
      verify(() => remote.removeDependent('dep-helena')).called(1);
    });

    test('422 with an open request carries the detail of the back', () async {
      when(() => remote.removeDependent(any())).thenThrow(
        dioFailure(
          422,
          body: const {
            'detail': 'O dependente está em um pedido de orçamento aberto.',
            'code': 'dependent.open_negotiation',
          },
        ),
      );

      final result = await repository.removeDependent('dep-helena');

      expect(
        result.errorOrNull,
        const DependentRejectedFailure(
          detail: 'O dependente está em um pedido de orçamento aberto.',
        ),
      );
    });

    test('404 maps to not found', () async {
      when(() => remote.removeDependent(any())).thenThrow(dioFailure(404));

      final result = await repository.removeDependent('dep-helena');

      expect(result.errorOrNull, const DependentNotFoundFailure());
    });

    test('no response maps to a network failure', () async {
      when(() => remote.removeDependent(any())).thenThrow(dioFailure(null));

      final result = await repository.removeDependent('dep-helena');

      expect(result.errorOrNull, const DependentNetworkFailure());
    });
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
