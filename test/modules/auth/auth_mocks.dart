import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/account_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/auth_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';

import 'account_fixtures.dart';
import 'auth_fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

void registerAuthFallbacks() {
  registerFallbackValue(fakeAuthorizationRequest);
  registerFallbackValue(const ProfilePatchRequest());
  registerFallbackValue(const FakeUserProfile());
  registerFallbackValue(validClientSignupForm);
}
