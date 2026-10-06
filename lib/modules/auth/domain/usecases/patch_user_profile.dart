import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/auth_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';

class PatchUserProfile {
  const PatchUserProfile(this._repository);

  final AuthRepository _repository;

  Future<Result<ProfileEditFailure, UserProfile>> call(
    ProfilePatchRequest request,
  ) {
    return _repository.patchUserProfile(request);
  }
}
