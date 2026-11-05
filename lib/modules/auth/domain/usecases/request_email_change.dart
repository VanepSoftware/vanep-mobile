import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/auth_repository.dart';

class RequestEmailChange {
  const RequestEmailChange(this._repository);

  final AuthRepository _repository;

  Future<Result<ProfileEditFailure, UserProfile>> call(String email) {
    return _repository.requestEmailChange(email);
  }
}
