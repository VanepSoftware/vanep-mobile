import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';
import '../failures/profile_edit_failure.dart';
import '../repositories/auth_repository.dart';

class RefreshUserProfile {
  const RefreshUserProfile(this._repository);

  final AuthRepository _repository;

  Future<Result<ProfileEditFailure, UserProfile>> call() {
    return _repository.refreshUserProfile();
  }
}
