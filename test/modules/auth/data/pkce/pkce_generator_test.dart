import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/data/pkce/pkce_generator.dart';

void main() {
  group('PkceGenerator', () {
    test('S256 challenge matches the RFC 7636 Appendix B example', () {
      // Fixed vector from RFC 7636 so the crypto is verified exactly.
      const verifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk';
      const expectedChallenge = 'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM';

      final challenge = PkceGenerator().createCodeChallenge(verifier);

      expect(challenge, expectedChallenge);
    });

    test('verifier and state are URL-safe and unpadded', () {
      final pkce = PkceGenerator();

      final verifier = pkce.createCodeVerifier();
      final state = pkce.createState();

      expect(verifier, matches(r'^[A-Za-z0-9_-]+$'));
      expect(state, matches(r'^[A-Za-z0-9_-]+$'));
    });

    test('same seed produces the same verifier (deterministic for tests)', () {
      final a = PkceGenerator(random: Random(1)).createCodeVerifier();
      final b = PkceGenerator(random: Random(1)).createCodeVerifier();

      expect(a, b);
    });
  });
}
