import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PkceGenerator {
  PkceGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  String createCodeVerifier() => _randomUrlSafe(32);

  String createCodeChallenge(String verifier) {
    final digest = sha256.convert(ascii.encode(verifier));
    return _withoutPadding(base64UrlEncode(digest.bytes));
  }

  String createState() => _randomUrlSafe(16);

  String _randomUrlSafe(int byteCount) {
    final bytes = List<int>.generate(byteCount, (_) => _random.nextInt(256));
    return _withoutPadding(base64UrlEncode(bytes));
  }

  static String _withoutPadding(String value) => value.replaceAll('=', '');
}
