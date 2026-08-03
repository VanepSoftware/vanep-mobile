import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';
import '../failures/profile_edit_failure.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/profile_patch_request.dart';

class PatchUserProfile {
  const PatchUserProfile(this._repository);

  final AuthRepository _repository;

  Future<Result<ProfileEditFailure, UserProfile>> call(
    ProfilePatchRequest request,
  ) {
    return _repository.patchUserProfile(request);
  }
}
