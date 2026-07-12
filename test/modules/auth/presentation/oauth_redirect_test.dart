import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/oauth_redirect.dart';

import '../auth_fixtures.dart';

void main() {
  const redirect = 'com.vanep.vanepmobile://oauth2redirect';

  group('isOAuthRedirect', () {
    test('matches the redirect scheme', () {
      expect(
        isOAuthRedirect('$redirect?code=abc&state=state-123', redirect),
        isTrue,
      );
    });

    test('does not match the backend authorize/login URLs', () {
      expect(isOAuthRedirect('http://10.0.2.2:8080/login', redirect), isFalse);
    });
  });

  group('extractAuthorizationCode', () {
    test('returns the code when state matches', () {
      const url = '$redirect?code=the-code&state=state-123';
      expect(
        extractAuthorizationCode(url, fakeAuthorizationRequest),
        'the-code',
      );
    });

    test('returns null when state does not match', () {
      const url = '$redirect?code=the-code&state=tampered';
      expect(extractAuthorizationCode(url, fakeAuthorizationRequest), isNull);
    });

    test('returns null when the redirect carries an error', () {
      const url = '$redirect?error=access_denied&state=state-123';
      expect(extractAuthorizationCode(url, fakeAuthorizationRequest), isNull);
    });

    test('returns null when there is no code', () {
      const url = '$redirect?state=state-123';
      expect(extractAuthorizationCode(url, fakeAuthorizationRequest), isNull);
    });
  });
}
