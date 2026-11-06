import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';

void main() {
  test('parses reais input into cents', () {
    expect(parseReaisInput(''), 0);
    expect(parseReaisInput('350'), 35000);
    expect(parseReaisInput('350,5'), 35050);
    expect(parseReaisInput('350,50'), 35050);
    expect(parseReaisInput('12,'), 1200);
    expect(parseReaisInput('1.350'), isNull);
    expect(formatReaisInput(35000), '350');
    expect(formatReaisInput(35050), '350,50');
  });
}
