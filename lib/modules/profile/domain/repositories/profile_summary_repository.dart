import '../../../../core/media/photo_failure.dart';
import '../../../../core/media/picked_photo.dart';
import '../../../../core/result/result.dart';
import '../../../auth/domain/value_objects/user_type.dart';
import '../entities/profile_summary.dart';
import '../failures/profile_summary_failure.dart';

abstract class ProfileSummaryRepository {
  Future<Result<ProfileSummaryFailure, ProfileSummary>> fetchSummary(
    UserType type,
  );

  Future<Result<PhotoFailure, void>> uploadPhoto(
    ProfileSummary owner,
    PickedPhoto photo,
  );
}
