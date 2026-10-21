import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/schools/data/datasources/school_remote_datasource.dart';
import 'package:vanep_mobile/modules/schools/data/repositories/school_repository_impl.dart';
import 'package:vanep_mobile/modules/schools/domain/repositories/school_repository.dart';
import 'package:vanep_mobile/modules/schools/domain/usecases/resolve_school.dart';

void registerSchoolsDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<SchoolRemoteDataSource>(
      SchoolRemoteDataSource(dio: authenticatedDio, environment: environment),
    )
    ..registerSingleton<SchoolRepository>(
      SchoolRepositoryImpl(remote: getIt<SchoolRemoteDataSource>()),
    )
    ..registerFactory<ResolveSchool>(
      () => ResolveSchool(getIt<SchoolRepository>()),
    );
}
