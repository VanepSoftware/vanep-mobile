import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/schools/data/repositories/school_repository_impl.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

import '../schools_mocks.dart';

const delta = School(token: 'school-delta', name: 'Colégio Delta');

void main() {
  late MockSchoolRemoteDataSource remote;
  late SchoolRepositoryImpl repository;

  setUp(() {
    remote = MockSchoolRemoteDataSource();
    repository = SchoolRepositoryImpl(remote: remote);
  });

  void resolveThrows(Object error) {
    when(
      () => remote.resolveSchool(
        placeId: any(named: 'placeId'),
        sessionToken: any(named: 'sessionToken'),
      ),
    ).thenThrow(error);
  }

  Future<SchoolFailure?> resolveFailure() async {
    final result = await repository.resolveSchool(
      placeId: 'place-delta',
      sessionToken: 'sess-1',
    );
    return result.errorOrNull;
  }

  test('a resolved school is returned as Ok', () async {
    when(
      () => remote.resolveSchool(
        placeId: any(named: 'placeId'),
        sessionToken: any(named: 'sessionToken'),
      ),
    ).thenAnswer((_) async => delta);

    final result = await repository.resolveSchool(
      placeId: 'place-delta',
      sessionToken: 'sess-1',
    );

    expect(result.valueOrNull, delta);
    verify(
      () =>
          remote.resolveSchool(placeId: 'place-delta', sessionToken: 'sess-1'),
    ).called(1);
  });

  test('a place that is not a school is a rejection with the detail', () async {
    resolveThrows(
      schoolDioFailure(
        400,
        body: const {
          'detail':
              'Este local não é uma escola. Escolha uma escola nas sugestões.',
        },
      ),
    );

    expect(
      await resolveFailure(),
      const SchoolRejectedFailure(
        detail:
            'Este local não é uma escola. Escolha uma escola nas sugestões.',
      ),
    );
  });

  test('the rate limit is a rejection with the detail', () async {
    resolveThrows(
      schoolDioFailure(
        429,
        body: const {'detail': 'Muitas consultas de endereço.'},
      ),
    );

    expect(
      await resolveFailure(),
      const SchoolRejectedFailure(detail: 'Muitas consultas de endereço.'),
    );
  });

  test('a 4xx without a detail maps to unexpected', () async {
    resolveThrows(schoolDioFailure(400));

    expect(await resolveFailure(), const SchoolUnexpectedFailure());
  });

  test('a 5xx maps to unexpected', () async {
    resolveThrows(
      schoolDioFailure(502, body: const {'detail': 'Places indisponível.'}),
    );

    expect(await resolveFailure(), const SchoolUnexpectedFailure());
  });

  test('no response maps to a network failure', () async {
    resolveThrows(schoolDioFailure(null));

    expect(await resolveFailure(), const SchoolNetworkFailure());
  });

  test('an unreadable payload maps to unexpected', () async {
    resolveThrows(const FormatException('Empty school payload.'));

    expect(await resolveFailure(), const SchoolUnexpectedFailure());
  });
}
