import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

void main() {
  test('two schools with the same token and name are equal', () {
    expect(
      const School(token: 'school-delta', name: 'Colégio Delta'),
      const School(token: 'school-delta', name: 'Colégio Delta'),
    );
  });

  test('rejections are equal only with the same detail', () {
    expect(
      const SchoolRejectedFailure(detail: 'Não é uma escola.'),
      const SchoolRejectedFailure(detail: 'Não é uma escola.'),
    );
    expect(
      const SchoolRejectedFailure(detail: 'a'),
      isNot(const SchoolRejectedFailure(detail: 'b')),
    );
  });

  test('failures without data are equal by kind', () {
    expect(const SchoolNetworkFailure(), const SchoolNetworkFailure());
    expect(
      const SchoolUnexpectedFailure(),
      isNot(const SchoolNetworkFailure()),
    );
  });
}
