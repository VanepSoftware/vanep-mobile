import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';

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
