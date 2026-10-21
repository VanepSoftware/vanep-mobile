import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/dependents/data/repositories/dependent_school_days_repository_impl.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';

import '../dependents_mocks.dart';

void main() {
  late MockDependentRemoteDataSource remote;
  late DependentSchoolDaysRepositoryImpl repository;

  final week = SchoolWeek.fromDays(const [
    SchoolDay(weekday: Weekday.monday, shift: SchoolShift.afternoon),
  ]);

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    remote = MockDependentRemoteDataSource();
    repository = DependentSchoolDaysRepositoryImpl(remote: remote);
  });

  test('the loaded week is returned as Ok', () async {
    when(() => remote.fetchSchoolDays(any())).thenAnswer((_) async => week);

    final result = await repository.findSchoolDays('dep-pedro');

    expect(result.valueOrNull, week);
    verify(() => remote.fetchSchoolDays('dep-pedro')).called(1);
  });

  test('the saved week is returned as Ok', () async {
    when(
      () => remote.replaceSchoolDays(
        token: any(named: 'token'),
        week: any(named: 'week'),
      ),
    ).thenAnswer((_) async => week);

    final result = await repository.replaceSchoolDays(
      dependentToken: 'dep-pedro',
      week: week,
    );

    expect(result.valueOrNull, week);
    verify(() => remote.replaceSchoolDays(token: 'dep-pedro', week: week))
        .called(1);
  });

  test('404 maps to not found', () async {
    when(() => remote.fetchSchoolDays(any())).thenThrow(dioFailure(404));

    final result = await repository.findSchoolDays('dep-pedro');

    expect(result.errorOrNull, const DependentNotFoundFailure());
  });

  test('no response maps to a network failure', () async {
    when(() => remote.fetchSchoolDays(any())).thenThrow(dioFailure(null));

    final result = await repository.findSchoolDays('dep-pedro');

    expect(result.errorOrNull, const DependentNetworkFailure());
  });

  test('400 maps to a validation failure', () async {
    when(
      () => remote.replaceSchoolDays(
        token: any(named: 'token'),
        week: any(named: 'week'),
      ),
    ).thenThrow(dioFailure(400, body: const {'detail': 'Dia repetido.'}));

    final result = await repository.replaceSchoolDays(
      dependentToken: 'dep-pedro',
      week: week,
    );

    expect(result.errorOrNull, const DependentValidationFailure());
  });
}
