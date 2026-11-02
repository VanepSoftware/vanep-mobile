import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';
import 'package:vanep_mobile/modules/dependents/data/datasources/dependent_remote_datasource.dart';
import 'package:vanep_mobile/modules/dependents/data/repositories/dependent_repository_impl.dart';
import 'package:vanep_mobile/modules/dependents/data/repositories/dependent_school_days_repository_impl.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_school_days_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/create_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/remove_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/replace_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/set_default_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_detail_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';

void registerDependentsDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<DependentRemoteDataSource>(
      DependentRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<DependentRepository>(
      DependentRepositoryImpl(remote: getIt<DependentRemoteDataSource>()),
    )
    ..registerSingleton<DependentSchoolDaysRepository>(
      DependentSchoolDaysRepositoryImpl(
        remote: getIt<DependentRemoteDataSource>(),
      ),
    )
    ..registerFactory<FindMyDependents>(
      () => FindMyDependents(getIt<DependentRepository>()),
    )
    ..registerFactory<CreateDependent>(
      () => CreateDependent(getIt<DependentRepository>()),
    )
    ..registerFactory<UpdateDependent>(
      () => UpdateDependent(getIt<DependentRepository>()),
    )
    ..registerFactory<SetDefaultDependent>(
      () => SetDefaultDependent(getIt<DependentRepository>()),
    )
    ..registerFactory<RemoveDependent>(
      () => RemoveDependent(getIt<DependentRepository>()),
    )
    ..registerFactory<FindSchoolDays>(
      () => FindSchoolDays(getIt<DependentSchoolDaysRepository>()),
    )
    ..registerFactory<ReplaceSchoolDays>(
      () => ReplaceSchoolDays(getIt<DependentSchoolDaysRepository>()),
    )
    ..registerFactory<DependentsCubit>(
      () => DependentsCubit(
        findMyDependents: getIt<FindMyDependents>(),
        setDefaultDependent: getIt<SetDefaultDependent>(),
        deleteDependent: getIt<RemoveDependent>(),
        findContractReadiness: getIt<FindContractReadiness>(),
      ),
    )
    ..registerFactoryParam<DependentDetailCubit, String, void>(
      (dependentToken, _) => DependentDetailCubit(
        dependentToken: dependentToken,
        findSchoolDays: getIt<FindSchoolDays>(),
      ),
    )
    ..registerFactoryParam<DependentPersonalDataCubit, Dependent?, void>(
      (dependent, _) => DependentPersonalDataCubit(
        createDependent: getIt<CreateDependent>(),
        updateDependent: getIt<UpdateDependent>(),
        dependent: dependent,
      ),
    )
    ..registerFactoryParam<DependentSchoolCubit, Dependent, void>(
      (dependent, _) => DependentSchoolCubit(
        dependent: dependent,
        autocomplete: PlaceAutocompleteController(
          datasource: getIt<PlaceAutocompleteDataSource>(),
          includedPrimaryTypes: schoolPlacePrimaryTypes,
        ),
        resolveSchool: getIt<ResolveSchool>(),
        updateDependent: getIt<UpdateDependent>(),
      ),
    )
    ..registerFactoryParam<DependentPickupCubit, Dependent, void>(
      (dependent, _) => DependentPickupCubit(
        dependent: dependent,
        updateDependent: getIt<UpdateDependent>(),
        lookupCep: getIt<LookupCep>(),
        listStates: getIt<ListStates>(),
        listCities: getIt<ListCities>(),
      ),
    )
    ..registerFactoryParam<DependentSchoolDaysCubit, String, void>(
      (dependentToken, _) => DependentSchoolDaysCubit(
        dependentToken: dependentToken,
        findSchoolDays: getIt<FindSchoolDays>(),
        replaceSchoolDays: getIt<ReplaceSchoolDays>(),
      ),
    );
}
