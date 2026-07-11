import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates PKCE (RFC 7636) values and the anti-CSRF `state`.
///
/// [random] is injectable so tests can make the output deterministic; in
/// production a [Random.secure] source is used.
class PkceGenerator {
  PkceGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// A high-entropy `code_verifier`: 32 random bytes, base64url without padding.
  String createCodeVerifier() => _randomUrlSafe(32);

  /// The S256 `code_challenge` for [verifier]: base64url(sha256(verifier)),
  /// without padding.
  String createCodeChallenge(String verifier) {
    final digest = sha256.convert(ascii.encode(verifier));
    return _withoutPadding(base64UrlEncode(digest.bytes));
  }

  /// An opaque `state` value to correlate the redirect with this request.
  String createState() => _randomUrlSafe(16);

  String _randomUrlSafe(int byteCount) {
    final bytes = List<int>.generate(byteCount, (_) => _random.nextInt(256));
    return _withoutPadding(base64UrlEncode(bytes));
  }

  static String _withoutPadding(String value) =>
      value.replaceAll('=', '');
}
