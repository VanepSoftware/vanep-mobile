import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/decline_reason.dart';

void main() {
  test('joins the reason and the message in one text', () {
    expect(
      composeDeclineReason('Escolhi outra van', ' Obrigada, Rita. '),
      'Escolhi outra van. Obrigada, Rita.',
    );
  });

  test('a reason without a message goes alone', () {
    expect(composeDeclineReason('Outro motivo', '  '), 'Outro motivo');
  });

  test('the message fits in what the longest reason leaves of the limit', () {
    expect(
      declineMessageMaxLength(['Outro motivo', 'Escolhi outra van']),
      500 - 'Escolhi outra van'.length - 2,
    );
  });

  test('a reason and a message over 500 characters do not fit', () {
    expect(fitsDeclineReasonLimit('Outro motivo', 'a' * 486), isTrue);
    expect(fitsDeclineReasonLimit('Outro motivo', 'a' * 487), isFalse);
  });
}
