import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/phone/phone_caller.dart';

void main() {
  test('a formatted phone becomes a dialable tel uri', () {
    expect(phoneCallUri('(61) 99999-0000').toString(), 'tel:61999990000');
  });

  test('the country prefix is kept', () {
    expect(phoneCallUri('+55 61 99999-0000').toString(), 'tel:+5561999990000');
  });
}
