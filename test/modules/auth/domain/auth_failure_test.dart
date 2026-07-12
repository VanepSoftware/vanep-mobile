import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';

void main() {
  test('failures use value equality including their detail', () {
    expect(const CancelledAuthFailure(), const CancelledAuthFailure());
    expect(const InvalidStateAuthFailure(), const InvalidStateAuthFailure());
    expect(const NetworkAuthFailure('x'), const NetworkAuthFailure('x'));
    expect(const NetworkAuthFailure('x'), isNot(const NetworkAuthFailure('y')));
    expect(
      const UnexpectedAuthFailure('boom'),
      const UnexpectedAuthFailure('boom'),
    );
  });

  test('detail is optional', () {
    expect(const NetworkAuthFailure().detail, isNull);
    expect(const UnexpectedAuthFailure('e').detail, 'e');
  });
}
