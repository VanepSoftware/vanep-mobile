import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/authorization_request.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

class FakeUserProfile implements UserProfile {
  const FakeUserProfile({
    this.token = 'user-token-1',
    this.name = 'Ana Motorista',
    this.email = 'ana@vanep.com.br',
    this.phone = '11999999999',
    this.document = '12345678901',
    this.birthDate = '1990-05-15',
    this.gender = Gender.female,
    this.type = UserType.driver,
  });

  @override
  final String token;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? document;
  @override
  final String? birthDate;
  @override
  final Gender? gender;
  @override
  final UserType? type;
}

class FakeAuthSession implements AuthSession {
  FakeAuthSession({
    this.accessToken = 'access-1',
    this.refreshToken = 'refresh-1',
    DateTime? expiresAt,
    this.profile = const FakeUserProfile(),
  }) : expiresAt = expiresAt ?? DateTime(2999);

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final DateTime expiresAt;
  @override
  final UserProfile profile;
}

const fakeAuthorizationRequest = AuthorizationRequest(
  authorizationUrl:
      'http://10.0.2.2:8080/oauth2/authorize?response_type=code&client_id=vanep-mobile',
  redirectUri: 'com.vanep.vanepmobile://oauth2redirect',
  state: 'state-123',
  codeVerifier: 'verifier-123',
);
