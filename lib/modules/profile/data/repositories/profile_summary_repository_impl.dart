import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/network/photo_uploader.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/failures/profile_summary_failure.dart';
import 'package:vanep_mobile/modules/profile/domain/profile_summary_support.dart';
import 'package:vanep_mobile/modules/profile/domain/repositories/profile_summary_repository.dart';
import 'package:vanep_mobile/modules/profile/data/datasources/profile_summary_remote_datasource.dart';

class ProfileSummaryRepositoryImpl implements ProfileSummaryRepository {
  ProfileSummaryRepositoryImpl({required this.remote});

  final ProfileSummaryRemoteDataSource remote;

  @override
  Future<Result<ProfileSummaryFailure, ProfileSummary>> fetchSummary(
    UserType type,
  ) async {
    if (!supportsProfileSummary(type)) {
      return const Err(UnsupportedProfileSummaryFailure());
    }
    try {
      final summary = await remote.fetchSummary(type);
      return Ok(summary);
    } on DioException catch (error) {
      return Err(NetworkProfileSummaryFailure(error.message));
    } on Object catch (error) {
      return Err(UnexpectedProfileSummaryFailure(error.toString()));
    }
  }

  @override
  Future<Result<PhotoFailure, void>> uploadPhoto(
    ProfileSummary owner,
    PickedPhoto photo,
  ) async {
    try {
      await remote.uploadPhoto(owner, photo);
      return const Ok(null);
    } on DioException catch (error) {
      return Err(photoFailureFrom(error));
    }
  }
}
