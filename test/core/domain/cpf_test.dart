import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/cpf.dart';

void main() {
  group('extractCpfDigits', () {
    test('drops the mask', () {
      expect(extractCpfDigits('529.982.247-25'), '52998224725');
    });
  });

  group('isValidCpf', () {
    test('accepts valid check digits with or without punctuation', () {
      expect(isValidCpf('52998224725'), isTrue);
      expect(isValidCpf('529.982.247-25'), isTrue);
    });

    test('rejects wrong check digits, repeated digits and wrong length', () {
      expect(isValidCpf('52998224726'), isFalse);
      expect(isValidCpf('11111111111'), isFalse);
      expect(isValidCpf('5299822472'), isFalse);
    });

    test('rejects an empty value', () {
      expect(isValidCpf(''), isFalse);
    });
  });

  group('cpfCheckDigit', () {
    test('computes both check digits of a valid CPF', () {
      expect(cpfCheckDigit([5, 2, 9, 9, 8, 2, 2, 4, 7]), 2);
      expect(cpfCheckDigit([5, 2, 9, 9, 8, 2, 2, 4, 7, 2]), 5);
    });
  });
}
