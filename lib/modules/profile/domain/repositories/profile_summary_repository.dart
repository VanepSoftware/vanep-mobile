import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/failures/profile_summary_failure.dart';

abstract class ProfileSummaryRepository {
  Future<Result<ProfileSummaryFailure, ProfileSummary>> fetchSummary(
    UserType type,
  );

  Future<Result<PhotoFailure, void>> uploadPhoto(
    ProfileSummary owner,
    PickedPhoto photo,
  );
}
