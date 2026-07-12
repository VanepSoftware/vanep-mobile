import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/auth_repository.dart';

import 'auth_fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void registerAuthFallbacks() {
  registerFallbackValue(fakeAuthorizationRequest);
}
