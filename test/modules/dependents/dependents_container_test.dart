import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/places/places_container.dart';
import 'package:vanep_mobile/modules/contract_readiness/contract_readiness_container.dart';
import 'package:vanep_mobile/modules/dependents/dependents_container.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_school_days_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/remove_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/replace_school_days.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_detail_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/ibge_locations/ibge_locations_container.dart';
import 'package:vanep_mobile/modules/schools/schools_container.dart';

import 'dependents_fixtures.dart';
import 'dependents_mocks.dart';

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance()
      ..registerSingleton<Environment>(testDependentsEnvironment)
      ..registerSingleton<Dio>(Dio(), instanceName: authenticatedDioName);
    registerPlacesDependencies(getIt, platform: TargetPlatform.android);
    registerIbgeLocationsDependencies(getIt);
    registerSchoolsDependencies(getIt);
    registerContractReadinessDependencies(getIt);
    registerDependentsDependencies(getIt);
  });

  test('registers the school days repository and the new use cases', () {
    expect(
      getIt<DependentSchoolDaysRepository>(),
      isA<DependentSchoolDaysRepository>(),
    );
    expect(getIt<FindSchoolDays>(), isA<FindSchoolDays>());
    expect(getIt<ReplaceSchoolDays>(), isA<ReplaceSchoolDays>());
    expect(getIt<RemoveDependent>(), isA<RemoveDependent>());
  });

  test('resolves the list, the detail and every editor cubit', () {
    expect(getIt<DependentsCubit>(), isA<DependentsCubit>());
    expect(
      getIt<DependentDetailCubit>(param1: 'dep-helena').dependentToken,
      'dep-helena',
    );
    expect(
      getIt<DependentPersonalDataCubit>(param1: null).state.snapshot,
      isNull,
    );
    expect(
      getIt<DependentPersonalDataCubit>(param1: testHelenaDependent)
          .state
          .snapshot,
      testHelenaDependent,
    );
    expect(
      getIt<DependentSchoolCubit>(param1: testHelenaDependent)
          .autocomplete
          .includedPrimaryTypes,
      schoolPlacePrimaryTypes,
    );
    expect(
      getIt<DependentPickupCubit>(param1: testHelenaDependent).state.snapshot,
      testHelenaDependent,
    );
    expect(
      getIt<DependentSchoolDaysCubit>(param1: 'dep-helena').dependentToken,
      'dep-helena',
    );
  });
}
