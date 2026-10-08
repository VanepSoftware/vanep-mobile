import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/media/photo_picker.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/network/photo_uploader.dart';
import 'package:vanep_mobile/modules/profile/data/datasources/profile_summary_remote_datasource.dart';
import 'package:vanep_mobile/modules/profile/data/repositories/profile_summary_repository_impl.dart';
import 'package:vanep_mobile/modules/profile/domain/repositories/profile_summary_repository.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/change_profile_photo.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/get_profile_summary.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';

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
