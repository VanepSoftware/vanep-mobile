import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/search_text.dart';

void main() {
  test('folds case, accents and surrounding spaces', () {
    expect(foldForSearch('  Sofía Conceição  '), 'sofia conceicao');
    expect(foldForSearch('JOÃO'), 'joao');
  });
}
