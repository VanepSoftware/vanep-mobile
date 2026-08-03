import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../entities/user_profile.dart';
import '../failures/auth_failure.dart';
import '../failures/profile_edit_failure.dart';
import '../value_objects/authorization_request.dart';
import '../value_objects/profile_patch_request.dart';

abstract class AuthRepository {
  AuthorizationRequest buildAuthorizationRequest();

  Future<Result<AuthFailure, AuthSession>> exchangeCode({
    required String code,
    required AuthorizationRequest request,
  });

  Future<Result<AuthFailure, AuthSession?>> currentSession();

  Future<Result<AuthFailure, void>> signOut();

  Future<Result<ProfileEditFailure, UserProfile>> refreshUserProfile();

  Future<Result<ProfileEditFailure, UserProfile>> patchUserProfile(
    ProfilePatchRequest request,
  );

  Future<Result<ProfileEditFailure, UserProfile>> requestEmailChange(
    String email,
  );
}
