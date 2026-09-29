import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../entities/user_profile.dart';
import '../failures/auth_failure.dart';
import '../failures/profile_edit_failure.dart';
import '../value_objects/profile_patch_request.dart';

abstract class AuthRepository {
  Future<Result<AuthFailure, AuthSession>> signInWithPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthFailure, AuthSession>> signInWithGoogle();

  Future<Result<AuthFailure, AuthSession?>> currentSession();

  Future<Result<AuthFailure, AuthSession?>> refreshSession();

  Future<Result<AuthFailure, void>> signOut();

  Future<Result<ProfileEditFailure, UserProfile>> refreshUserProfile();

  Future<Result<ProfileEditFailure, UserProfile>> patchUserProfile(
    ProfilePatchRequest request,
  );

  Future<Result<ProfileEditFailure, UserProfile>> requestEmailChange(
    String email,
  );
}
