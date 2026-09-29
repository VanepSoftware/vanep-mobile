import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/photo_failure_label.dart';
import 'package:vanep_mobile/core/formatters/upper_case_input_formatter.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';

void main() {
  test('every photo failure has its own message', () {
    final l10n = AppLocalizationsPt();
    final labels = PhotoFailure.values
        .map((failure) => photoFailureLabel(l10n, failure))
        .toSet();

    expect(labels, hasLength(PhotoFailure.values.length));
    expect(
      photoFailureLabel(l10n, PhotoFailure.tooLarge),
      'A foto é grande demais. Escolha outra.',
    );
  });

  test('upper-cases what is typed', () {
    final formatted = const UpperCaseInputFormatter().formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: 'abc1d23'),
    );

    expect(formatted.text, 'ABC1D23');
  });
}
