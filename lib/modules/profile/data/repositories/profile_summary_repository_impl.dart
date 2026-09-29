import 'package:dio/dio.dart';

import '../../../../core/media/photo_failure.dart';
import '../../../../core/media/picked_photo.dart';
import '../../../../core/network/photo_uploader.dart';
import '../../../../core/result/result.dart';
import '../../../auth/domain/value_objects/user_type.dart';
import '../../domain/entities/profile_summary.dart';
import '../../domain/failures/profile_summary_failure.dart';
import '../../domain/profile_summary_support.dart';
import '../../domain/repositories/profile_summary_repository.dart';
import '../datasources/profile_summary_remote_datasource.dart';

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
