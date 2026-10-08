import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/repositories/profile_summary_repository.dart';

class ChangeProfilePhoto {
  const ChangeProfilePhoto(this.repository);

  final ProfileSummaryRepository repository;

  Future<Result<PhotoFailure, void>> call(
    ProfileSummary owner,
    PickedPhoto photo,
  ) {
    return repository.uploadPhoto(owner, photo);
  }
}
