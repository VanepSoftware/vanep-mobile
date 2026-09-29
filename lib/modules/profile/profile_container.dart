import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/environment/environment.dart';
import '../../core/media/photo_picker.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/photo_uploader.dart';
import 'data/datasources/profile_summary_remote_datasource.dart';
import 'data/repositories/profile_summary_repository_impl.dart';
import 'domain/repositories/profile_summary_repository.dart';
import 'domain/usecases/change_profile_photo.dart';
import 'domain/usecases/get_profile_summary.dart';
import 'presentation/cubit/profile_photo_cubit.dart';
import 'presentation/cubit/profile_summary_cubit.dart';

void registerProfileDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<ProfileSummaryRemoteDataSource>(
      ProfileSummaryRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
        photoUploader: getIt<PhotoUploader>(),
      ),
    )
    ..registerSingleton<ProfileSummaryRepository>(
      ProfileSummaryRepositoryImpl(
        remote: getIt<ProfileSummaryRemoteDataSource>(),
      ),
    )
    ..registerFactory<GetProfileSummary>(
      () => GetProfileSummary(getIt<ProfileSummaryRepository>()),
    )
    ..registerFactory<ProfileSummaryCubit>(
      () => ProfileSummaryCubit(getProfileSummary: getIt<GetProfileSummary>()),
    )
    ..registerFactory<ChangeProfilePhoto>(
      () => ChangeProfilePhoto(getIt<ProfileSummaryRepository>()),
    )
    ..registerFactory<ProfilePhotoCubit>(
      () => ProfilePhotoCubit(
        photoPicker: getIt<PhotoPicker>(),
        changeProfilePhoto: getIt<ChangeProfilePhoto>(),
      ),
    );
}
