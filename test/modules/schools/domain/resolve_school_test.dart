import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';

import '../schools_mocks.dart';

void main() {
  test('ResolveSchool forwards the result of the repository', () async {
    final repository = MockSchoolRepository();
    when(
      () => repository.resolveSchool(
        placeId: any(named: 'placeId'),
        sessionToken: any(named: 'sessionToken'),
      ),
    ).thenAnswer(
      (_) async => const Ok<SchoolFailure, School>(
        School(token: 'school-delta', name: 'Colégio Delta'),
      ),
    );

    final result = await ResolveSchool(repository)(
      placeId: 'place-delta',
      sessionToken: 'sess-1',
    );

    expect(
      result.valueOrNull,
      const School(token: 'school-delta', name: 'Colégio Delta'),
    );
    verify(
      () => repository.resolveSchool(
        placeId: 'place-delta',
        sessionToken: 'sess-1',
      ),
    ).called(1);
  });
}
