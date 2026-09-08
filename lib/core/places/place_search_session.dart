import 'dart:math';

const _tokenAlphabet = 'abcdef0123456789';
const _tokenLength = 32;

String generatePlaceSessionToken(Random random) {
  final buffer = StringBuffer();
  for (var index = 0; index < _tokenLength; index++) {
    buffer.write(_tokenAlphabet[random.nextInt(_tokenAlphabet.length)]);
  }
  return buffer.toString();
}

class PlaceSearchSession {
  PlaceSearchSession({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  String? _token;

  String currentToken() => _token ??= generatePlaceSessionToken(_random);

  void completeAfterHandover() => _token = null;
}
