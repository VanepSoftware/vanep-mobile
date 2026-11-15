import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/schools/data/dtos/school_dto.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';

import '../schools_mocks.dart';

void main() {
  test('a school is read from the token and the name of the response', () {
    expect(
      schoolFromJson(deltaSchoolJson),
      const School(token: 'school-delta', name: 'Colégio Delta'),
    );
  });
}
