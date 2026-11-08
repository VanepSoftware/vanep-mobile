import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/cpf_input_formatter.dart';

TextEditingValue formatTyped(String text) {
  return const CpfInputFormatter().formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(text: text),
  );
}

void main() {
  group('formatPartialCpf', () {
    test('shows up to three digits without punctuation', () {
      expect(formatPartialCpf(''), '');
      expect(formatPartialCpf('529'), '529');
    });

    test('puts the dots after the third and sixth digits', () {
      expect(formatPartialCpf('5299'), '529.9');
      expect(formatPartialCpf('529982247'), '529.982.247');
    });

    test('puts the hyphen before the check digits', () {
      expect(formatPartialCpf('52998224725'), '529.982.247-25');
    });
  });

  group('CpfInputFormatter', () {
    test('masks what is typed', () {
      expect(formatTyped('52998224725').text, '529.982.247-25');
    });

    test('keeps the caret at the end', () {
      final value = formatTyped('52998224725');

      expect(value.selection, const TextSelection.collapsed(offset: 14));
    });

    test('ignores letters and symbols', () {
      expect(formatTyped('529a.982/247-25').text, '529.982.247-25');
    });

    test('stops at eleven digits', () {
      expect(formatTyped('5299822472599').text, '529.982.247-25');
    });
  });
}
