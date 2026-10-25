import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/dependents/dependents_container.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_school_days_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/remove_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/replace_school_days.dart';

import 'dependents_mocks.dart';

void main() {
  test('registers the school days repository and the new use cases', () {
    final getIt = GetIt.asNewInstance()
      ..registerSingleton<Environment>(testDependentsEnvironment)
      ..registerSingleton<Dio>(Dio(), instanceName: authenticatedDioName);

    registerDependentsDependencies(getIt);

    expect(
      getIt<DependentSchoolDaysRepository>(),
      isA<DependentSchoolDaysRepository>(),
    );
    expect(getIt<FindSchoolDays>(), isA<FindSchoolDays>());
    expect(getIt<ReplaceSchoolDays>(), isA<ReplaceSchoolDays>());
    expect(getIt<RemoveDependent>(), isA<RemoveDependent>());
  });
}
