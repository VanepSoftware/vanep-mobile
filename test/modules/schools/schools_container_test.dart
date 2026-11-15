import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/schools/domain/repositories/school_repository.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';
import 'package:vanep_mobile/modules/schools/schools_container.dart';

import 'schools_mocks.dart';

void main() {
  test('registers the repository and ResolveSchool', () {
    final getIt = GetIt.asNewInstance()
      ..registerSingleton<Environment>(testSchoolsEnvironment)
      ..registerSingleton<Dio>(Dio(), instanceName: authenticatedDioName);

    registerSchoolsDependencies(getIt);

    expect(getIt<SchoolRepository>(), isA<SchoolRepository>());
    expect(getIt<ResolveSchool>(), isA<ResolveSchool>());
  });
}
