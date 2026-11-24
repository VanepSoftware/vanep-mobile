import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_students_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

import '../../fixtures/assistant_fixtures.dart';

class MockAssistantRemoteDataSource extends Mock
    implements AssistantRemoteDataSource {}

AssistantVanSummary summaryOf(AssistantVan van) =>
    AssistantVanSummary(van: van, studentCount: 0, hasRouteToday: false);

void main() {
  late MockAssistantRemoteDataSource remote;
  late AssistantStudentsRepositoryImpl repository;

  const vanWithoutShift = AssistantVan(
    token: 'van-token-primary',
    driverToken: 'driver-token-1',
    driverName: 'João Motorista',
    plate: 'ABC-1234',
    model: 'Mercedes Sprinter 2024',
  );

  setUp(() {
    remote = MockAssistantRemoteDataSource();
    repository = AssistantStudentsRepositoryImpl(remote: remote);
  });

  test('builds one roster per shift with its students', () async {
    when(() => remote.fetchVanSummaries()).thenAnswer(
      (_) async => [
        summaryOf(testAssistantVanPrimary),
        summaryOf(testAssistantVanSecondary),
      ],
    );
    when(() => remote.fetchStudents('van-token-primary', 'MORNING'))
        .thenAnswer((_) async => [testAssistantStudentAna]);
    when(
      () => remote.fetchStudents(
        testAssistantVanSecondary.token,
        testAssistantVanSecondary.shift!,
      ),
    ).thenAnswer((_) async => [testAssistantStudentLais]);

    final overview = (await repository.findStudentsOverview()).valueOrNull!;

    expect(overview.rosters.map((roster) => roster.van), [
      testAssistantVanPrimary,
      testAssistantVanSecondary,
    ]);
    expect(overview.rosters.first.students, [testAssistantStudentAna]);
    expect(overview.rosters.last.students, [testAssistantStudentLais]);
  });

  test('skips a van that has no shift yet', () async {
    when(() => remote.fetchVanSummaries())
        .thenAnswer((_) async => [summaryOf(vanWithoutShift)]);

    final overview = (await repository.findStudentsOverview()).valueOrNull!;

    expect(overview.rosters, isEmpty);
    verifyNever(() => remote.fetchStudents(any(), any()));
  });

  test('fails when a request fails', () async {
    when(() => remote.fetchVanSummaries())
        .thenAnswer((_) async => [summaryOf(testAssistantVanPrimary)]);
    when(() => remote.fetchStudents(any(), any()))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

    final result = await repository.findStudentsOverview();

    expect(result.errorOrNull, AssistantFailure.network);
  });
}
