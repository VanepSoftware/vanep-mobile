import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/places/place_search_session.dart';

void main() {
  test('keeps the same token across one search', () {
    final session = PlaceSearchSession();

    final first = session.currentToken();
    final second = session.currentToken();

    expect(first, second);
    expect(first, isNotEmpty);
  });

  test('starts a new token after the selection is handed over', () {
    final session = PlaceSearchSession();
    final duringSearch = session.currentToken();

    session.completeAfterHandover();
    final afterHandover = session.currentToken();

    expect(afterHandover, isNot(duringSearch));
  });

  test('two boxes never share a token', () {
    final originBox = PlaceSearchSession();
    final destinationBox = PlaceSearchSession();

    expect(originBox.currentToken(), isNot(destinationBox.currentToken()));
  });

  test('reuses the token for every request until handover', () {
    final session = PlaceSearchSession();

    final tokens = List.generate(5, (_) => session.currentToken()).toSet();

    expect(tokens, hasLength(1));
  });

  test('a fresh session after handover is stable again', () {
    final session = PlaceSearchSession()..completeAfterHandover();

    final first = session.currentToken();
    final second = session.currentToken();

    expect(first, second);
  });
}
