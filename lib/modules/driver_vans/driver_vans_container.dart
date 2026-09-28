import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/environment/environment.dart';
import '../../core/media/photo_picker.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/photo_uploader.dart';
import 'data/datasources/driver_van_remote_datasource.dart';
import 'data/repositories/driver_van_repository_impl.dart';
import 'domain/repositories/driver_van_repository.dart';
import 'domain/usecases/change_van_photo.dart';
import 'domain/usecases/list_my_vans.dart';
import 'domain/usecases/register_van.dart';
import 'presentation/cubit/driver_vans_cubit.dart';

void registerDriverVansDependencies(GetIt getIt) {
  getIt
    ..registerSingleton<DriverVanRemoteDataSource>(
      DriverVanRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: getIt<Environment>(),
        photoUploader: getIt<PhotoUploader>(),
      ),
    )
    ..registerSingleton<DriverVanRepository>(
      DriverVanRepositoryImpl(remote: getIt<DriverVanRemoteDataSource>()),
    )
    ..registerFactory<ListMyVans>(
      () => ListMyVans(getIt<DriverVanRepository>()),
    )
    ..registerFactory<RegisterVan>(
      () => RegisterVan(getIt<DriverVanRepository>()),
    )
    ..registerFactory<ChangeVanPhoto>(
      () => ChangeVanPhoto(getIt<DriverVanRepository>()),
    )
    ..registerFactory<DriverVansCubit>(
      () => DriverVansCubit(
        listMyVans: getIt<ListMyVans>(),
        registerVan: getIt<RegisterVan>(),
        changeVanPhoto: getIt<ChangeVanPhoto>(),
        photoPicker: getIt<PhotoPicker>(),
      ),
    );
}
