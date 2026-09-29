import '../../../../core/media/photo_failure.dart';
import '../../../../core/media/picked_photo.dart';
import '../../../../core/result/result.dart';
import '../entities/profile_summary.dart';
import '../repositories/profile_summary_repository.dart';

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
