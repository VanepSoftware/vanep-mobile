import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/google_id_token_source.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

void main() {
  late MockGoogleSignIn googleSignIn;
  late MockGoogleSignInAccount account;

  setUp(() {
    googleSignIn = MockGoogleSignIn();
    account = MockGoogleSignInAccount();
    when(
      () =>
          googleSignIn.initialize(serverClientId: any(named: 'serverClientId')),
    ).thenAnswer((_) async {});
  });

  GoogleSignInIdTokenSource buildSource({String serverClientId = 'web-id'}) {
    return GoogleSignInIdTokenSource(
      googleSignIn: googleSignIn,
      serverClientId: serverClientId,
    );
  }

  test(
    'initializes once with the Web client id and returns the token',
    () async {
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => account);
      when(
        () => account.authentication,
      ).thenReturn(const GoogleSignInAuthentication(idToken: 'id-token'));
      final source = buildSource();

      expect(await source.requestIdToken(), 'id-token');
      expect(await source.requestIdToken(), 'id-token');

      verify(() => googleSignIn.initialize(serverClientId: 'web-id')).called(1);
    },
  );

  test('a cancelled chooser returns null', () async {
    when(() => googleSignIn.authenticate()).thenThrow(
      const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );

    expect(await buildSource().requestIdToken(), isNull);
  });

  test('other SDK errors become GoogleIdTokenException', () async {
    when(() => googleSignIn.authenticate()).thenThrow(
      const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      ),
    );

    expect(
      buildSource().requestIdToken(),
      throwsA(const GoogleIdTokenException('clientConfigurationError')),
    );
  });

  test('an account without ID token is an error', () async {
    when(() => googleSignIn.authenticate()).thenAnswer((_) async => account);
    when(
      () => account.authentication,
    ).thenReturn(const GoogleSignInAuthentication(idToken: null));

    expect(
      buildSource().requestIdToken(),
      throwsA(const GoogleIdTokenException('missing_id_token')),
    );
  });

  test('without a server client id nothing is requested', () async {
    expect(
      buildSource(serverClientId: '').requestIdToken(),
      throwsA(const GoogleIdTokenException('missing_server_client_id')),
    );
    verifyNever(() => googleSignIn.authenticate());
  });

  test('signOut only reaches the SDK once it was initialized', () async {
    when(() => googleSignIn.signOut()).thenAnswer((_) async {});
    when(() => googleSignIn.authenticate()).thenAnswer((_) async => account);
    when(
      () => account.authentication,
    ).thenReturn(const GoogleSignInAuthentication(idToken: 'id-token'));
    final source = buildSource();

    await source.signOut();
    verifyNever(() => googleSignIn.signOut());

    await source.requestIdToken();
    await source.signOut();
    verify(() => googleSignIn.signOut()).called(1);
  });
}
